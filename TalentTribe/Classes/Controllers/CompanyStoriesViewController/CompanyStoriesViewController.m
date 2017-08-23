//
//  CompanyStoriesViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyStoriesViewController.h"
#import "DataManager.h"
#import "StoryFeedCollectionViewCell.h"
#import "StoryFeedCollectionViewStoryCell.h"
#import "StoryFeedCollectionViewQuestionCell.h"
#import "StoryFeedCollectionViewMultimediaCell.h"
#import "StoryFeedCollectionViewLinkCell.h"
#import "CompanyStoriesAskCollectionViewCell.h"
#import "StoryDetailsViewController.h"
#import "Story.h"
#import "SVPullToRefresh.h"
#import "DejalActivityView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SocialManager.h"
#import "CreateViewController.h"
#import "TTTabBarController.h"
#import "User.h"
#import "AsyncVideoDisplay.h"
#import "DetailsPageViewController.h"
#import <SDWebImage/SDWebImagePrefetcher.h>

typedef enum {
    SectionItemQuestion,
    SectionItemStories,
    sectionItemsCount
} SectionItem;

@interface CompanyStoriesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, StoryFeedCollectionViewCellDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSInteger currentPage;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation CompanyStoriesViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    self.currentPage = self.company.currentFeedPage;
    if (!self.company.storiesFeed.count) {
        [self loadPage:self.currentPage];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)loadPage:(NSInteger)page {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [[DataManager sharedManager] companyFeedForCompany:self.company page:page count:COMPANYFEED_DEFAULT_PAGE_SIZE completionHandler:^(id result, NSError *error) {
                if (result && !error) {
                    self.currentPage = page;
                    NSMutableArray *filteredStories = [NSMutableArray new];
                    for (Story *story in result) {
                        if (story.storyType != StoryTypeHardFacts && story.storyType != StoryTypeOfficePhotos) {
                            [filteredStories addObject:story];
                        }
                    }
                    if (filteredStories) {
                        self.company.storiesFeed = [[NSMutableArray alloc] initWithArray:filteredStories];
                    }
                    
                    NSMutableArray *urls = [NSMutableArray new];
                    for (Story *story in self.company.storiesFeed) {
                        NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
                        NSURL *thumbnail = [NSURL URLWithString:story.videoThumbnailLink];
                        if (url) {
                            DLog(@"Downloading story image with URL %@", url);
                            [urls addObject:url];
                        } else if (thumbnail) {
                            [urls addObject:thumbnail];
                        }
                    }
                                        
                    [urls addObject:@"http://goo.gl/Y4LXh1"]; // remove image
                    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
                    [self.collectionView reloadData];
                    [self.tableView reloadData];
                } else {
                    //handle error
                }
                [[self.collectionView infiniteScrollingView] stopAnimating];
                loading = NO;
            }];
        }
    }
}

#pragma mark Interface actions

- (IBAction)askQuestionButtonPressed:(id)sender {
    [self handleAskQuestion];
}

#pragma mark UICollectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sectionItemsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemQuestion: {
            return 0;
        } break;
        case SectionItemStories: {
            return self.company.storiesFeed.count;
        } break;
        default: {
            return 0;
        } break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemQuestion: {
            CompanyStoriesAskCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"askCell" forIndexPath:indexPath];
            [cell.gradientButton setTitle:[NSString stringWithFormat:@"Ask %@ a question", self.company.companyName] forState:UIControlStateNormal];
            return cell;
        } break;
        case SectionItemStories: {
            Story *story = [self.company.storiesFeed objectAtIndex:indexPath.row];
            Company *company = self.company;
            StoryFeedCollectionViewCell *cell;
            
            //NSString *authorString;
            switch (story.storyType) {
                case StoryTypeStory: {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"storyCell" forIndexPath:indexPath];
                    StoryFeedCollectionViewCell *storyCell = cell;
                    storyCell.headerContainer.alpha = 0.0;
                    //authorString = [NSString stringWithFormat:@"%@", story.author.fullName];
                } break;
                case StoryTypeQuestion: {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"questionCell" forIndexPath:indexPath];
                    StoryFeedCollectionViewQuestionCell *questionCell = (StoryFeedCollectionViewQuestionCell *)cell;
                    //authorString = [NSString stringWithFormat:@"%@ asks:", story.author.fullName];
                    
                    [questionCell setIndex:[company indexOfStoryByType:story]];
                    questionCell.questionAnswersLabel.hidden = story.commentsNum <= 0;
                    
                    if (story.commentsNum > 0) {
                        questionCell.questionAnswersLabel.attributedText = [self attributedStringForString:[NSString stringWithFormat:@"%ld people answered", (long)story.commentsNum] highlight:[NSString stringWithFormat:@"%ld", (long)story.commentsNum]];
                    } else {
                        questionCell.readMoreLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Be the first to answer »" attributes:@{NSFontAttributeName : questionCell.readMoreLabel.font, NSForegroundColorAttributeName : questionCell.readMoreLabel.textColor}];
                    }
                } break;
                case StoryTypeLink: {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"linkCell" forIndexPath:indexPath];
                    StoryFeedCollectionViewLinkCell *linkCell = (StoryFeedCollectionViewLinkCell *)cell;
                    
                    //authorString = [NSString stringWithFormat:@"%@ posted a link:", story.author.fullName];
                    linkCell.linkLabel.attributedText = [[NSAttributedString alloc] initWithString:[[[NSURL URLWithString:story.videoLink] host] stringByReplacingOccurrencesOfString:@"www." withString:@""] attributes:@{NSFontAttributeName : linkCell.linkLabel.font, NSForegroundColorAttributeName : linkCell.linkLabel.textColor}];
                } break;
                case StoryTypeMultimedia: {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"multimediaCell" forIndexPath:indexPath];
                    StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
                    multimediaCell.headerContainer.alpha = 0.0;
                    multimediaCell.urlString = story.videoLink;
                    cell.indexPath = indexPath;
                } break;
                default: {
                    
                } break;
            }
            
            cell.titleLabel.shadowEnabled = story.storyType != StoryTypeQuestion;
            cell.textView.text = story.storyTitle;
            
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

            if (story.storyType != StoryTypeQuestion && story.storyType != StoryTypeMultimedia) {
                DejalActivityView *activityUView = [DejalWhiteActivityView activityViewForView:cell];
                [cell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [activityUView removeFromSuperview];
                }];
            }
            
            if (story.storyType == StoryTypeMultimedia) {
                StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
                [multimediaCell.backgroundImageView sd_setImageWithURL:story.videoThumbnailLink ? [NSURL URLWithString:story.videoThumbnailLink] : [NSURL URLWithString:@"http://www.clker.com/cliparts/B/u/J/E/o/f/red-delete-square-button-md.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    multimediaCell.backgroundImageView.image = image;
                }];
            }
            
            //cell.authorContainer.hidden = story.author ? NO : YES;
            /*if (authorString && story.author.fullName) {
             cell.authorLabel.attributedText = [self attributedStringForString:authorString highlight:story.author.fullName];
             }
             
             if (story.author.profileImageLink) {
             [cell.authorImageView sd_setImageWithURL:[NSURL URLWithString:story.author.profileImageLink] placeholderImage:[UIImage imageNamed:@"user_avatar"]];
             } else {
             cell.authorImageView.image = [UIImage imageNamed:@"user_avatar"];
             }*/
            
            cell.delegate = self;
            [cell.commentButton setTitle:[TTUtils stringForNumberReplacingThousands:story.commentsNum] forState:UIControlStateNormal];
            
            return cell;
        } break;
        default: {
            return nil;
        } break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DLog(@"scrollViewDidEndDecelerating");
    [self startPlayingMultimediaItem];
}

- (NSAttributedString *)attributedStringForString:(NSString *)string highlight:(NSString *)highlight {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-Light" size:13]} range:NSMakeRange(0, attributedString.string.length)];
    [attributedString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-Semibold" size:13]} range:[attributedString.string rangeOfString:highlight]];
    
    return attributedString;
}

#pragma mark UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemQuestion: {
            return CGSizeMake(self.view.bounds.size.width, [CompanyStoriesAskCollectionViewCell height]);
        } break;
        case SectionItemStories: {
            return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
        } break;
        default: {
            return CGSizeZero;
        } break;
    }
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemQuestion: {
            [self handleAskQuestion];
        } break;
        case SectionItemStories: {
            [self presentStoryDetailsForCompany:self.company story:[self.company.storiesFeed objectAtIndex:indexPath.row] comment:NO indexPath:indexPath];
        } break;
        default: {
        } break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        return;
    }
    StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
    [multimediaCell cellWillAppear];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        [multimediaCell didEndDisplay];
    }
}

- (void)handleAskQuestion {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        User *currentUser = [[DataManager sharedManager] currentUser];
        TTTabBarController *tabController = (TTTabBarController *)self.rdv_tabBarController;
        if (currentUser.isProfileFilled) {
            [self presentAskQuestionViewForCompany:self.company];
        } else if (currentUser.isProfilePartiallyFilled) {
            [tabController moveToTabItem:TabItemUserProfile];
        } else {
            [tabController presentCreateUserProfileScreen];
        }
    } else {
        [[DataManager sharedManager] showLoginScreen];
    }
}

- (void)presentAskQuestionViewForCompany:(Company *)company {
    CreateViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewController"];
    controller.selectedCompany = company;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
}

- (void)presentStoryDetailsForCompany:(Company *)company story:(Story *)story comment:(BOOL)comment indexPath:(NSIndexPath *)indexPath {
    StoryDetailsViewController *storyController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
    storyController.currentStory = story;
    storyController.company = company;
    storyController.storyDetailsControllerType = StoryDetailsTypeViewController;
    storyController.openedByDeeplink = NO;
    storyController.shouldOpenComment = NO;
    storyController.shouldDownloadStory = YES;
    storyController.canOpenCompanyDetails = NO;
    [self.navigationController pushViewController:storyController animated:YES];
}

- (void)startPlayingMultimediaItem  {
    StoryFeedCollectionViewMultimediaCell *multimediaCellWithVideo;

    NSArray *sortedCellsArray = [[self.collectionView.visibleCells copy] sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *obj1, UICollectionViewCell *obj2) {
        if (obj1.frame.origin.y < obj2.frame.origin.y) {
            return NSOrderedAscending;
        } else if (obj1.frame.origin.y > obj2.frame.origin.y) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];

    if ([sortedCellsArray.firstObject isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        multimediaCellWithVideo = sortedCellsArray.firstObject;
    }
    if (!multimediaCellWithVideo || !multimediaCellWithVideo.urlString) {
        return;
    }
    [multimediaCellWithVideo playing:NO];
    //self.pendingCell = multimediaCellWithVideo;
    
    [multimediaCellWithVideo toggleVideo:YES];
    [multimediaCellWithVideo setActive];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self cancelPlayingMultimediaItems];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.company.storiesFeed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    return cell;
}

#pragma mark StortFeedCollectionViewCell delegate

- (void)commentButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell {
    /*if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
     if (![[DataManager sharedManager] isCVAvailable]) {
     [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
     } else {
     NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
     [self presentStoryDetailsForCompany:self.company story:[self.company.storiesFeed objectAtIndex:indexPath.row] comment:YES];
     }
     } else {
     [[DataManager sharedManager] showLoginScreen];
     }*/
}

- (void)shareButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        Story *story = [self.company.storiesFeed objectAtIndex:indexPath.row];
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

#pragma mark Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.collectionView;
}

#pragma mark - UITableView



#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyStories];
    [self cancelPlayingMultimediaItems];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewStoryCell" bundle:nil] forCellWithReuseIdentifier:@"storyCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewQuestionCell" bundle:nil] forCellWithReuseIdentifier:@"questionCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewLinkCell" bundle:nil] forCellWithReuseIdentifier:@"linkCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewMultimediaCell" bundle:nil] forCellWithReuseIdentifier:@"multimediaCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCreateUserProfileCell" bundle:nil] forCellWithReuseIdentifier:@"vibeCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedJoinCompanyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"joinCompanyCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedPrivacyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"privacyCell"];
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [self loadPage:self.currentPage + 1];
    }];
}

- (void)dealloc {
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyStories];
    [self cancelPlayingMultimediaItems];
}

@end
