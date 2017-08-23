//
//  StoryFeedViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedViewController.h"
#import "StoryDetailsViewController.h"
#import "StoryFeedTableViewCell.h"
#import "StoryFeedCollectionViewQuestionCell.h"
#import "StoryFeedCollectionViewLinkCell.h"
#import "StoryFeedCollectionViewMultimediaCell.h"
#import "StoryFeedCollectionViewHardFactsCell.h"
#import "SVPullToRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import "DataManager.h"
#import "Company.h"
#import "Story.h"
#import "Author.h"
#import "SocialManager.h"
#import "DejalActivityView.h"
#import "User.h"
#import "CompanyProfileViewController.h"
#import "UIViewController+RootNavigationController.h"
#import "RootNavigationController.h"
#import "TTTabBarController.h"
#import "TTDeeplinkManager.h"
#import "DetailsPageViewController.h"
#import "GeneralMethods.h"
#import "LinedTextView.h"
#import "StoryFeedJoinCompanyCollectionViewCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Story.h"
#import "StrokeLogoIndicator.h"
#import "UIImage+sizedImageNamed.h"
#import "VideoControllersView.h"
#import "UIView+Additions.h"
#import "Mixpanel.h"
#import "CompanyLookingForViewController.h"

@interface StoryFeedViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, StoryFeedCollectionViewCellDelegate, StoryFeedTableViewCellDelegate, DetailsPageDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, VideoControllersViewDelegate, StoryFeedCollectionViewMultimediaCellDelegate>


@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSMutableArray *dataContainer;
@property NSInteger currentPage;
@property (strong, nonatomic) StoryFeedCollectionViewMultimediaCell *currPlayingCell;
@property (nonatomic, strong) UIViewController *loadingViewController;
@property (nonatomic) CGPoint currentContentOffset;
@property NSInteger currentItemIndex;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, strong) NSMutableArray *videoPlayers;

@property (nonatomic, strong) NSIndexPath *vibedIndexPath;
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, strong) NSTimer *videoControllersTimer;
@property (nonatomic, strong) NSMutableDictionary *thumbnailDictionary;
@property (nonatomic, assign) BOOL autoPlayed;
@property (nonatomic, strong) VideoControllersView *videoControllersView;
@property (nonatomic, strong) StoryFeedCollectionViewMultimediaCell *currentMultimediaCell;
@property (nonatomic, weak) IBOutlet UIView *statusBarBackgroundView;
@property (nonatomic, strong) dispatch_block_t repeatControllersBlock;
@end

@implementation StoryFeedViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"TalentTribe";
    }
    return self;
}

#pragma mark Reloading data

- (void)reloadData
{
    @synchronized(self)
    {
        static BOOL loading = NO;
        if (!loading)
        {
            loading = YES;
            if (!self.dataContainer || [[DataManager sharedManager] isHashDiffrent])
            {
                [[DataManager sharedManager] setHashDiffrent:NO];
                if (self.loadingViewController)
                {
                    if (self.selectedCategory)
                    {
                        //[TTActivityIndicator showOnMainWindow];
                        [StrokeLogoIndicator showOnMainWindow];
                    }
                    else
                    {
                        //[TTActivityIndicator showOnMainWindowOnTop];
                        [StrokeLogoIndicator showOnMainWindowOnTop];
                    }
                }
                else
                {
                    //[TTActivityIndicator showOnMainWindow];
                    [StrokeLogoIndicator showOnMainWindow];
                }
                
                [self.tableView.infiniteScrollingView setEnabled:NO];
                self.currentPage = 0;
                self.contentOffsetDictionary = [NSMutableDictionary new];
                [[DataManager sharedManager] storyFeedForCategory:nil companyId:nil completionHandler:^(id result, NSError *error) {
                     if (result && !error) {
                         NSArray *companyUpdated = [self updateFeedCompaniesWithHardFacts:result];
                         self.dataContainer = [[NSMutableArray alloc] initWithArray:companyUpdated];
                         
                         NSMutableArray *urls = [NSMutableArray new];
                         for (Company *company in result) {
                             Story *story = company.stories.firstObject;
                             DLog(@"%@", story.videoLink);
                             NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
                             NSURL *thumbnail = [NSURL URLWithString:story.videoThumbnailLink];
                             if (url) {
                                 DLog(@"Downloading story image with URL %@", url);
                                 [urls addObject:url];
                             } else if (thumbnail) {
                                 [urls addObject:thumbnail];
                             }
                        }
                         
                         // Preload search/explore data
                         [[DataManager sharedManager] exploreCategoriesForPage:0 count:EXPLORE_DEFAULT_PAGE_SIZE completionHandler:^(id result, NSError *error) {
                             if (result && !error) {
                                 NSDictionary *resultDict = (NSDictionary *)result;
                                 NSArray *fixedArray = [resultDict objectForKeyOrNil:kFixedCategories];
                                 [DataManager sharedManager].fixedArray = [[NSMutableArray alloc] init];
                                 if (fixedArray) {
                                     [[DataManager sharedManager].fixedArray addObjectsFromArray:fixedArray];
                                 }
                                 
                                 NSArray *trendingArray = [resultDict objectForKeyOrNil:kTrendingCategories];
                                 [DataManager sharedManager].trendingArray = [[NSMutableArray alloc] init];
                                 if (trendingArray) {
                                     [[DataManager sharedManager].trendingArray addObjectsFromArray:trendingArray];
                                 }
                             }
                         }];
                         
                         [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
                         
                         //[self.tableView.infiniteScrollingView setEnabled:(self.dataContainer.count == STORYFEED_DEFAULT_PAGE_SIZE)];
                         [self.tableView reloadData];
                         
                         // download indexes for next stories
                         [[DataManager sharedManager] storyFeedIndexesWithParams:@{@"page" : @(1)} forceReload:YES completionHandler:^(id result, NSError *error) {
                             if (result && !error) {
                                 
                             }
                         }];
                         [self handleDeeplink];
                     }
                     else
                     {
                         //handle error
                     }
                     
                     if (self.loadingViewController)
                     {
                         //[TTActivityIndicator dismiss];
                         [StrokeLogoIndicator dismiss];
                     }
                     else
                     {
                         //[TTActivityIndicator dismiss];
                         [StrokeLogoIndicator dismiss];
                     }
                     
                     [self.tableView.infiniteScrollingView setEnabled:YES];
                     loading = NO;
                     [self removeLoadingViewControllerAnimated:YES];
                 }];
            } else
            {
                [self.tableView reloadData];
                loading = NO;
            }
        }
    }
}

- (void)refreshFeed:(UIControlEvents)event {
    static BOOL refreshing = NO;
    void (^stopRefreshController)() = ^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refresh endRefreshing];
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                refreshing = NO;
            });
        });
    };

    if (refreshing) {
        return;
    }
    
    if ([DataManager sharedManager].isHashDiffrent) {
        [self reloadData];
        stopRefreshController();
        return;
    }
    refreshing = YES;
    @synchronized(self) {
        NSLog(@"Refreshed");
        [self.tableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.refresh.bounds)) animated:YES];
        
        // end refreshing + set tableview contentOffset should be in response block for refresh
        [[DataManager sharedManager] storyFeedIndexesWithParams:@{@"page" : @(1)} forceReload:NO completionHandler:^(id result, NSError *error) {
            NSMutableArray *ids = [NSMutableArray new];
            if (result && !error) {
                DLog(@"Results %@", result);
                
                for (NSArray *row in result) {
                    [ids addObjectsFromArray:row];
                }
                
                [[DataManager sharedManager] sha1StringFromIdsArray:[ids copy] completionHandler:^(id result, NSError *error) {
                    if (result && !error) {
                        stopRefreshController();
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.refresh endRefreshing];
                                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                            });
                        });
                        [[DataManager sharedManager] refreshIdIndexesWithEncryptedString:result completionHandler:^(id result, NSError *error) {
                            if ([result[@"isEqualHash"] isEqualToString:@"NO"]) {
                                [[DataManager sharedManager] setHashDiffrent:YES];
                            }
                        }];
                    }
                }];
            }
        }];
    }
}

- (void)loadPage:(NSInteger)page {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        
        // make a new call with current company index, and load the next company with indexes
        [[DataManager sharedManager] storyFeedIndexesForYAxis:[self rowDataClaculatedSnippet:self.dataContainer withRow:self.dataContainer.count] maxCount:5 completionHandler:^(id result, NSError *error) {
            DLog(@"Result load more %@", result);
            NSArray *arr = (NSArray *)result;
            if (arr.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self.tableView infiniteScrollingView] stopAnimating];
                    [self.tableView infiniteScrollingView].hidden = YES;
                });
                loading = NO;
                return ;
            }
            
            // make 2D ids array into 1D Array
            NSMutableArray *allIds = [NSMutableArray new];
            for (NSArray *ids in result) {
                [allIds addObjectsFromArray:ids];
            }
            
            DLog(@"allIds %@", allIds);
            if (allIds.count == 0) {
                [[self.tableView infiniteScrollingView] stopAnimating];
                [self autoAdjustScrollToTop];
                loading = NO;
                return ;
            }
            [[DataManager sharedManager] storyFeedIndexesWithParams:nil forceReload:NO completionHandler:^(id result, NSError *error) {
                [[DataManager sharedManager] storiesByIds:@{@"ids" : allIds, @"size" : [GeneralMethods screenSizeDict]} orderByIndexes:result completionHandler:^(id result, NSError *error) {
                    if (result && !error) {
                        self.currentPage = page;
                        
                        NSInteger lastCount = self.dataContainer.count;
                        [self.dataContainer addObjectsFromArray:[self updateFeedCompaniesWithHardFacts:result]];

                        NSMutableArray *urls = [NSMutableArray new];
                        for (Company *company in result) {
                            Story *story = company.stories.firstObject;
                            NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
                            NSURL *thumbnail = [NSURL URLWithString:story.videoThumbnailLink];
                            if (url) {
                                DLog(@"Downloading story image with URL %@", url);
                                [urls addObject:url];
                            } else if (thumbnail) {
                                [urls addObject:thumbnail];
                            }
                        }
                        
                        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
    
                        // add snip
                        if (self.currentPage == 1) {
                            // join-company snippet
                            Company *createCompany = [Company new];
                            createCompany.companyName = @"TalentTribe";
                            createCompany.companyLogo = [[[NSBundle mainBundle] URLForResource:[UIImage scaledNameForName:@"story_logo"] withExtension:@"png"] absoluteString];
                            Story *joinCompanySnip = [Story new];
                            joinCompanySnip.storyType = StoryTypeJoinCompanySnip;
                            joinCompanySnip.storyTitle = @"";
                            joinCompanySnip.storyImages = [[NSMutableArray alloc] initWithArray:@[@{kRegularImage :[[[NSBundle mainBundle] URLForResource:[UIImage sizedNameForName:@"createProfileStory"] withExtension:@"png"] absoluteString]}]];
                            createCompany.stories = @[joinCompanySnip];
                            
                            if (self.dataContainer.count > STORYFEED_JOIN_COMPANY_INDEX) {
                                [self.dataContainer insertObject:createCompany atIndex:STORYFEED_JOIN_COMPANY_INDEX];
                            } else {
                                [self.dataContainer addObject:createCompany];
                            }
                        }
                        
                        //[self.tableView reloadData];
                        DLog(@"*********************** UPDATE TABLE VIEW ***********************");
                        NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                        for (NSInteger i = lastCount; i < self.dataContainer.count; i++) {
                            [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                        [self.tableView beginUpdates];
                        [self.tableView insertRowsAtIndexPaths:[indexPathArray copy] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    } else {
                        //handle error
                    }
                    [[self.tableView infiniteScrollingView] stopAnimating];
                    [self autoAdjustScrollToTop];
                    loading = NO;
                }];
            }];
        }];
    }
}

- (void)performPendingVibeAction {
    if (self.vibedIndexPath) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in visibleRows) {
                if ([self.vibedIndexPath isEqual:indexPath]) {
                    DataManager *dMgr = [DataManager sharedManager];
                    if ([dMgr isCredentialsSavedInKeychain] && [dMgr.currentUser isProfileMinimumFilled]) {
                        NSInteger index = [visibleRows indexOfObject:indexPath];
                        StoryFeedTableViewCell *storyCell = [[self.tableView visibleCells] objectAtIndex:index];
                        [storyCell.dragVibeView performVibeActionManually];
                    }
                    break;
                }
            }
            self.vibedIndexPath = nil;
        });
    }
}

- (void)removeLoadingViewControllerAnimated:(BOOL)animated {
    if (self.loadingViewController) {
        self.view.alpha = 0.0f;
        [UIView animateWithDuration:1.0f animations:^{
            self.view.alpha = 1.0f;
            self.loadingViewController.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.loadingViewController.view removeFromSuperview];
            self.loadingViewController = nil;
        }];
    } else {
        [self.loadingViewController.view removeFromSuperview];
        self.loadingViewController = nil;
    }
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataContainer.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryFeedTableViewCell *storyCell = (StoryFeedTableViewCell *)cell;
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(indexPath.row) stringValue]] floatValue];
    [storyCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    [self performPendingVibeAction];
    
    [self updateArrowsState];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryFeedTableViewCell *storyCell = (StoryFeedTableViewCell *)cell;
    CGFloat horizontalOffset = storyCell.collectionView.contentOffset.x;
    self.contentOffsetDictionary[[@(indexPath.row) stringValue]] = @(horizontalOffset);
    
    [self updateArrowsState];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForStoryFeedCell];
}

-(NSInteger)getStoryFromTableViewById:(NSString *)storyId
{
    for (Company *company in self.dataContainer)
    {
        Story *story = company.stories[0];
        
        if ([story.storyId isEqualToString:storyId])
        {
            return [self.dataContainer indexOfObject:company];
        }
    }
    
    return -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryFeedTableViewCell *storyCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    storyCell.tag = indexPath.row;
    [storyCell setDelegate:self];
    [storyCell setCollectionViewDataSource:self delegate:self];
    
    Company *company = [self.dataContainer objectAtIndex:indexPath.row];
    [storyCell setCompany:company];
    
    if ([Story isStoryTypeSnip:company.stories.firstObject]) {
        storyCell.headerContainer.hidden = YES;
        [storyCell.dragVibeView setHidden:YES];
    } else {
        [storyCell.dragVibeView setHidden:NO];
        if (company.companyName) {
            storyCell.companyTitle.attributedText = [TTUtils attributedCompanyName:company.companyName industry:company.industry];
            storyCell.headerContainer.hidden = NO;
        } else {
            storyCell.companyTitle.attributedText = nil;
            storyCell.headerContainer.hidden = YES;
        }
    }
    
    if (indexPath.row >= self.dataContainer.count - 5) {
        [self loadPage:self.currentPage + 1];
    }
    
    return storyCell;
}

- (void)updateArrowsState {
    for (StoryFeedTableViewCell *visibleCell in self.tableView.visibleCells) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [visibleCell updateButtonsState];
        });
    }
}

- (void)animateCollectionView {
    StoryFeedTableViewCell *tableViewCell = [self.tableView visibleCells].firstObject;
    UICollectionViewCell *collectionViewCell = tableViewCell.collectionView.visibleCells.firstObject;
    if ([tableViewCell.collectionView indexPathForCell:collectionViewCell].item > 0) {
        return;
    }
    
    //[self animateArrow:tableViewCell.rightButton withCompletion:nil];
}

- (void)animateArrow:(UIButton *)arrow withCompletion:(SimpleCompletionBlock)completion {
    arrow.layer.cornerRadius = CGRectGetWidth(arrow.bounds)/2;
    arrow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    [UIView animateWithDuration:0.3/1.5 animations:^{
        arrow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 2.0);
        /*
        arrow.layer.borderColor = [UIColor colorWithRed:(0.0/255/0) green:(179.0/255.0) blue:(234.0/255.0) alpha:1.0].CGColor;
        arrow.layer.borderWidth = 1.0;
         */
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            arrow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                arrow.transform = CGAffineTransformIdentity;
                arrow.layer.borderWidth = 0.0;
                if (completion) {
                    completion(YES, nil);
                }
            }];
        }];
    }];
}

#pragma mark Heights handling

- (CGFloat)heightForStoryFeedCell {
    return self.view.bounds.size.width;
}

#pragma mark UITableView delegate

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self cellForChildView:collectionView]];
    if (indexPath) {
        Company *company = [self.dataContainer objectAtIndex:indexPath.row];
        return company.stories.count;
    }
    return 0;
    
    
    
    /*
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self cellForChildView:collectionView]];
    if (indexPath) {
        Company *company = [self.dataContainer objectAtIndex:indexPath.row];
        return company.stories.count;
    }
    return 0;
     */
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *collectionIndexPath = [self.tableView indexPathForCell:[self cellForChildView:collectionView]];
    Company *company = [self.dataContainer objectAtIndex:collectionIndexPath.row];
    Story *story = [company.stories objectAtIndex:indexPath.row];

    StoryFeedCollectionViewCell *cell;
    switch (story.storyType) {
        case StoryTypeStory: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"storyCell" forIndexPath:indexPath];
        } break;
        case StoryTypeVibeSnip: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"vibeCell" forIndexPath:indexPath];
            if ([DataManager sharedManager].isCredentialsSavedInKeychain && ![DataManager sharedManager].currentUser.isProfileMinimumFilled) {
                NSMutableArray *words = [[NSMutableArray alloc] initWithArray:[cell.titleLabel.text componentsSeparatedByString:@" "]];
                if (words.count > 0) {
                    [words replaceObjectAtIndex:0 withObject:@"Complete"];
                    cell.titleLabel.text = [[words valueForKey:@"description"] componentsJoinedByString:@" "];
                }
            }
        } break;
        case StoryTypePrivacySnip: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"privacyCell" forIndexPath:indexPath];
        } break;
        case StoryTypeJoinCompanySnip: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"joinCompanyCell" forIndexPath:indexPath];
        } break;
        case StoryTypeQuestion: {
            
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"storyCell" forIndexPath:indexPath];
//            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"questionCell" forIndexPath:indexPath];
//            StoryFeedCollectionViewQuestionCell *questionCell = (StoryFeedCollectionViewQuestionCell *)cell;
//            
//            [questionCell setIndex:[company indexOfStoryByType:story]];
//            questionCell.questionAnswersLabel.hidden = story.commentsNum <= 0;
//            
//            if (story.commentsNum > 0) {
//                questionCell.questionAnswersLabel.attributedText = [self attributedStringForString:[NSString stringWithFormat:@"%ld people answered", (long)story.commentsNum] highlight:[NSString stringWithFormat:@"%ld", (long)story.commentsNum]];
//            } else {
//                questionCell.readMoreLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Be the first to answer »" attributes:@{NSFontAttributeName : questionCell.readMoreLabel.font, NSForegroundColorAttributeName : questionCell.readMoreLabel.textColor}];
//            }
        } break;
        case StoryTypeLink: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"linkCell" forIndexPath:indexPath];
            StoryFeedCollectionViewLinkCell *linkCell = (StoryFeedCollectionViewLinkCell *)cell;
            
            linkCell.linkLabel.attributedText = [[NSAttributedString alloc] initWithString:[[[NSURL URLWithString:story.videoLink] host] stringByReplacingOccurrencesOfString:@"www." withString:@""] attributes:@{NSFontAttributeName : linkCell.linkLabel.font, NSForegroundColorAttributeName : linkCell.linkLabel.textColor}];
        } break;
        case StoryTypeMultimedia: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"multimediaCell" forIndexPath:indexPath];
            StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
            multimediaCell.urlString = story.videoLink;
            multimediaCell.multimediaCellDelegate = self;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateCollectionView];
            });
            
        } break;
        case StoryTypeHardFacts: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hardFactsCell" forIndexPath:indexPath];
            StoryFeedCollectionViewHardFactsCell *hardFactsCell = (StoryFeedCollectionViewHardFactsCell *)cell;
            hardFactsCell.aboutLabel.text = company.about;

            hardFactsCell.separatorView.hidden = NO;
            hardFactsCell.leftItemContainer.hidden = NO;
            hardFactsCell.rightItemContainer.hidden = NO;
            
            if (company.industry && company.employees) {
                hardFactsCell.leftItemValueLabel.text = company.industry;
                hardFactsCell.leftItemTitleLabel.text = @"Industry";
                
                hardFactsCell.rightItemValueLabel.text = company.employees;
                hardFactsCell.rightItemTitleLabel.text = @"Employees";
            } else {
                NSMutableArray *items = [NSMutableArray new];
                if (company.industry) {
                    [items addObject:@{kTitleKey : @"Industry", kValueKey : company.industry}];
                }
                if (company.employees) {
                    [items addObject:@{kTitleKey : @"Employees", kValueKey : company.employees}];
                }
                if (company.founded) {
                    [items addObject:@{kTitleKey : @"Founded", kValueKey : company.founded}];
                }
                if (company.funding) {
                    [items addObject:@{kTitleKey : @"Funding", kValueKey : company.funding}];
                }
                if (company.headquarters) {
                    [items addObject:@{kTitleKey : @"Headquareters", kValueKey : company.headquarters}];
                }
                if (company.stage) {
                    [items addObject:@{kTitleKey : @"Stage", kValueKey : company.stage}];
                }
                if (items.count >= 2) {
                    hardFactsCell.leftItemTitleLabel.text = [items[0] objectForKey:kTitleKey];
                    hardFactsCell.leftItemValueLabel.text = [items[0] objectForKey:kValueKey];
                
                    hardFactsCell.rightItemTitleLabel.text = [items[1] objectForKey:kTitleKey];
                    hardFactsCell.rightItemValueLabel.text = [items[1] objectForKey:kValueKey];
                } else {
                    hardFactsCell.separatorView.hidden = YES;
                    hardFactsCell.leftItemContainer.hidden = YES;
                    hardFactsCell.rightItemContainer.hidden = YES;
                }
            }
        } break;
        case StoryTypeOfficePhotos: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"officesCell" forIndexPath:indexPath];
        } break;
    }

    [cell.shareButton setHidden:YES];
    cell.buttonsContainer.hidden = YES;
    
    for (UIView *view in cell.containerView.subviews) {
        if ([view isKindOfClass:[LinedTextView class]]) {
            [view removeFromSuperview];
        }
    }
//    cell.textView.text = story.storyTitle;
    CGFloat textViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds) * 0.95;
    CGFloat textViewHeight = CGRectGetWidth([UIScreen mainScreen].bounds) * 0.4;
    [LinedTextView textViewWithText:story.storyTitle maxWidth:textViewWidth maxHeight:textViewHeight completion:^(id result, NSError *error) {
        if (result) {
            LinedTextView *textView = result;
            [cell.containerView addSubview:textView];
        }
    }];
    
    if (story.storyType == StoryTypeMultimedia) {
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        [multimediaCell.backgroundImageView sd_setImageWithURL:story.videoThumbnailLink ? [NSURL URLWithString:story.videoThumbnailLink] : [NSURL URLWithString:@"http://www.wpclipart.com/computer/keyboard_keys/special_keys/computer_key_Delete.png"] completed:nil];
    }

    if (story.storyType == StoryTypeStory) {
        DejalActivityView *activityUView = [DejalWhiteActivityView activityViewForView:cell];
        [cell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityUView removeFromSuperview];
        }];
    }
    cell.delegate = self;
    cell.indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:collectionIndexPath.row];
    
    [cell.commentButton setTitle:[TTUtils stringForNumberReplacingThousands:story.commentsNum] forState:UIControlStateNormal];
    [self updateArrowsState];
    return cell;
}

- (NSAttributedString *)attributedStringForString:(NSString *)string highlight:(NSString *)highlight {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-Light" size:13]} range:NSMakeRange(0, attributedString.string.length)];
    [attributedString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-Semibold" size:13]} range:[attributedString.string rangeOfString:highlight]];
    
    return attributedString;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    StoryFeedCollectionViewCell *selectedCell = (StoryFeedCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self collectionViewCellClicked:selectedCell];
    [self cancelPlayingMultimediaCells:@[selectedCell]];
}

- (void)collectionViewCellClicked:(StoryFeedCollectionViewCell *)cell {
    DLog(@"Section %ld", cell.indexPath.section);
    DLog(@"Row %ld", cell.indexPath.row);
    Company *company = [self.dataContainer objectAtIndex:cell.indexPath.section];
    Story *story = [company.stories objectAtIndex:cell.indexPath.row];
    if ([Story isStoryTypeSnip:story]) {
        if (story.storyType == StoryTypeHardFacts) {
            [self presentCompanyDetailsForCompany:company item:MenuItemLookingFor];
        } else if (story.storyType == StoryTypeJoinCompanySnip) {
            [self openMail];
        }
        return;
    }
    
    [self presentStoryDetailsForCompany:[company copy] story:story comment:NO atIndex:[self indexPathForCollectionWithCompany:company indexPath:cell.indexPath].item row:[self rowDataClaculatedSnippet:[self.dataContainer copy] withRow:cell.indexPath.section]];
    
    /*
    switch (story.storyType) {
        case StoryTypeHardFacts: {
            [self presentCompanyDetailsForCompany:company item:MenuItemAbout];
        } break;
        case StoryTypeOfficePhotos: {
            [self presentCompanyDetailsForCompany:company item:MenuItemOurOffices];
        } break;
        case StoryTypeCreateProfile: {
            DataManager *dMgr = [DataManager sharedManager];
            if (![dMgr isCredentialsSavedInKeychain]) {
                [(TTTabBarController *)self.rdv_tabBarController setScheduledTabItem:TabItemCreateUserProfile];
                [dMgr showLoginScreen];
            } else if (dMgr.currentUser.isProfilePartiallyFilled) {
                [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
            } else {
                [(TTTabBarController *)self.rdv_tabBarController presentCreateUserProfileScreen];
            }
        } break;
        default:
        {
            [self presentStoryDetailsForCompany:[company copy] story:story comment:NO atIndex:[self indexPathForCollectionWithCompany:company indexPath:cell.indexPath].item row:[self isDataContainsSnippet:self.dataContainer withRow:cell.indexPath.section] ? cell.indexPath.section - 1 : cell.indexPath.section];
        } break;
    }
     */
}

-(void)collectionViewCellShouldClick:(StoryFeedCollectionViewCell *)cell
{
//    self.tableView.userInteractionEnabled = YES;
    [self collectionViewCellClicked:cell];
    
    TTDeeplinkManager *manager = DEEPLINK_MANAGER;
    [manager deallocDeeplinkManager];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *collectionIndexPath = [self.tableView indexPathForCell:[self cellForChildView:collectionView]];
    Company *company = [self.dataContainer objectAtIndex:collectionIndexPath.row];
    company.currentStoryShowIndex = indexPath.item;
    
//    Story *currentStory = company.stories[indexPath.item];
//    StoryFeedTableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:collectionIndexPath];
    
    if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]] && collectionIndexPath.row == 0 && !self.autoPlayed) {
        self.autoPlayed = YES;
        
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        self.currentMultimediaCell = multimediaCell;
        [multimediaCell cellWillAppear];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [multimediaCell setActive];
            [multimediaCell toggleVideo:YES];
        });
        
        [self videoControllersTimerActivate:YES];
        return;
    }
    
    //downloading new
    if (company.companyId && company.stories.count > 0 && indexPath.item == company.stories.count - 4) {
        [self collectionViewReachToEndXAxis:collectionView atIndex:collectionIndexPath.row];
    }
    [self updateArrowsState];
    
    if (![cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        return;
    }
    
    [(StoryFeedCollectionViewMultimediaCell *)cell cellWillAppear];
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    StoryFeedTableViewCell *tableViewCell = (StoryFeedTableViewCell *)cell.superview.superview.superview;
    //StoryFeedTableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:indexPath];
    __unused NSIndexPath *indexForTableCell = [self.tableView indexPathForCell:tableViewCell];
    
    if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        //StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        //[multimediaCell didEndDisplay];
    }
    [self updateArrowsState];
}

- (void)presentCompanyDetailsForCompany:(Company *)company item:(MenuItem)item {
    [[Mixpanel sharedInstance] track:kCompanyProfile properties:@{
                                                                  kScreenName : @"Feed",
                                                                  kCompany : company.companyName
                                                                  }];
    
    CompanyProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"companyProfileViewController"];
    controller.company = [company copy];
    controller.currentSelectedItem = item;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)presentStoryDetailsForCompany:(Company *)company story:(Story *)story comment:(BOOL)comment atIndex:(NSInteger)index row:(NSInteger)row {
    if (company.stories.count) {
        DetailsPageViewController *detailsPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsPageViewController"];
        company = [self companyWithoutHardFactStory:company];
        detailsPageViewController.company = company;
        detailsPageViewController.currentStory = story;
        detailsPageViewController.shouldOpenComment = comment;
        detailsPageViewController.startingIndex = index;
        detailsPageViewController.row = row;
        detailsPageViewController.canOpenCompanyDetails = YES;
        detailsPageViewController.delegate = self;
        [self.navigationController pushViewController:detailsPageViewController animated:YES];
    }
}

#pragma maek - DetailsPageViewController - 

- (void)updateStoriesArray:(NSArray *)storiesArray atRowIndex:(NSInteger)row {
    // mendy
}

- (void)collectionViewReachToEndXAxis:(UICollectionView *)collectionView atIndex:(NSInteger)row {
    Company *company = self.dataContainer[row];
    NSInteger calculatedRow = [self rowDataClaculatedSnippet:[self.dataContainer copy] withRow:row];
    [self updateStoriesListWithIndex:[self companyStoriesCountSubtractHardFact:company] atRow:calculatedRow completion:^(id result, NSError *error) {
        if ([result count] && !error) {
            Company *newCompanyForStories = result[0];
            // update data holder of more stories - self.dataContainer holds companies
            NSInteger lastCount = company.stories.count;
            NSMutableArray *newStories = [[NSMutableArray alloc] initWithArray:company.stories];
            [newStories addObjectsFromArray:newCompanyForStories.stories];
            company.stories = [newStories copy];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                for (NSInteger i = lastCount; i < company.stories.count; i++) {
                    [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                if (indexPathArray.count > 0) {
                    //[collectionView insertItemsAtIndexPaths:[indexPathArray copy]];
                    [collectionView reloadData];
                }
                
                // add arrow on collection
                [self updateArrowsState];
                
                //[collectionView reloadData];
            }];
        }
    }];
}

- (void)updateStoriesListWithIndex:(NSInteger)index atRow:(NSInteger)row completion:(SimpleResultBlock)completion {
    DLog(@"Index %ld", index);
    //DLog(@"Company Fetch:  %@", company.companyName);
    [[DataManager sharedManager] storyFeedIndexesForXAxis:index inRow:row maxCount:5 completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            DLog(@"Feed: First X ids %@", result);
            NSDictionary *params = @{@"ids" : result,
                                     @"size" : [GeneralMethods screenSizeDict]
                                     };
            
            [[DataManager sharedManager] storyFeedIndexesWithParams:nil forceReload:NO completionHandler:^(id result, NSError *error) {
                [[DataManager sharedManager] storiesByIds:params orderByIndexes:result completionHandler:^(id result, NSError *error) {
                    DLog(@"Company with Stories by ids on feed %@", result);
                    
                    // extract stories from result which contains Company
                    if (result && !error) {
                        NSMutableArray *urls = [NSMutableArray new];
                        for (Company *company in result) {
                            for (Story *story in company.stories) {
                                NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
                                NSURL *thumbnail = [NSURL URLWithString:story.videoThumbnailLink];
                                if (url) {
                                   // DLog(@"Downloading story image with URL %@", url);
                                    [urls addObject:url];
                                } else if (thumbnail) {
                                    [urls addObject:thumbnail];
                                }
                            }
                        }
                        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
                        if (completion) {
                            completion(result, error);
                        }
                    }     
                }];
            }];
        }
    }];
}

#pragma mark Hard Fact Handle Methods

- (NSArray *)updateFeedCompaniesWithHardFacts:(NSArray *)companies {
    for (Company *company in companies) {
        Story *hardFactStory = [[Story alloc] initWithDictionary:@{@"storyId" : @"0"}];
        hardFactStory.storyType = StoryTypeHardFacts;
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:company.stories];
        if (company.stories.count > 2) {
            [temp insertObject:hardFactStory atIndex:2];
        }
        company.stories = [temp copy];
    }
    
    return companies;
}

- (NSIndexPath *)indexPathForCollection:(NSIndexPath *)indexPath {
    if (indexPath.item >= 2) {
        return [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
    }
    return indexPath;
}

- (BOOL)isCompanyContainsHardFactCell:(Company *)company {
    for (Story *story in company.stories) {
        if (story.storyType == StoryTypeHardFacts) {
            return YES;
        }
    }
    return NO;
}

- (Company *)companyWithoutHardFactStory:(Company *)company {
    NSMutableArray *stories = [NSMutableArray new];
    for (Story *story in company.stories) {
        if ([Story isStoryTypeSnip:story]) {
            continue;
        }
        [stories addObject:story];
    }
    company.stories = [stories copy];
    return company;
}

- (NSInteger)companyStoriesCountSubtractHardFact:(Company *)company {
    return [self isCompanyContainsHardFactCell:company] ? company.stories.count - 1 : company.stories.count;
}

- (NSIndexPath *)indexPathForCollectionWithCompany:(Company *)company indexPath:(NSIndexPath *)indexPath {
    NSInteger newIndex = indexPath.item;
    if ([self isCompanyContainsHardFactCell:company] && indexPath.item > 2) {
        newIndex = indexPath.item - 1;
    }

    return [NSIndexPath indexPathForItem:newIndex inSection:indexPath.section];
}

#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.tableView]) {
        [self enableScrolling:NO]; // this is the line causes scroll issues (previously set "NO" before changed)
    }
    [self videoControllersTimerActivate:NO];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView]) {
        TTDeeplinkManager *manager = DEEPLINK_MANAGER;
        if ([manager.mode isEqualToString:ON_MODE]) {
            [manager performSelector:@selector(storyFeedTableViewScrollCompleted) withObject:nil afterDelay:0.7];
        }
    } else if ([scrollView isKindOfClass:[UICollectionView class]]) {
        [self updateContentOffsetDictFromView:(UICollectionView *)scrollView];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self startPlayingMultimediaItems];
    });
}

- (void)updateContentOffsetDictFromView:(UICollectionView *)collectionView {
    StoryFeedTableViewCell *storyCell = (StoryFeedTableViewCell *)[self cellForChildView:collectionView];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:storyCell];
    CGFloat horizontalOffset = storyCell.collectionView.contentOffset.x;
    self.contentOffsetDictionary[[@(indexPath.row) stringValue]] = @(horizontalOffset);
}

- (void)autoAdjustScrollToTop {
    // compare the top two visible rows to the current content offset
    // and auto scroll so that the best row is snapped to top
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    if (!visibleRows.count && visibleRows.count < 2) {
        return;
    }
    NSIndexPath *firstPath = visibleRows[0];
    NSIndexPath *secondPath = visibleRows[1];
    CGRect firstRowRect = [self.tableView rectForRowAtIndexPath:firstPath];
    [self.tableView scrollToRowAtIndexPath:(firstRowRect.origin.y >= self.tableView.contentOffset.y ? firstPath : secondPath) atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (![scrollView isEqual:self.tableView]) {
            [self enableScrolling:YES];
            [self updateContentOffsetDictFromView:(UICollectionView *)scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.tableView]) {
        [self enableScrolling:YES];
        [self updateContentOffsetDictFromView:(UICollectionView *)scrollView];
    }
    [[DataManager sharedManager] setScrolling:NO];
    // quick and dirty
    [self startPlayingMultimediaItems];
    
    NSNumber *userScrolled = [[NSUserDefaults standardUserDefaults] objectForKey:kUserScrolledSide];
    if ([userScrolled boolValue] == YES) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateCollectionView];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView]) {
        self.currentContentOffset = scrollView.contentOffset;
        BOOL enable = NO;
        [self enableCellSideScroll:[NSNumber numberWithBool:enable]];
    }

    self.currentMultimediaCell.repeat = NO;
    [[DataManager sharedManager] setScrolling:YES];
    [self.currentMultimediaCell didEndDisplay];
    [self.videoControllersView showVolumeGradientView:NO player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
 }

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    /*
    CGFloat targetY = (*targetContentOffset).y;
    CGPoint newOffset = *targetContentOffset;
//    CGFloat height = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    CGFloat height = self.view.frame.size.width;
    CGFloat scrollValue = height * 0.3f;
    
    // scrolling up
    if (scrollView.contentOffset.y > targetY) {
        newOffset = CGPointMake(0, self.currentContentOffset.y - height);
        if (newOffset.y < 0) {
            newOffset = CGPointZero;
        }
        *targetContentOffset = newOffset;
        return;
    }
    newOffset = CGPointMake(0, height + self.currentContentOffset.y);
    *targetContentOffset = newOffset;
    return;
     */
    
    if ([scrollView isEqual:self.tableView]) {
        CGFloat targetY = (*targetContentOffset).y;
        CGFloat rowHeight = self.view.frame.size.width;
        CGFloat scrollValue = rowHeight * 0.3f;
        CGPoint newOffset = *targetContentOffset;

        if (self.currentContentOffset.y > targetY) {
            //DLog(@"SCROLLING TO TOP");
            if (self.currentContentOffset.y - scrollValue > targetY) {
                newOffset = CGPointMake(0, (roundf(self.currentContentOffset.y / rowHeight) - (velocity.y > 2 ? 2 : 1)) * rowHeight);
                //DLog(@"SHOULD SCROLL TO PREV ITEM WITH OFFSET %f", newOffset.y);
                if (newOffset.y < 0) {
                    newOffset = CGPointZero;
                }
            } else {
                newOffset = CGPointMake(0, roundf(self.currentContentOffset.y / rowHeight) * rowHeight);
               // DLog(@"SHOULD RETURN TO CURRENT ITEM WITH OFFSET %f", newOffset.y);
            }
        }

        else if (self.currentContentOffset.y < targetY) {
           // DLog(@"SCROLLING TO BOTTOM");
            if (self.currentContentOffset.y + scrollValue < targetY) {
                newOffset = CGPointMake(0, (roundf(self.currentContentOffset.y / rowHeight) + (velocity.y > 2 ? 2 : 1)) * rowHeight);
                //DLog(@"SHOULD SCROLL TO NEXT ITEM WITH OFFSET %f", newOffset.y);
                if (newOffset.y > scrollView.contentSize.height - scrollView.frame.size.height + (scrollView.infiniteScrollingView.hidden ? 0.0f : scrollView.infiniteScrollingView.frame.size.height)) {
                    newOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height + (scrollView.infiniteScrollingView.hidden ? 0.0f : scrollView.infiniteScrollingView.frame.size.height));
                }
            } else {
                newOffset = CGPointMake(0, roundf(self.currentContentOffset.y / rowHeight) * rowHeight);
                //DLog(@"SHOULD RETURN TO CURRENT ITEM WITH OFFSET %f", newOffset.y);
            }
        }
        
        BOOL enable = YES;
        [self performSelector:@selector(enableCellSideScroll:) withObject:[NSNumber numberWithBool:enable] afterDelay:0.2];
        *targetContentOffset = newOffset;
        scrollView.decelerationRate = 10.0;
    } else if ([scrollView isKindOfClass:[UICollectionView class]] && scrollView.contentOffset.x > 0) {
        // user scrolled X axis so no need for x side animation
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserScrolledSide];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)enableCellSideScroll:(NSNumber *)enable {
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollingMode object:[NSNumber numberWithBool:[enable boolValue]] userInfo:nil];
}


#pragma mark StoryFeedTableViewCell delegate

- (void)willBeginDraggingOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self enableScrolling:NO];
}

- (void)willEndDraggingOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    /*NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableView reloadtRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }*/
    // [self enableScrolling:YES];
}

- (void)profileOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    self.vibedIndexPath = [self.tableView indexPathForCell:cell];
    [(TTTabBarController *)self.rdv_tabBarController presentCreateUserProfileScreenAnimated:YES];
}

- (void)signupOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    self.vibedIndexPath = [self.tableView indexPathForCell:cell];
    [[DataManager sharedManager] showLoginScreen];
}

- (void)didHideDragView {
    [self enableScrolling:YES];
}

- (void)hiringTappedOnCell:(StoryFeedTableViewCell *)cell {
    NSIndexPath *companyIndexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *storyIndexPath = [[cell.collectionView indexPathsForVisibleItems] firstObject];
    if (companyIndexPath && storyIndexPath) {
        Company *company = [self.dataContainer objectAtIndex:companyIndexPath.row];
        
        CompanyLookingForViewController *lookingForViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"companyLookingForViewController"];
        lookingForViewController.company = company;
        [self showViewController:lookingForViewController sender:self];
        
        [[Mixpanel sharedInstance] track:kOpenPositionsFromFeed properties:@{
                                                                kCompany : company.companyName
                                                                }];
    }
    
}

- (void)vibeOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell completion:(SimpleCompletionBlock)completion {
    NSIndexPath *companyIndexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *storyIndexPath = [[cell.collectionView indexPathsForVisibleItems] firstObject];
    if (companyIndexPath && storyIndexPath) {
        Company *company = [self.dataContainer objectAtIndex:companyIndexPath.row];
        Story *story = [company.stories objectAtIndex:storyIndexPath.row];
        [self likeStory:story inCompany:company completion:completion];
        //[self wannaWorkInCompany:company completion:completion];
    } else {
        if (completion) {
            completion(NO, nil);
        }
    }
}

- (void)wannaWorkInCompany:(Company *)company completion:(SimpleCompletionBlock)completion {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        [[DataManager sharedManager] wannaWorkInCompany:company wanna:YES completionHandler:^(BOOL success,NSError *error) {
            if (success && !error) {
                [company setWannaWork:YES];
            } else {
                if (error) {
                    [self showWannaWorkFailedAlert];
                }
            }
            loading = NO;
            if (completion) {
                completion(success, error);
            }
        }];
    }
}

- (void)likeStory:(Story *)story inCompany:(Company *)company completion:(SimpleCompletionBlock)completion {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        if (story.storyType == StoryTypeHardFacts) {
            [[DataManager sharedManager] wannaWorkInCompany:company wanna:YES completionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [story setUserLike:YES];
                    [company setWannaWork:YES];
                } else {
                    if (error) {
                        [self showWannaWorkFailedAlert];
                    }
                }
                loading = NO;
                if (completion) {
                    completion(success, error);
                }
            }];
            return;
        }
        [[DataManager sharedManager] likeStory:story like:YES completionHandler:^(BOOL success,NSError *error) {
            if (success && !error) {
                [story setUserLike:YES];
                [company setWannaWork:YES];
            } else {
                if (error) {
                    [self showWannaWorkFailedAlert];
                }
            }
            loading = NO;
            if (completion) {
                completion(success, error);
            }
        }];
    }
}

- (void)storyFeedCellShouldMoveToUserProfile:(StoryFeedTableViewCell *)cell {
    [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
}

- (void)leftButtonPressedOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    NSIndexPath *collectionIndexPath = [cell.collectionView indexPathsForVisibleItems].firstObject;
    if (collectionIndexPath.row > 0) {
        if ([cell.collectionView.visibleCells.firstObject isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
            StoryFeedCollectionViewMultimediaCell *multimediaCell = cell.collectionView.visibleCells.firstObject;
            [self cancelPlayingMultimediaCells:@[multimediaCell]];
            [multimediaCell didEndDisplay];
        }
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:collectionIndexPath.row - 1 inSection:collectionIndexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self.videoControllersView showVolumeGradientView:NO player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startPlayingMultimediaItems];
        });
    }
}

- (void)rightButtonPressedOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    NSIndexPath *collectionIndexPath = [cell.collectionView indexPathsForVisibleItems].firstObject;
    if (collectionIndexPath.row + 1 < [cell.collectionView numberOfItemsInSection:collectionIndexPath.section]) {
        if ([cell.collectionView.visibleCells.firstObject isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
            StoryFeedCollectionViewMultimediaCell *multimediaCell = cell.collectionView.visibleCells.firstObject;
            [self cancelPlayingMultimediaCells:@[multimediaCell]];
            [multimediaCell didEndDisplay];
        }
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:collectionIndexPath.row + 1 inSection:collectionIndexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self.videoControllersView showVolumeGradientView:NO player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startPlayingMultimediaItems];
        });
    }
}

- (NSArray *)companiesForVisibleCells {
    NSMutableArray *companies = [NSMutableArray new];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [companies addObject:self.dataContainer[indexPath.row]];
    }
    return [companies copy];
}

- (NSArray *)urlsForVisibleCells {
    NSMutableArray *firstLineUrls = [[NSMutableArray alloc] init];
    NSMutableArray *secondLineUrls = [[NSMutableArray alloc] init];
    NSInteger index = 0;

    for (StoryFeedTableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        switch (index) {
            case 0: {
                NSIndexPath *collectionIndexPath = [cell.collectionView indexPathForCell:[cell.collectionView visibleCells].firstObject];
                Company *firstCompany = self.dataContainer[indexPath.row];
                Story *mainStory = firstCompany.stories[collectionIndexPath.item];
                
                Story *nextStory;
                if (firstCompany.stories.count > collectionIndexPath.item + 1) {
                    nextStory = firstCompany.stories[collectionIndexPath.item + 1];
                }
                if (mainStory.videoLink) {
                    [firstLineUrls addObject:mainStory.videoLink];
                }
                if (nextStory.videoLink) {
                    [firstLineUrls addObject:nextStory.videoLink];
                }
            } break;
            case 1: {
                NSIndexPath *collectionIndexPath = [cell.collectionView indexPathForCell:[cell.collectionView visibleCells].firstObject];
                Company *bottomCompany = self.dataContainer[indexPath.row];
                Story *bottomStory = bottomCompany.stories[collectionIndexPath.item];
                if (bottomStory.videoLink) {
                    [secondLineUrls addObject:bottomStory.videoLink];
                }
            } break;
            default:
                break;
        }
        index++;
    }
    return @[firstLineUrls, secondLineUrls];
}

- (Story *)storyForCell:(StoryFeedTableViewCell *)cell {
    NSIndexPath *companyIndexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *storyIndexPath = [[cell.collectionView indexPathsForVisibleItems] firstObject];
    Story *story;
    if (companyIndexPath && storyIndexPath) {
        Company *company = [self.dataContainer objectAtIndex:companyIndexPath.row];
        story = [company.stories objectAtIndex:storyIndexPath.row];
    }
    return story;
}

#pragma mark - StoryFeedMultimediaCell Delegate

- (void)timeUpdated:(NSTimeInterval)time {
    //DLog(@"update time %f", time);
    if (time > 1.0 && ![DataManager sharedManager].isScrolling) {
        [self.videoControllersView showVolumeGradientView:YES player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
    }
}

#pragma mark - VideoControllersView Delegate

- (void)videoControllersDidSwiped {
    [self videoControllersTimerActivate:NO];
}

- (void)videoMuted:(BOOL)muted {
    [self muteVideo:muted];
}

- (void)videoPaused:(BOOL)paused {
    [self pauseVideo:paused];
}

- (void)appResignActive {
    [self pauseVideo:YES];
    [self.videoControllersView playButtonStatePlaying:NO];
}

- (void)appBecomeActive {
    [self pauseVideo:NO];
    [self.videoControllersView playButtonStatePlaying:YES];
}

- (void)shareVideo {
    StoryFeedCollectionViewMultimediaCell *cell = [self currentMultimediaCollectionCell];
    if (!cell) {
        return;
    }
    StoryFeedTableViewCell *tableCell = (StoryFeedTableViewCell *)[self cellForChildView:cell.superview];
    Story *story = [self storyForCell:tableCell];
    [[SocialManager sharedManager] shareStory:story controller:self completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            DLog(@"Shared");
        } else {
            DLog(@"Not Shared");
        }
    }];
}

- (void)showVideoController {
    static NSInteger time = 0;
    if (time < 3) {
        time++;
        __weak StoryFeedViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf showVideoController];
        });
        return;
    }
    time = 0;
    [self.videoControllersView showVolumeGradientView:YES player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
}

#pragma mark StortFeedCollectionViewCell delegate

- (void)commentButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell {
    /*if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if (![[DataManager sharedManager] isCVAvailable]) {
            [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
        } else {
            Company *company = [self.dataContainer objectAtIndex:cell.indexPath.section];
            [self presentStoryDetailsForCompany:company story:[company.stories objectAtIndex:cell.indexPath.row] comment:YES];
        }
    } else {
        [[DataManager sharedManager] showLoginScreen];
    }*/
}

- (void)shareButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        Company *company = [self.dataContainer objectAtIndex:cell.indexPath.section];
        Story *story = [company.stories objectAtIndex:cell.indexPath.row];
        [[SocialManager sharedManager] shareStory:story controller:self completionHandler:^(BOOL success, NSError *error) {
            if (success && !error) {
                DLog(@"Shared");
            } else {
                //[self showShareToFacebookFailedAlert];
            }
            loading = NO;
        }];
    }
}

- (void)openMail {
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setToRecipients:@[@"partners@talenttribe.me"]];
    [mailViewController setSubject:@"Join the TalentTribe Community"];
    [mailViewController setMessageBody:@"Name:\n\nPosition:\n\nCompany:\n\nE-mail:\n\nPhone:\n\nWebsite:" isHTML:NO];
    [self presentViewController:mailViewController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Interface actions

- (IBAction)showCompanyDetails:(id)sender {
    UITableViewCell *cell = [self cellForChildView:sender];
    if (cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Company *company = [self.dataContainer objectAtIndex:indexPath.row];
        if (![Story isStoryTypeSnip:company.stories.firstObject]) {
            [self presentCompanyDetailsForCompany:company item:MenuItemStories];
        }
    }
}

#pragma mark Alerts

- (void)showWannaWorkFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"It seems that you are interested in quite a few companies, that's very nice\r\nAnyway,It looks like you have reached your maximum daily quota.\r\nFeel free to continue looking for other companies, and tomorrow you will be able to express your interest in them" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
}

- (void)showShareToFacebookFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Share to faceobok failed" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Misc methods

- (UITableViewCell *)cellForChildView:(UIView *)childView {
    UIView *view = childView;
    while (view && (![view isKindOfClass:[UITableViewCell class]])) {
        view = view.superview;
    }
    UITableViewCell *cell = (UITableViewCell *)view;
    NSAssert([cell isKindOfClass:[UITableViewCell class]], @"");
    return cell;
}

- (UICollectionView *)collectionViewForChildView:(UIView *)childView {
    UIView *view = childView;
    while (view && (![view isKindOfClass:[UICollectionView class]])) {
        view = view.superview;
    }
    UICollectionView *collectionView = (UICollectionView *)view;
    NSAssert([collectionView isKindOfClass:[UICollectionView class]], @"");
    return collectionView;
}

- (void)createBarButtons {
    if (!self.selectedCategory) {
        UIImage *searchImage = [UIImage imageNamed:@"search_icon"];
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, searchImage.size.width, searchImage.size.height)];
        [searchButton setImage:searchImage forState:UIControlStateNormal];
        UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        self.navigationItem.rightBarButtonItems = @[searchBarItem];
    }
}

- (void)touchedStatusBar {
    //[self showNavBarAnimated:YES];
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [self.videoControllersView showVolumeGradientView:NO player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
    [self.currentMultimediaCell didEndDisplay];
}

- (void)enableScrolling:(BOOL)enable {
    //[self setScrollingEnabled:enable];
    if ([DataManager sharedManager].likeOpen) {
        [self.tableView setScrollEnabled:NO];
        [self scrollViewEnableScrolling:NO];
        return;
    }
    [self.tableView setScrollEnabled:enable];
    [self scrollViewEnableScrolling:enable];
}

- (void)scrollViewEnableScrolling:(BOOL)enable {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[StoryFeedTableViewCell class]]) {
            StoryFeedTableViewCell *tableCell = (StoryFeedTableViewCell *)cell;
            tableCell.collectionView.scrollEnabled = ![DataManager sharedManager].likeOpen;
            tableCell.collectionView.userInteractionEnabled = ![DataManager sharedManager].likeOpen;
        }
    }
}

- (void)setupConstraints {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    UIView * parent = mainWindow;
    UIView * child = self.loadingViewController.view;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(child)]];
    [parent layoutIfNeeded];
}

// should't be in use
- (BOOL)isDataContainsSnippet:(NSArray *)data withRow:(NSInteger)row {
    NSInteger snipIndex = 0;
    for (Company *company in data) {
        Story *story = company.stories.firstObject;
        if ([Story isStoryTypeSnip:story] && row > snipIndex) {
            return YES;
        }
        snipIndex++;
    }
    return NO;
}

- (NSInteger)rowDataClaculatedSnippet:(NSArray *)data withRow:(NSInteger)row {
    NSInteger snipIndex = row;
    NSInteger index = 0;
    for (Company *company in data) {
        Story *story = company.stories.firstObject;
        if ([Story isStoryTypeYSnip:story] && index <= row) {
            snipIndex--;
        }
        index++;
    }
    return snipIndex;
}

- (NSIndexPath *)indexPathSubtractSnipps:(NSIndexPath *)indexPath {
    NSInteger snipIndex = 0;
    for (Company *company in self.dataContainer) {
        Story *story = company.stories.firstObject;
        if ([Story isStoryTypeSnip:story] && indexPath.row > snipIndex) {
            return [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        }
        snipIndex++;
    }
    return indexPath;
}

- (void)cancelPlayingMultimediaItems {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[StoryFeedTableViewCell class]]) {
            StoryFeedTableViewCell *storyCell = (StoryFeedTableViewCell *)cell;
            [self cancelPlayingMultimediaCells:storyCell.collectionView.visibleCells];
        }
    }
}

- (void)startPlayingMultimediaItems {
    StoryFeedCollectionViewMultimediaCell *multimediaCellWithVideo = [self currentMultimediaCollectionCell];
    if (!multimediaCellWithVideo || !multimediaCellWithVideo.urlString) {
        [self cancelPlayingMultimediaItems];
        [self.videoControllersView setEnableVolumeObserver:NO];
        return;
    }
    [self.videoControllersView setEnableVolumeObserver:YES];
    [self videoControllersTimerActivate:YES];
    
    self.currentMultimediaCell = multimediaCellWithVideo;
    //DLog(@"Activating %@", multimediaCellWithVideo .urlString);
    //[multimediaCellWithVideo toggleVideo:YES];
    [multimediaCellWithVideo setActive];
}

- (void)togglePlay:(BOOL)play player:(AVPlayer *)player {
    if (play && player.rate == 0) {
        [player play];
        [self.videoControllersView playButtonStatePlaying:play];
        return;
    }
    
    if (!player && player.rate == 1) {
        [self.videoControllersView playButtonStatePlaying:play];
        [player pause];
    }
}

- (void)cancelPlayingMultimediaCells:(NSArray *)cells {
    for (UICollectionViewCell *cell in cells) {
        if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
            StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
            [multimediaCell toggleVideo:NO];
            [multimediaCell animateView:NO];
            multimediaCell.playButton.hidden = NO;
        }
    }
}

- (void)muteVideo:(BOOL)mute {
    StoryFeedCollectionViewMultimediaCell *multimediaCellWithVideo = [self currentMultimediaCollectionCell];
    [multimediaCellWithVideo muteVideo:mute];
}

- (void)pauseVideo:(BOOL)pause {
    StoryFeedCollectionViewMultimediaCell *multimediaCellWithVideo = [self currentMultimediaCollectionCell];
    [multimediaCellWithVideo toggleVideo:!pause];
}

- (StoryFeedCollectionViewMultimediaCell *)currentMultimediaCollectionCell {
    if (self.tableView.contentOffset.y < 0) {
        return nil;
    }
    StoryFeedCollectionViewMultimediaCell *multimediaCellWithVideo;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[StoryFeedTableViewCell class]]) {
            StoryFeedTableViewCell *storyCell = (StoryFeedTableViewCell *)cell;
            for (UICollectionViewCell *collectionCell in storyCell.collectionView.visibleCells) {
                if ([collectionCell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
                    if (!CGRectContainsPoint(storyCell.collectionView.slk_visibleRect, collectionCell.center)) {
                        continue;
                    }
                    multimediaCellWithVideo = (StoryFeedCollectionViewMultimediaCell *)collectionCell;
                    break;
                }
            }
        }
        break;
    }
    return multimediaCellWithVideo;
    
    /*
     if (!multimediaCellWithVideo) {
     multimediaCellWithVideo = (StoryFeedCollectionViewMultimediaCell *)collectionCell;
     continue;
     }
     if (CGRectGetMinX(collectionCell.frame) <= CGRectGetMinX(multimediaCellWithVideo.frame) || CGRectGetMinY(collectionCell.frame) <= CGRectGetMinY(multimediaCellWithVideo.frame)) {
     multimediaCellWithVideo = (StoryFeedCollectionViewMultimediaCell *)collectionCell;
     }
     */
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchedStatusBar) name:kTouchedStatusBar object:nil];
    
    //[self reloadData];
    
    if (!self.selectedCategory) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    } else {
        [self.navigationItem setTitle:self.selectedCategory.categoryName];
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    //[self followScrollView:self.tableView usingTopConstraint:self.topLayoutConstraint];
    //[self setOverlayColor:UIColorFromRGB(0x28beff)];
    
    //[self showNavBarAnimated:NO];
    [self enableScrolling:YES];
    if (self.currentMultimediaCell) {
        [self.currentMultimediaCell toggleVideo:YES];
    }
    
    [VideoControllersView videoControllersViewWithCompletion:^(id result, NSError *error) {
        if (!self.videoControllersView) {
            self.videoControllersView = result;
            [DataManager sharedManager].videoController = self.videoControllersView;
            self.videoControllersView.statusBarView = self.statusBarBackgroundView;
            self.videoControllersView.delegate = self;
            [self.rootNavigationController.view addSubview:self.videoControllersView];
        }
    }];
}

-(void)handleDeeplink
{
    TTDeeplinkManager *manager = DEEPLINK_MANAGER;
    [manager startWithAlert:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self disableVideoControllers];
    if (self.selectedCategory) {
        [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeStoryFeed];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentMultimediaCell toggleVideo:NO];
    //[self.currentMultimediaCell removeObserver:self.currentMultimediaCell.currentPlayer.currentItem];
}

- (void)disableVideoControllers {
    if (self.repeatControllersBlock) {
        dispatch_cancel(self.repeatControllersBlock);
        self.repeatControllersBlock = nil;
    }
    [self.videoControllersView setEnableVolumeObserver:NO];
    [self.videoControllersView showVolumeGradientView:NO player:[self currentMultimediaCollectionCell].currentPlayer completion:nil];
    self.videoControllersView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self createBarButtons];
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:[[DataManager sharedManager] silentLogin] ? @"loadingViewController" : @"feedLoadingViewController"];
    
    if (!self.selectedCategory) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        [mainWindow addSubview:self.loadingViewController.view];
        [self setupConstraints];
    }
    
    /*if (self.selectedCategory) {
        [self.navigationItem setTitle:self.selectedCategory.categoryName];
    } else {
        [self.navigationItem setTitle:@"TalentTribe"];
    }*/
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
//    self.tableView.pagingEnabled = YES;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        //[self loadPage:self.currentPage + 1];
    }];
    
    self.refresh = [[UIRefreshControl alloc] initWithFrame:self.tableView.frame];
    [self.refresh addTarget:self action:@selector(refreshFeed:) forControlEvents:UIControlEventAllEvents];
    self.tableView.backgroundView = self.refresh;
    
    [self.view setMultipleTouchEnabled:YES];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:@"applicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:@"applicationDidBecomeActive" object:nil];
#ifdef DEBUG
    [self initiateDotIndicator];
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerIndicator) userInfo:nil repeats:YES];
    }
    [self.timer fire];
#endif
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DLog(@"TOUCH BEGAN");
}

- (void)dealloc {
    [self cancelPlayingMultimediaItems];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeStoryFeed];
    [[SDWebImagePrefetcher sharedImagePrefetcher] cancelPrefetching];
}

- (void)videoControllersTimerActivate:(BOOL)activate {
    if (activate) {
        //[self showVideoController];
        return;
    }
}

- (void)initiateDotIndicator {
    self.dot = [[UIView alloc] init];
    self.dot.layer.cornerRadius = 5/2;
}

- (void)timerIndicator {
    CGFloat dotSize = 5;
    self.dot.backgroundColor = [DataManager sharedManager].isCredentialsSavedInKeychain ? [UIColor greenColor] : [UIColor redColor];
    [self.view.window addSubview:self.dot];
    self.dot.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - dotSize, CGRectGetHeight([UIScreen mainScreen].bounds) - dotSize, dotSize, dotSize);
    
    self.dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.dot.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end
