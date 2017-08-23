//
//  UserProfileTabStoriesViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileTabStoriesViewController.h"
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
#import "CreateStoryViewController.h"

typedef enum {
    SectionItemStories,
    sectionItemsCount
} SectionItem;

@interface UserProfileTabStoriesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, StoryFeedCollectionViewCellDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *emptyContainer;

@property (nonatomic, strong) NSMutableArray *storiesContainer;

@property NSInteger currentPage;

@end

@implementation UserProfileTabStoriesViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.currentPage = 0;
        self.storiesContainer = [NSMutableArray new];
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        @synchronized(self) {
            if (!self.storiesContainer.count) {
                [self loadPage:self.currentPage];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        }
    }
}

- (void)loadPage:(NSInteger)page {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        [[DataManager sharedManager] userFeedForPage:page count:USERFEED_DEFAULT_PAGE_SIZE completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                NSArray *resultArray = result;
                if (resultArray.count > 0) {
                    self.currentPage = page + 1;
                }
                [self.storiesContainer addObjectsFromArray:result];
                if (self.storiesContainer.count == 0) {
                    [self.collectionView setHidden:YES];
                    [self.emptyContainer setHidden:NO];
                } else {
                    [self.collectionView setHidden:NO];
                    [self.emptyContainer setHidden:YES];
                    [self.collectionView reloadData];
                }
            } else {
                if (error) {
                    [TTUtils showAlertWithText:@"Unable to load at the moment"];
                }
            }
            [[self.collectionView infiniteScrollingView] stopAnimating];
            loading = NO;
        }];
    }
}

#pragma mark Interface actions

- (IBAction)createStoryButtonPressed:(id)sender {
    [(TTTabBarController *)self.rdv_tabBarController moveToCreateStoryTab];
}

#pragma mark UICollectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sectionItemsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemStories: {
            return self.storiesContainer.count;
        } break;
        default: {
            return 0;
        } break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Story *story = [self.storiesContainer objectAtIndex:indexPath.row];
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
            
            [questionCell setIndex:indexPath.row];
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
            //authorString = [NSString stringWithFormat:@"by %@", story.author.fullName];
        } break;
        default: {
            
        } break;
    }
    
    cell.editContainer.hidden = NO;
    cell.titleBottomConstraint.constant = -50.0f;
    cell.delegate = self;
    [cell layoutIfNeeded];
    
    cell.buttonsContainer.hidden = YES;
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

    
    if (story.storyType == StoryTypeMultimedia) {
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        [multimediaCell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:story.videoThumbnailLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            multimediaCell.backgroundImageView.image = image;
        }];
    }
    
    if (story.storyType != StoryTypeQuestion && story.storyType != StoryTypeMultimedia) {
        DejalActivityView *activityUView = [DejalWhiteActivityView activityViewForView:cell];
        [cell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityUView removeFromSuperview];
        }];
    }
    
    return cell;
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
        case SectionItemStories: {
            Story *story = self.storiesContainer[indexPath.item];
            [self presentStoryDetailsForCompany:[DataManager sharedManager].currentUser.company story:story comment:NO indexPath:indexPath];
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
    StoryFeedTableViewCell *tableViewCell = (StoryFeedTableViewCell *)cell.superview.superview.superview;
    __unused NSIndexPath *indexForTableCell = [self.tableView indexPathForCell:tableViewCell];
    
    if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        [multimediaCell didEndDisplay];
    }
}

- (void)presentStoryDetailsForCompany:(Company *)company story:(Story *)story comment:(BOOL)comment indexPath:(NSIndexPath *)indexPath {
    if (story.storyId) {
        DLog(@"Storyboard %@", self.storyboard);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StoryDetailsViewController *storyController = [storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
        storyController.currentStory = story;
        storyController.company = company;
        storyController.storyDetailsControllerType = StoryDetailsTypeViewController;
        storyController.openedByDeeplink = NO;
        storyController.shouldOpenComment = NO;
        storyController.shouldDownloadStory = YES;
        storyController.canOpenCompanyDetails = NO;
        [self.navigationController pushViewController:storyController animated:YES];
    }
}

#pragma mark TT Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.collectionView;
}

#pragma mark Playing control

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DLog(@"scrollViewDidEndDecelerating");
    [self startPlayingMultimediaItem];
}

- (void)cancelPlayingMultimediaItems {
    [self cancelPlayingMultimediaCells:self.collectionView.visibleCells];
}

- (void)startPlayingMultimediaItem  {
    StoryFeedCollectionViewMultimediaCell *multimediaCellWithVideo;
    
    NSArray *sortedCellsArray = [self.collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *obj1, UICollectionViewCell *obj2) {
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

- (void)cancelPlayingMultimediaCells:(NSArray *)cells {
    for (UICollectionViewCell *cell in cells) {
        if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
            DLog(@"STOPPING PLAYING ITEM %@", cell);
            StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
            [multimediaCell pause];
        }
    }
}

#pragma mark - StoryFeedCollectionViewCell Delegate

- (void)editButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell {
    Story *story = [self.storiesContainer objectAtIndex:cell.indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CreateViewController *createStory = [storyboard instantiateViewControllerWithIdentifier:@"createViewController"];
    createStory.storyIdToLoad = story.storyId;
    [self presentViewController:createStory animated:YES completion:nil];
}

- (void)deleteButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell {
    __block Story *story = [self.storiesContainer objectAtIndex:cell.indexPath.row];
    [[TTUtils sharedUtils] showAlertWithTitle:nil andText:@"You are about to delete this story, are you sure?" otherButton:@"Delete" withCompletion:^(BOOL success, NSError *error) {
        if (success && !error) {
            [[DataManager sharedManager] removeStory:story completionHandler:^(BOOL success, NSError *error) {
                if (!error && success) {
                    // reload data
                    [self.storiesContainer removeObject:story];
                    [self reloadData];
                } else {
                    [TTUtils showAlertWithText:@"Unable to delete story at the moment :("];
                }
            }];
        } 
    }];
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyStories];
    [self cancelPlayingMultimediaItems];
    
    [self.storiesContainer removeAllObjects];
    self.currentPage = 0;
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
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [self loadPage:self.currentPage];
    }];
}

- (void)dealloc {
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyStories];
    [self cancelPlayingMultimediaItems];
}

@end
