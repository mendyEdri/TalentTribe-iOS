//
//  StoryFeedYAxisViewController.m
//  TalentTribe
//
//  Created by Mendy on 18/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "StoryFeedYAxisViewController.h"
#import "DataManager.h"
#import "JTMaterialSpinner.h"
#import "StoryFeedTableViewCell.h"
#import "StoryFeedMultimediaTableViewCell.h"
#import "Story.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import "DejalActivityView.h"
#import "AsyncVideoDisplay.h"
#import "StoryDetailsViewController.h"
#import "TTTabBarController.h"
#import "UIView+Additions.h"
#import "DataManager.h"
#import "User.h"

@interface StoryFeedYAxisViewController () <UITableViewDataSource, UITableViewDelegate, StoryFeedTableViewCellDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *companies;
@property (strong, nonatomic) AsyncVideoDisplay *asyncDisplay;
@property (nonatomic, strong) NSIndexPath *vibedIndexPath;
@end

@implementation StoryFeedYAxisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spinnerView.circleLayer.lineWidth = 2.0;
    self.spinnerView.circleLayer.strokeColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0].CGColor;
    [self.spinnerView beginRefreshing];
    self.tableView.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[DataManager sharedManager] storyFeedForCategory:self.selectedCategory companyId:nil completionHandler:^(id result, NSError *error) {
        DLog(@"Result %@", result);
        self.dataSource = [[NSMutableArray alloc] initWithArray:[result valueForKeyOrNil:@"Stories"]];
        self.companies = [[NSMutableArray alloc] initWithArray:[result valueForKeyOrNil:@"Companies"]];
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.hidden = NO;
            [self.spinnerView beginRefreshing];
        });
    }];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:self.selectedCategory.categoryName];
    //self.asyncDisplay = [[AsyncVideoDisplay alloc] initWithNothing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryFeedTableViewCell *cell;
    Story *story = self.dataSource[indexPath.row];
    
    DLog(@"StoryType %u", story.storyType);
    if ( story.storyType == StoryTypeStory) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"storyFeedTableViewCell"];
        
        DejalActivityView *activityUView = [DejalWhiteActivityView activityViewForView:cell];
        [cell.backgroundImage sd_setImageWithURL:[NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityUView removeFromSuperview];
        }];
    } else if (story.storyType == StoryTypeMultimedia) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"multimediaTableCell"];
        StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
        multimediaCell.urlString = story.videoLink;
        
        [cell.backgroundImage sd_setImageWithURL:story.videoThumbnailLink ? [NSURL URLWithString:story.videoThumbnailLink] : [NSURL URLWithString:@"http://www.wpclipart.com/computer/keyboard_keys/special_keys/computer_key_Delete.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    
    cell.companyTitle.attributedText = [TTUtils attributedCompanyName:story.companyName industry:nil];
    [cell setCompany:[self companyForCompanyId:story.companyId]];
    cell.delegate = self;
    
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[LinedTextView class]]) {
            [view removeFromSuperview];
        }
    }
    CGFloat textViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds) * 0.95;
    CGFloat textViewHeight = CGRectGetWidth([UIScreen mainScreen].bounds) * 0.4;
    [LinedTextView textViewWithText:story.storyTitle maxWidth:textViewWidth maxHeight:textViewHeight completion:^(id result, NSError *error) {
        if (result) {
            LinedTextView *textView = result;
            [cell.contentView addSubview:textView];
        }
    }];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(StoryFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.dataSource[indexPath.row];
    [cell.dragVibeView setUserVibed:story.userLike];
    [self performPendingVibeAction];
}

- (void)performPendingVibeAction {
    if (self.vibedIndexPath) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in visibleRows) {
                if ([self.vibedIndexPath isEqual:indexPath]) {
                    if ([[DataManager sharedManager] isCredentialsSavedInKeychain] && [[DataManager sharedManager].currentUser isProfileMinimumFilled]) {
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

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //[self startPlayingMultimediaItems];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  //  [self cancelPlayingMultimediaItems];
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

#pragma mark - Video Handling
/*
- (void)startPlayingMultimediaItems {
    StoryFeedMultimediaTableViewCell *multimediaCell;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[StoryFeedMultimediaTableViewCell class]]) {
            multimediaCell = (StoryFeedMultimediaTableViewCell *)cell;
            break;
        }
        break;
    }
    if (!multimediaCell || !multimediaCell.urlString) {
        return;
    }
    [multimediaCell playing:NO];
//    self.pendingCell = multimediaCell;
    self.asyncPlayer.pendingUrl = multimediaCell.urlString;
    [self.asyncPlayer playerWithUrl:multimediaCell.urlString completion:^(id result, NSError *error) {
        AVPlayer *player = result;
        player.muted = YES;
        if ([[[DataManager sharedManager] urlStringOfCurrentlyPlayingInPlayer:player] isEqualToString:self.asyncPlayer.pendingUrl]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.asyncPlayer cancelAllPlayingVideosWithCompletion:nil];
                [multimediaCell addPlayerLayerForPlayer:player withCompletion:nil];
                [self.asyncPlayer playPlayerWithUrl:multimediaCell.urlString];
                DLog(@"URL READY AND PLAY %@", [[DataManager sharedManager] urlStringOfCurrentlyPlayingInPlayer:player]);
                
                __block StoryFeedMultimediaTableViewCell *blockCell = multimediaCell;
                [self.asyncPlayer videoPlayingState:^(id result, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DLog(@"Playing Notification %@",result)
                        BOOL playing = [result boolValue];
                        [blockCell playing:playing];
                    });
                }];
            });
            return ;
        }
    }];
}
*/

#pragma mark StoryFeedTableViewCell delegate

- (void)willBeginDraggingOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    [self enableScrolling:NO];
}

- (void)willEndDraggingOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
    /*NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
     if (indexPath) {
     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
     }*/
    //[self enableScrolling:YES];
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

- (void)vibeOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell completion:(SimpleCompletionBlock)completion {
    NSIndexPath *storyIndexPath = [self.tableView indexPathForCell:cell];
    if (storyIndexPath) {
        Story *story = [self.dataSource objectAtIndex:storyIndexPath.row];
        [self likeStory:story inCompany:[self companyForCompanyId:story.companyId] completion:completion];
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
}

- (void)rightButtonPressedOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell {
}

- (void)collectionViewCellShouldClick:(StoryFeedCollectionViewCell *)cell {
}

- (void)presentStoryDetailsWithStory:(Story *)story {
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

#pragma mark - Like Hendle

- (void)showWannaWorkFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"It seems that you are interested in quite a few companies, that's very nice\r\nAnyway,It looks like you have reached your maximum daily quota.\r\nFeel free to continue looking for other companies, and tomorrow you will be able to express your interest in them" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
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

- (void)cancelPlayingMultimediaItems {
    DLog(@"Player Stoped");
   // [self.asyncPlayer cancelAllPlayingVideosWithCompletion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[DataManager sharedManager] cancelAllRequests];
//    [self.asyncPlayer cancelAllPlayingVideosWithCompletion:nil];
//    self.asyncPlayer = nil;
}

@end
