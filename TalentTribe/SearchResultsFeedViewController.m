//
//  SearchResultsFeedViewController.m
//  TalentTribe
//
//  Created by Mendy on 23/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "SearchResultsFeedViewController.h"
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
#import "StoryCategory.h"
#import "TTDragVibeView.h"
#import "JTMaterialSpinner.h"
#import "VideoControllersView.h"

typedef enum {
    SectionItemQuestion,
    SectionItemStories,
    sectionItemsCount
} SectionItem;

@interface SearchResultsFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, StoryFeedCollectionViewCellDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, VideoControllersViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *companies;
@property (nonatomic, weak) IBOutlet JTMaterialSpinner *spinnerView;
@property (nonatomic, strong) StoryFeedCollectionViewMultimediaCell *pendingCell;
@property (nonatomic) CGPoint currentContentOffset;
@property (nonatomic, strong) VideoControllersView *videoControllersView;
@end


@implementation SearchResultsFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewStoryCell" bundle:nil] forCellWithReuseIdentifier:@"storyCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewQuestionCell" bundle:nil] forCellWithReuseIdentifier:@"questionCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewLinkCell" bundle:nil] forCellWithReuseIdentifier:@"linkCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewMultimediaCell" bundle:nil] forCellWithReuseIdentifier:@"multimediaCell"];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationItem setTitle:self.selectedCategory.categoryName];
    
    self.spinnerView.circleLayer.lineWidth = 3.0;
    self.spinnerView.circleLayer.strokeColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0].CGColor;
    [self.spinnerView beginRefreshing];
    self.collectionView.hidden = YES;
    [[DataManager sharedManager] storyFeedForCategory:self.selectedCategory companyId:nil completionHandler:^(id result, NSError *error) {
        DLog(@"Result %@", result);
        self.dataSource = [[NSMutableArray alloc] initWithArray:[result valueForKeyOrNil:@"Stories"]];
        self.companies = [[NSMutableArray alloc] initWithArray:[result valueForKeyOrNil:@"Companies"]];
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView endRefreshing];
            self.collectionView.hidden = NO;
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [VideoControllersView videoControllersViewWithCompletion:^(id result, NSError *error) {
        if (!self.videoControllersView) {
            self.videoControllersView = result;
            self.videoControllersView.statusBarView = self.navigationController.navigationBar;
            self.videoControllersView.delegate = self;
            [self.videoControllersView setEnableVolumeObserver:YES];
            //[self.rootNavigationController.view addSubview:self.videoControllersView];
            //[self.view.window.rootViewController.view addSubview:self.videoControllersView];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self cancelPlayingMultimediaCells:self.collectionView.visibleCells];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    return cell;
}

#pragma marl - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.dataSource[indexPath.row];
    Company *company = [self companyForCompanyId:story.companyId];
    StoryFeedCollectionViewCell *cell;

    switch (story.storyType) {
        case StoryTypeStory: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"storyCell" forIndexPath:indexPath];
            //authorString = [NSString stringWithFormat:@"%@", story.author.fullName];
        } break;
        case StoryTypeMultimedia: {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"multimediaCell" forIndexPath:indexPath];
            StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
            multimediaCell.urlString = story.videoLink;
            cell.indexPath = indexPath;
        } break;
        default: {
            
        } break;
    }
    
    cell.company = company;
    cell.delegate = self;
    [cell.dragVibeView setCurrentCompany:company];
    [cell setHeaderEnable:YES];
    [cell setUserVibedStory:story.userLike];
    
    cell.titleLabel.shadowEnabled = story.storyType != StoryTypeQuestion;
    [cell.companyImageView sd_setImageWithURL:[NSURL URLWithString:story.companyLogo]];
    cell.companyTitle.attributedText = [TTUtils attributedCompanyName:company.companyName industry:company.industry];
    
    for (UIView *view in cell.containerView.subviews) {
        if ([view isKindOfClass:[LinedTextView class]]) {
            [view removeFromSuperview];
        }
    }

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
    cell.delegate = self;
    [cell.commentButton setTitle:[TTUtils stringForNumberReplacingThousands:story.commentsNum] forState:UIControlStateNormal];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.dataSource[indexPath.row];
    Company *company = [self companyForCompanyId:story.companyId];
    DLog(@"Company :%@", company.companyName);
    DLog(@"Story Title :%@", story.storyTitle);
    if (story.storyType == StoryTypeMultimedia) {
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        [multimediaCell.backgroundImageView sd_setImageWithURL:story.videoThumbnailLink ? [NSURL URLWithString:story.videoThumbnailLink] : [NSURL URLWithString:@"http://www.clker.com/cliparts/B/u/J/E/o/f/red-delete-square-button-md.png"]];
        [multimediaCell cellWillAppear];
    }
}

#pragma mark UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.dataSource[indexPath.item];
    [self presentStoryDetailsForCompany:[self companyForCompanyId:story.companyId] story:story comment:NO indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.dataSource[indexPath.item];
    StoryFeedCollectionViewCell *storyCell = (StoryFeedCollectionViewCell *)cell;
    [storyCell setUserVibedStory:story.userLike];
    
    if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        [multimediaCell didEndDisplay];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startPlayingMultimediaItems];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.currentContentOffset = scrollView.contentOffset;
    [self cancelPlayingMultimediaCells:self.collectionView.visibleCells];
}

- (void)cancelPlayingMultimediaCells:(NSArray *)cells {
    for (UICollectionViewCell *cell in cells) {
        if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
            StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
            [multimediaCell didEndDisplay];
        }
    }
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
    
    if ([scrollView isEqual:self.collectionView]) {
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
        *targetContentOffset = newOffset;
        scrollView.decelerationRate = 10.0;
    }
}

- (void)presentStoryDetailsForCompany:(Company *)company story:(Story *)story comment:(BOOL)comment indexPath:(NSIndexPath *)indexPath {
    if (story.storyId) {
        StoryDetailsViewController *storyController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
        storyController.currentStory = story;
        storyController.company = [self companyForCompanyId:story.storyId];
        storyController.storyDetailsControllerType = StoryDetailsTypeViewController;
        storyController.openedByDeeplink = NO;
        storyController.shouldOpenComment = NO;
        storyController.shouldDownloadStory = YES;
        storyController.canOpenCompanyDetails = NO;
        [self.navigationController pushViewController:storyController animated:YES];
    }
}

- (Company *)companyForCompanyId:(NSString *)companyID {
    for (Company *company in [self.companies copy]) {
        if (![company.companyId isEqualToString:companyID]) {
            continue;
        }
        return company;
    }
    return nil;
}

- (void)startPlayingMultimediaItems {
    StoryFeedCollectionViewMultimediaCell *multimediaCell;
    
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
        multimediaCell = sortedCellsArray.firstObject;
    }
    
    if (!multimediaCell || !multimediaCell.urlString) {
        return;
    }
    [multimediaCell toggleVideo:YES];
    [multimediaCell setActive];
}

#pragma mark - VideoControllersView Delegate 

- (void)videoControllersDidSwiped {

}

- (void)videoMuted:(BOOL)muted {

}

- (void)videoPaused:(BOOL)paused {

}

- (void)shareVideo {

}

#pragma mark - StoryFeedCollectionViewCell Delegate

- (void)willBeginDraggingOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell {
    [self enableScrolling:NO];
}

- (void)willEndDraggingOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell {
    /*NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
     if (indexPath) {
     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
     }*/
    //    [self enableScrolling:YES];
}

- (void)profileOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell {
//    self.vibedIndexPath = [self.tableView indexPathForCell:cell];
    [(TTTabBarController *)self.rdv_tabBarController presentCreateUserProfileScreenAnimated:YES];
}

- (void)signupOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell {
  //  self.vibedIndexPath = [self.tableView indexPathForCell:cell];
    [[DataManager sharedManager] showLoginScreen];
}

- (void)didHideDragView {
    [self enableScrolling:YES];
}

- (void)vibeOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell completion:(SimpleCompletionBlock)completion {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        Story *story = self.dataSource[indexPath.item];
        Company *company = [self companyForCompanyId:story.storyId];
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

- (void)storyFeedCellShouldMoveToUserProfile:(StoryFeedCollectionViewCell *)cell {
    [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
}

- (NSArray *)storiesForVisibleCells {
    NSMutableArray *stories = [NSMutableArray new];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [stories addObject:self.dataSource[indexPath.item]];
    }
    return [stories copy];
}

- (void)showWannaWorkFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"It seems that you are interested in quite a few companies, that's very nice\r\nAnyway,It looks like you have reached your maximum daily quota.\r\nFeel free to continue looking for other companies, and tomorrow you will be able to express your interest in them" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
}

- (void)enableScrolling:(BOOL)enable {
    if ([DataManager sharedManager].likeOpen) {
        self.collectionView.scrollEnabled = NO;
        return;
    }
    self.collectionView.scrollEnabled = enable;
}

- (void)dealloc {

}

@end
