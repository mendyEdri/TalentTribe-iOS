//
//  StoryCommentsViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsViewController.h"
#import "Company.h"
#import "Story.h"
#import "StoryCategory.h"
#import "Comment.h"
#import "Author.h"
#import "DataManager.h"
#import "StoryDetailsContentCell.h"
#import "StoryDetailsImageCell.h"
#import "StoryDetailsShowImageCell.h"
#import "StoryDetailsGradientButtonCell.h"
#import "StoryDetailsCommentCell.h"
#import "StoryDetailsCategoryCell.h"
#import "StoryDetailsQuestionCell.h"
#import "StoryDetailsCollectionViewCell.h"
#import "StoryImagesViewController.h"
#import "StoryWebViewController.h"
#import "StoryDetailsLoadingCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SocialManager.h"
#import "NSDate+TimeAgo.h"
#import "DejalActivityView.h"
#import "CompanyProfileViewController.h"
#import "TTTabBarController.h"
#import "StoryHeaderView.h"
#import "LinkHeaderView.h"
#import "MultimediaHeaderView.h"
#import "StoryDetailsFooterView.h"
#import "UIImage+Crop.h"
#import "UIView+Additions.h"
#import "InsetTableView.h"
#import "CommManager.h"
#import "TTGradientHandler.h"
#import "StoryFeedViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "User.h"
#import "AsyncVideoDisplay.h"
#import <MessageUI/MessageUI.h>
#import "StoryDetailsShareCell.h"
#import "DetailsPageViewController.h"
#import <JTMaterialSpinner/JTMaterialSpinner.h>
#import "SearchResultsFeedViewController.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "CompanyLookingForViewController.h"

typedef enum {
    SectionHeader,
    SectionInfo,
    //SectionComments,
    sectionCount
} TableViewSections;

typedef enum {
    StoryCellImages,
    storyCellsHeaderCount
} StoryCellsHeader;

typedef enum {
    StoryCellContent,
    StoryCellCategories,
    StoryCellShare,
    storyCellsInfoCount
} StoryCellsInfo;

typedef enum {
    LinkCellImages,
    linkCellsHeaderCount
} LinkCellsHeader;

typedef enum {
    LinkCellContent,
    LinkCellViewOnWeb,
    LinkCellCategories,
    linkCellsInfoCount
} LinkCellsInfo;

typedef enum {
    QuestionCellView,
    questionCellsHeaderCount
} QuestionCellsHeader;

typedef enum {
    QuestionCellCategories,
    questionCellsInfoCount
} QuestionCellsInfo;

typedef enum {
    MultimediaCellView,
    multimediaCellsHeaderCount
} MultimediaCellsHeader;

typedef enum {
    multimediaCellsInfoCount
} MultimediaCells;

static void *AudioControllerBufferingObservationContext = &AudioControllerBufferingObservationContext;

@interface StoryDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TTDragVibeViewDelegate, StoryDetailsFooterViewDelegate, StoryDetailsCategoryDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet InsetTableView *tableView;

@property (nonatomic, weak) IBOutlet UIImageView *companyImageView;
@property (nonatomic, weak) IBOutlet UILabel *companyTitle;

@property (nonatomic, strong) UIBarButtonItem *likeBarItem;
@property (nonatomic, strong) UIBarButtonItem *shareBarItem;
@property (nonatomic, strong) UIBarButtonItem *commentBarItem;

@property (nonatomic, strong) StoryDetailsFooterView *commentsFooterView;

@property (nonatomic, strong) NSMutableArray *commentsContainer;
@property NSInteger currentCommentPage;

@property (nonatomic, strong) Comment *commentToUpdate;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, weak) IBOutlet UIView *headerView;

@property (assign, getter=isPlaying) BOOL playing;
@property (assign, nonatomic) UIInterfaceOrientation lastOrientation;
@property (weak, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionManager *strongMotionManager;
@property (strong, nonatomic) UIView *videoContainerView;
@property (strong, nonatomic) UIView *cellVideoContentView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIImageView *videoButtonImageView;
@property (assign, getter=isButtonAnimating) BOOL buttonAnimating;
@property (strong, nonatomic) AVPlayerLayer *currentPlayingLayer;
@property (strong, nonatomic) JTMaterialSpinner *videoSpinnerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@property (strong, nonatomic) AVPlayer *player;
@property BOOL showImages;
@property BOOL pendingVibe;
@property (nonatomic, assign) BOOL forcePause;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, strong) dispatch_block_t block;
@end

void (^activateMotionManager)(BOOL activate);
static const CGFloat VideoImageSize = 60;

@implementation StoryDetailsViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.pendingVibe = NO;
        self.showImages = NO;
        
        self.shouldOpenComment = NO;
        self.canOpenCompanyDetails = YES;
        
        self.dragVibeView = [TTDragVibeView loadFromXib];
        self.dragVibeView.delegate = self;
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)showCompanyDetails:(id)sender {
    if (self.canOpenCompanyDetails) {
        [self presentCompanyDetailsForCompany:self.company item:MenuItemStories];
    }
}

- (void)presentCompanyDetailsForCompany:(Company *)company item:(MenuItem)item {
    CompanyProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"companyProfileViewController"];
    controller.company = company;
    controller.currentSelectedItem = item;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addVideoPlayerToLayer:(CALayer *)layer withStory:(Story *)story {
   
}

- (void)startVideo {
    self.repeat = YES;
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:[NSURL URLWithString:self.currentStory.videoLink]]]];
        self.currentPlayingLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    }
    self.currentPlayingLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.currentPlayingLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
    
    self.videoContainerView.hidden = NO;
    [self animateView:YES];
    
    [self initializeMotionManager];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
    [self.videoContainerView addGestureRecognizer:self.tap];
    
    self.currentPlayingLayer.player = self.player;
    self.currentPlayingLayer.player.muted = NO;

    [self.videoContainerView.layer insertSublayer:self.currentPlayingLayer above:self.imageView.layer];
}

- (void)repeatEverySecondOnMain {
    if (!self.repeat) {
        DLog(@"Not Repeating");
        return;
    }
    
    __weak StoryDetailsViewController *weakSelf = self;
    [self shouldStartVideoWithPlayerItem:self.currentPlayingLayer.player.currentItem completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [weakSelf.currentPlayingLayer.player play];
                weakSelf.playing = YES;
                [weakSelf animateView:!weakSelf.currentPlayingLayer.player.currentItem.isPlaybackLikelyToKeepUp];
            } else {
                [weakSelf.currentPlayingLayer.player pause];
                weakSelf.playing = NO;
                [weakSelf animateView:!self.forcePause];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf repeatEverySecondOnMain];
        });
    }];
}

- (void)shouldStartVideoWithPlayerItem:(AVPlayerItem *)item completion:(SimpleCompletionBlock)completion {
    if (self.forcePause) {
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    if (!self.currentPlayingLayer.player.currentItem) {
        return;
    }
    NSTimeInterval currentTime = CMTimeGetSeconds(item.currentTime);
    NSTimeInterval completeDuration = CMTimeGetSeconds(item.duration);
    if (roundf(currentTime) == roundf(completeDuration)) {
        [self videoEnded:nil];
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    DLog(@"available %f", roundf([self availableDurationForPlayerItem:self.currentPlayingLayer.player.currentItem]) - roundf(currentTime));
    if (roundf([self availableDurationForPlayerItem:item]) - roundf(currentTime) >= 1.8 || roundf([self availableDurationForPlayerItem:item]) == roundf(completeDuration) || roundf([self availableDurationForPlayerItem:item]) >= (roundf(completeDuration) - 1)) {
        if (completion) {
            completion(YES, nil);
        }
    } else {
        if (completion) {
            completion(NO, nil);
        }
    }
}

- (void)methodToRepeatEveryOneSecond {
    [self startObserving:self.player.currentItem];

    self.block = dispatch_block_create(0, ^{
        [self methodToRepeatEveryOneSecond];
    });
    
    double delayInSeconds = 0.5;
    dispatch_queue_t q_background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, q_background, self.block);
}

- (void)playVideo {
    if (self.isButtonAnimating) {
        return;
    }
    self.isPlaying ? [self.currentPlayingLayer.player pause] : [self.currentPlayingLayer.player play];
    [self setVideoButtonOnView:self.videoContainerView];

    self.buttonAnimating = YES;
    [self animateVideoButtonWithCompletion:^{
        self.buttonAnimating = NO;
    }];
    self.forcePause = self.isPlaying;
    self.playing = !self.isPlaying;
}

- (void)playVideo:(BOOL)play {
    if (self.isButtonAnimating) {
        return;
    }
    play ? [self.currentPlayingLayer.player play] : [self.currentPlayingLayer.player pause];
    self.forcePause = !play;
    [self setVideoButtonOnView:self.videoContainerView];
    
    self.buttonAnimating = YES;
    [self animateVideoButtonWithCompletion:^{
        self.buttonAnimating = NO;
    }];
    
    self.playing = play;
}

- (void)setVideoButtonOnView:(UIView *)imageSuperview {
    if (!self.videoButtonImageView) {
        self.videoButtonImageView = [[UIImageView alloc] init];
    }
    self.videoButtonImageView.image = self.isPlaying ? [UIImage imageNamed:@"pause"] : [UIImage imageNamed:@"play"];
    [imageSuperview addSubview:self.videoButtonImageView];
    [self updateVideoButtonFrameWithOrientation:self.lastOrientation ? self.lastOrientation : UIInterfaceOrientationPortrait];
}

- (void)animateVideoButtonWithCompletion:(void (^)())completion {
    CGFloat animationDuration = 1.0;
    self.videoButtonImageView.alpha = 1.0;
    [UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:12.0 initialSpringVelocity:1.3 options:kNilOptions animations:^{
        self.videoButtonImageView.transform = CGAffineTransformMakeScale(1.85, 1.85);
        self.videoButtonImageView.alpha = 0.0;
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * 0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoButtonImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            if (completion) {
                completion();
            }
        });
    });
}

- (void)updateVideoButtonFrameWithOrientation:(UIInterfaceOrientation)orientation {
    CGRect imageFrame;
    if (orientation == UIDeviceOrientationLandscapeLeft || self.lastOrientation == UIDeviceOrientationLandscapeRight) {
        imageFrame = CGRectMake(CGRectGetMidY([UIScreen mainScreen].bounds) - (VideoImageSize / 2) , CGRectGetMidX([UIScreen mainScreen].bounds) - (VideoImageSize / 2), VideoImageSize, VideoImageSize);
    } else {
        imageFrame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - (VideoImageSize / 2), CGRectGetMidY(self.cellVideoContentView.bounds) - (VideoImageSize / 2), VideoImageSize, VideoImageSize);
    }
    self.videoButtonImageView.frame = imageFrame;
}

#pragma mark - Observers

- (void)videoEnded:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
    });
}

- (void)startObserving:(AVPlayerItem *)item {
    if (!item) {
        DLog(@"Item is nil %@", self);
        if (self.block) {
            dispatch_block_cancel(self.block);
            self.block = nil;
        }
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        AVPlayerItem *playerItem = item;
        
        Float64 duration = CMTimeGetSeconds(playerItem.currentTime);
        Float64 completeDuration = CMTimeGetSeconds(playerItem.asset.duration);
        if (self.forcePause) {
            return;
        }
        if (roundf(duration) == roundf(completeDuration)) {
            [self videoEnded:nil];
            return;
        }
        if (roundf([self availableDurationForPlayerItem:playerItem]) - roundf(duration) >= 1.8 || roundf([self availableDurationForPlayerItem:playerItem]) == roundf(completeDuration) || roundf([self availableDurationForPlayerItem:playerItem]) >= (roundf(completeDuration) - 1)) {
            [self.player play];
            self.playing = YES;
            [self animateView:NO];
            DLog(@"PLAYING");
        } else {
            [self.player pause];
            self.playing = NO;
            [self animateView:YES];
            DLog(@"PAUSING");
        }
    });
}

#pragma mark - CoreMotion

- (void)initializeMotionManager {
    if (!self.currentStory.videoLink) {
        return;
    }
    if ([self.parentViewController.parentViewController isKindOfClass:[DetailsPageViewController class]]) {
        __weak DetailsPageViewController *detailsPage = (DetailsPageViewController *)self.parentViewController.parentViewController;
        if (!detailsPage.motionManager) {
            return;
        }
        self.motionManager = detailsPage.motionManager;
    } else {
        self.strongMotionManager = [[CMMotionManager alloc] init];
        self.motionManager = self.strongMotionManager;
    }
    
    self.motionManager.accelerometerUpdateInterval = 0.6;
    activateMotionManager = ^(BOOL activate) {
        if (!activate) {
            [self.motionManager stopAccelerometerUpdates];
            return ;
        }
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (!error) {
                [self outputAccelertionData:accelerometerData.acceleration];
            } else {
                NSLog(@"%@", error);
            }
        }];
    };
    activateMotionManager(YES);
}

- (void)outputAccelertionData:(CMAcceleration)acceleration {
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    } else {
        // Consider same as last time or upsidedown
        return;
    }
    
    if (orientationNew == self.lastOrientation) {
        return;
    }
    [self deviceOrientationDidChangeOrientation:orientationNew];
    self.lastOrientation = orientationNew;
}

- (void)deviceOrientationDidChangeOrientation:(UIInterfaceOrientation)orientation {
    [self updateVideoButtonFrameWithOrientation:orientation];
    if (orientation == UIDeviceOrientationPortrait) {
        [self rotateVideoToPortrait];
        return;
    }
    [self rotateVideoToLandscape:orientation];
}

- (void)rotateVideoToPortrait {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:12.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.videoContainerView.transform = CGAffineTransformMakeRotation(0);
        self.videoContainerView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentPlayingLayer.frame = self.videoContainerView.bounds;
            [self.cellVideoContentView addSubview:self.videoContainerView];
            [self.view addSubview:self.headerView];
            self.headerView.userInteractionEnabled = YES;
            self.headerView.hidden = YES;
        });
    } completion:nil];
}

- (void)rotateVideoToLandscape:(UIInterfaceOrientation)orientation {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:12.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            self.videoContainerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            self.videoContainerView.transform = CGAffineTransformMakeRotation(M_PI_2 * 3.0);
        }
        self.headerView.hidden = NO;
        self.videoContainerView.frame = [UIScreen mainScreen].bounds;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentPlayingLayer.frame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
        });
        [self.videoContainerView addSubview:self.headerView];
        self.headerView.userInteractionEnabled = NO;
        [self.view.window addSubview:self.videoContainerView];
    } completion:nil];
}

#pragma mark Cells actions

- (IBAction)commentButtonPressedOnCell:(id)sender {
    /*if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if (![[DataManager sharedManager] isCVAvailable]) {
            [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
        } else {
            [self commentStory:self.currentStory];
        }
    } else {
        [[DataManager sharedManager] showLoginScreen];
    }*/
}

- (IBAction)showImagesButtonPressed:(id)sender {
    self.showImages = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionHeader] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)hideImagesButtonPressed:(id)sender {
    self.showImages = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionHeader] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark UIBarButtonItems actions

- (void)commentButtonPressed {
    /*if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if (![[DataManager sharedManager] isCVAvailable]) {
            [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
        } else {
            [self commentStory:self.currentStory];
        }
    } else {
        [[DataManager sharedManager] showLoginScreen];
    }*/
}

- (void)viewOnWebButtonPressed {
    [self presentWebViewForStory:self.currentStory];
}

#pragma mark Actions

- (void)commentStory:(Story *)story {
    [self presentKeyboard:YES];
}

- (void)shareButtonPressed {
    [self playVideo:NO];
    void (^shareBlock)() = ^{
        [[SocialManager sharedManager] shareStory:self.currentStory controller:self completionHandler:^(BOOL success, NSError *error) {
            if (success && !error) {
                DLog(@"Shared");
            } else {
                //[self showShareToFacebookFailedAlert];
            }
        }];
    };
    shareBlock();
}

- (void)shareStory:(Story *)story {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
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

- (UIImage *)renderScrollViewToImage {
    UIImage *image = nil;

    CGFloat snapHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - (CGRectGetHeight(self.navigationController.navigationBar.bounds) + (65));
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), snapHeight);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, .75);
    {
        self.tableView.contentOffset = CGPointZero;
        
        [self.tableView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return image;
}

- (void)likeStory:(Story *)story inCompany:(Company *)company  completion:(SimpleCompletionBlock)completion {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        [[DataManager sharedManager] likeStory:story like:YES completionHandler:^(BOOL success,NSError *error) {
            if (success && !error) {
                [story setUserLike:YES];
                [company setWannaWork:YES];
                [self.dragVibeView setUserVibed:YES];
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

- (void)unlikeVibeOnDragView:(TTDragVibeView *)cell {
    
}

- (void)wannaWorkInCompany:(Company *)company completion:(SimpleCompletionBlock)completion {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        [[DataManager sharedManager] wannaWorkInCompany:company wanna:YES completionHandler:^(BOOL success,NSError *error) {
            if (success && !error) {
                [company setWannaWork:YES];
                [self.dragVibeView setUserVibed:YES];
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

#pragma mark Load more comments

- (void)loadMoreCommentsPressedOnStoryDetailsFooterView:(StoryDetailsFooterView *)footerView {
    /*@synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnView:self.view];
            [self loadCommentsForPage:self.currentCommentPage + 1 refresh:NO completion:^(NSArray *result, NSError *error) {
                if (result && !error) {
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionComments] withRowAnimation:UITableViewRowAnimationAutomatic];
                    self.tableView.tableFooterView = (result.count != STORYCOMMENTS_DEFAULT_PAGE_SIZE) ? nil : self.commentsFooterView;
                }
                loading = NO;
                [TTActivityIndicator dismiss];
            }];
        }
    }*/
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

#pragma mark ReloadData

- (void)reloadData {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            //[TTActivityIndicator showOnView:self.view];
            [self.dragVibeView setCurrentCompany:self.company];
            if (self.company.companyLogo) {
                [self.companyImageView sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo]];
            } else if (self.currentStory.companyLogo) {
                [self.companyImageView sd_setImageWithURL:[NSURL URLWithString:self.currentStory.companyLogo]];
            }
            
            if (self.company.companyName) {
                self.companyTitle.attributedText = [TTUtils attributedCompanyName:self.company.companyName industry:self.company.industry];
            } else if (self.currentStory.companyName) {
                self.companyTitle.attributedText = [TTUtils attributedCompanyName:self.currentStory.companyName industry:nil];
            }
            [self updateHeaderButtonsState];
            
            self.tableView.dataSource = self;
            [self.tableView reloadData];
            
            loading = NO;
            
            if (self.pendingVibe) {
                DataManager *dMgr = [DataManager sharedManager];
                if ([dMgr isCredentialsSavedInKeychain] && [dMgr.currentUser isProfilePartiallyFilled]) {
                    [self.dragVibeView performVibeActionManually];
                }
                self.pendingVibe = NO;
            }
            
            /*self.currentCommentPage = 0;
            self.commentsContainer = [NSMutableArray new];
            
            [self loadCommentsForPage:self.currentCommentPage refresh:YES completion:^(NSArray *result, NSError *error) {
                [self.tableView reloadData];
                self.tableView.tableFooterView = (result.count != STORYCOMMENTS_DEFAULT_PAGE_SIZE) ? nil : self.commentsFooterView;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.shouldOpenComment) {
                        self.shouldOpenComment = NO;
                        [self presentKeyboard:YES];
                    }
                });
                loading = NO;
                [TTActivityIndicator dismiss];
            }];*/
        }
    }
}

- (void)loadCommentsForPage:(NSInteger)page refresh:(BOOL)refresh completion:(SimpleResultBlock)completion {
    [[DataManager sharedManager] commentsForStory:self.currentStory page:page count:STORYCOMMENTS_DEFAULT_PAGE_SIZE completionHandler:^(id result, NSError *error) {
        if ((result && [result isKindOfClass:[NSArray class]]) && !error) {
            NSArray *resultArray = (NSArray *)result;
            self.currentCommentPage = page;
            
            if (refresh) {
                [self.commentsContainer removeAllObjects];
            }
            [self.commentsContainer addObjectsFromArray:resultArray];
            if (completion) {
                completion(result, nil);
            }
        } else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)updateHeaderButtonsState {
    UIButton *commentButton = (UIButton *)self.commentBarItem.customView;
    [commentButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.currentStory.commentsNum] forState:UIControlStateNormal];
    [commentButton sizeToFit];
    CGRect frame = commentButton.frame;
    frame.size = CGSizeMake(frame.size.width + commentButton.titleEdgeInsets.left + commentButton.titleEdgeInsets.right, frame.size.height);
    [commentButton setFrame:frame];
    [(UIButton *)self.likeBarItem.customView setSelected:self.currentStory.userLike];
}

#pragma mark TTDragView delegate

- (void)willBeginDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    if (self.dragHandler) {
        self.dragHandler(YES);
    }
}

- (void)willEndDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    if (self.dragHandler) {
        self.dragHandler(NO);
    }
}

- (void)profileOnDragVibeView:(TTDragVibeView *)cell {
    [(TTTabBarController *)self.rdv_tabBarController moveToProfileTab];
    if (self.delegate) {
        [self.delegate openProfilePage];
    }
}

- (void)signupOnDragVibeView:(TTDragVibeView *)cell {
    self.pendingVibe = YES;
     [[DataManager sharedManager] showLoginScreen];
}

- (void)vibeOnDragVibeView:(TTDragVibeView *)cell completion:(SimpleCompletionBlock)completion {
    /*if(![[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if (completion) {
            completion(NO, nil);
        }
        [[DataManager sharedManager] showLoginScreen];
    } else {
        if (![[DataManager sharedManager] isCVAvailable]) {
            [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
        } else {
            [self wannaWorkInCompany:self.company completion:completion];
        }
    }*/
    //[self wannaWorkInCompany:self.company completion:completion];
    [self likeStory:self.currentStory inCompany:self.company completion:completion];
}

#pragma mark Adding/editing comments

/*- (void)didPressRightButton:(id)sender {
    [self.textView refreshFirstResponder];
    
    Comment *comment = [Comment new];
    comment.commentDate = [NSDate date];
    comment.commentContent = [self.textView.text copy];
    
    [self addComment:comment forStory:self.currentStory];
    [super didPressRightButton:sender];
    [self dismissKeyboard:YES];
}

- (void)didCommitTextEditing:(id)sender {
    self.commentToUpdate.commentContent = [self.textView.text copy];
    NSInteger commentIndex = [self.commentsContainer indexOfObject:self.commentToUpdate];
    if (commentIndex != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:commentIndex inSection:SectionComments]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self updateComment:self.commentToUpdate forStory:self.currentStory];
    [super didCommitTextEditing:sender];
    [self dismissKeyboard:YES];
}

- (void)didCancelTextEditing:(id)sender {
    [super didCancelTextEditing:sender];
    [self dismissKeyboard:YES];
}

- (void)addComment:(Comment *)comment forStory:(Story *)story {
    @synchronized (self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnView:self.view];
            [[DataManager sharedManager] addComment:comment forStory:self.currentStory completionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SectionComments];
                    [self loadCommentsForPage:0 refresh:YES completion:^(NSArray *result, NSError *error) {
                        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
                        [self.tableView setContentOffset:CGPointMake(0, rect.origin.y - self.headerView.frame.size.height) animated:YES];
                        loading = NO;
                        

                                self.currentStory.commentsNum ++;
                                [self updateHeaderButtonsState];
                                [self.tableView reloadData];
                                [TTActivityIndicator dismiss];

                       
                    }];
                } else {
                    //handle error
                    loading = NO;
                    [TTActivityIndicator dismiss];
                }
                            }];
            
        }
    }
}

- (void)editComment:(Comment *)comment {
    self.commentToUpdate = comment;
    [self editText:comment.commentContent];
}

- (void)updateComment:(Comment *)comment forStory:(Story *)story {
    @synchronized (self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnView:self.view];
            [[DataManager sharedManager] updateComment:comment forStory:self.currentStory completionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [self loadCommentsForPage:0 refresh:YES completion:^(NSArray *result, NSError *error) {
                        loading = NO;
                        [TTActivityIndicator dismiss];
                    }];
                } else {
                    //handle error
                    loading = NO;
                    [TTActivityIndicator dismiss];
                }
                            }];
            
        }
    }
}*/

#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currentStory ? sectionCount : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionHeader: {
            switch (self.currentStory.storyType) {
                case StoryTypeStory: {
                    return self.showImages ? self.currentStory.storyImages.count : storyCellsHeaderCount;
                } break;
                case StoryTypeLink: {
                    return self.showImages ? self.currentStory.storyImages.count : linkCellsHeaderCount;
                } break;
                case StoryTypeQuestion: {
                    return questionCellsHeaderCount;
                } break;
                case StoryTypeMultimedia: {
                    return multimediaCellsHeaderCount;
                } break;
                default: {
                    return 0;
                } break;
            }
        } break;
        case SectionInfo: {
            switch (self.currentStory.storyType) {
                case StoryTypeStory: {
                    return storyCellsInfoCount;
                } break;
                case StoryTypeLink: {
                    return linkCellsInfoCount;
                } break;
                case StoryTypeQuestion: {
                    return questionCellsInfoCount;
                } break;
                case StoryTypeMultimedia: {
                    return storyCellsInfoCount;
                } break;
                default: {
                    return 0;
                } break;
            }
        } break;
        /*case SectionComments: {
            return self.commentsContainer.count ?: 1;
        } break;*/
        default: {
            return 0;
        } break;
    }
}

#pragma mark Header handling

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SectionInfo) {
        switch (self.currentStory.storyType) {
            case StoryTypeStory: {
                return [self heightForStoryHeaderForStory:self.currentStory];
            } break;
            case StoryTypeLink: {
                return [self heightForLinkHeaderForStory:self.currentStory];
            } break;
            case StoryTypeMultimedia: {
                return [self heightForStoryHeaderForStory:self.currentStory];
            } break;
            default: {
                return 0;
            } break;
        }
    }
    return 0.0f;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SectionComments) {
        if (self.commentsContainer.count && (self.commentsContainer.count % STORYCOMMENTS_DEFAULT_PAGE_SIZE == 0)) {
            return [StoryDetailsFooterView height];
        }
    }
    return 0.0f;
}*/

- (CGFloat)heightForStoryHeaderForStory:(Story *)story {
    return [StoryHeaderView heightForTitle:story.storyTitle author:[story.author.fullName containsString:@"TalentTribe Admin"] ? @"" : story.author.fullName size:self.view.frame.size.width];
}

- (CGFloat)heightForLinkHeaderForStory:(Story *)story {
    return [LinkHeaderView heightForTitle:story.storyTitle author:[story.author.fullName containsString:@"TalentTribe Admin"] ? @"" : story.author.fullName size:self.view.frame.size.width];
}

- (CGFloat)heightForMultimediaHeaderForStory:(Story *)story {
    return [MultimediaHeaderView heightForTitle:story.storyTitle author:[story.author.fullName containsString:@"TalentTribe Admin"] ? @"" : story.author.fullName size:self.view.frame.size.width];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == SectionInfo) {
        switch (self.currentStory.storyType) {
            case StoryTypeStory: {
                return [self viewForStoryHeaderForStory:self.currentStory];
            } break;
            case StoryTypeLink: {
                return [self viewForLinkHeaderForStory:self.currentStory];
            } break;
            case StoryTypeMultimedia: {
                return [self viewForMultimediaHeaderForStory:self.currentStory];
            } break;
            default: {
                return nil;
            } break;
        }
    }
    return nil;
}

/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == SectionComments) {
        return [self viewForFooterForStory:self.currentStory];
    }
}*/

- (UIView *)viewForStoryHeaderForStory:(Story *)story {
    BOOL hideName = [story.author.fullName containsString:@"TalentTribe Admin"] ? YES : NO;
    
    StoryHeaderView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"story"];
    [headerView setTitle:story.storyTitle];
    [headerView setAuthor:hideName ? @"" : story.author.fullName  date:story.storyUpdateTime];
    [headerView setOccupation:nil];
    [headerView setAuthorImageURL:hideName ? @"" : story.author.profileImageLink];
    
    return headerView;
}

- (UIView *)viewForLinkHeaderForStory:(Story *)story {
    LinkHeaderView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"link"];
    [headerView setTitle:story.storyTitle];
    [headerView setAuthor:story.author.fullName date:nil];
    [headerView setOccupation:nil];
    [headerView setAuthorImageURL:story.author.profileImageLink];
    [headerView setLinkURL:story.videoLink date:story.storyUpdateTime];
    
    return headerView;
}

- (UIView *)viewForMultimediaHeaderForStory:(Story *)story {
    BOOL hideName = [story.author.fullName containsString:@"TalentTribe Admin"] ? YES : NO;
    
    MultimediaHeaderView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"story"];
    [headerView setTitle:story.storyTitle];
    [headerView setAuthor:hideName ? @"" : story.author.fullName  date:story.storyUpdateTime];
    [headerView setOccupation:nil];
    [headerView setAuthorImageURL:hideName ? @"" : story.author.profileImageLink];
    return headerView;
}

- (UIView *)viewForFooterForStory:(Story *)story {
    StoryDetailsFooterView *footerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"storyDetailsFooterView"];
    footerView.delegate = self;
    return footerView;
}

#pragma mark Heights handling

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if (indexPath.section == SectionComments) {
        return [self heightForCommentCellAtIndexPath:indexPath];
    } else {*/
    switch (self.currentStory.storyType) {
        case StoryTypeStory: {
            return [self heightForStoryCellAtIndexPath:indexPath];
        } break;
        case StoryTypeLink: {
            return [self heightForLinkCellAtIndexPath:indexPath];
        } break;
        case StoryTypeQuestion: {
            return [self heightForQuestionCellAtIndexPath:indexPath];
        } break;
        case StoryTypeMultimedia: {
            return [self heightForMultimediaCellAtIndexPath:indexPath];
        } break;
        default: {
            return 0;
        } break;
    }
    //}
}

- (CGFloat)heightForStoryCellAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            return [self heightForImageCellForStory:story indexPath:indexPath];
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case StoryCellContent: {
                    return [self heightForContentCellForStory:story];
                } break;
                case StoryCellCategories: {
                    return [self heightForCategoryCellForStory:story];
                } break;
                case StoryCellShare: {
                    return [self heightForShareCellForStory:story];
                } break;
            }
        } break;
    }
    return 0.0f;
}

- (CGFloat)heightForLinkCellAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            return [self heightForImageCellForStory:story indexPath:indexPath];
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case LinkCellContent: {
                    return [self heightForContentCellForStory:story];
                } break;
                case LinkCellViewOnWeb: {
                    return [self heightForViewOnWebCellForStory:story];
                } break;
                case LinkCellCategories: {
                    return [self heightForCategoryCellForStory:story];
                } break;
            }
        } break;
    }
    return 0.0f;
}

- (CGFloat)heightForQuestionCellAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            switch (indexPath.row) {
                case QuestionCellView: {
                    return [self heightForQuestionCellForStory:story];
                } break;
            }
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case QuestionCellCategories: {
                    return [self heightForCategoryCellForStory:story];
                } break;
            }
        } break;
    }
    return 0.0f;
}

- (CGFloat)heightForMultimediaCellAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            switch (indexPath.row) {
                case MultimediaCellView: {
                    return [self heightForImageCellForStory:story];
                } break;
            }
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case StoryCellContent: {
                    return [self heightForContentCellForStory:story];
                } break;
                case StoryCellCategories: {
                    return [self heightForCategoryCellForStory:story];
                } break;
                case StoryCellShare: {
                    return [self heightForShareCellForStory:story];
                } break;
            }
        } break;
    }
    return 0.0f;
}

#pragma mark Custom cells heights handling

- (CGFloat)heightForCommentCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.commentsContainer.count) {
        return [self heightForCommentCellForComment:[self.commentsContainer objectAtIndex:indexPath.row]];
    } else {
        return [self heightForBeFirstToCommentCellForStory:self.currentStory];//self.commentsLoading ? [self heightForLoadingCellForStory:self.currentStory] :
    }
}

- (CGFloat)heightForShowImageCellsForStory:(Story *)story {
    CGFloat height = 0.0f;
    for (NSInteger index = 0; index < story.storyImages.count; index++) {
        height += [self heightForImageCellForStory:story indexPath:[NSIndexPath indexPathForRow:index inSection:SectionHeader]];
    }
    return height;
}

- (CGFloat)heightForImageCellForStory:(Story *)story {
    return [self heightForImageCellForStory:story indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (CGFloat)heightForImageCellForStory:(Story *)story indexPath:(NSIndexPath *)indexPath {
    NSString *imageLink = [[story.storyImages objectAtIndex:indexPath.row] objectForKeyOrNil:kRegularImage];
    if (imageLink.length) {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:imageLink]]) {
            UIImage *firstImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:imageLink];
            return ceil(firstImage.size.height * self.view.bounds.size.width / firstImage.size.width);
        } else {
            return self.view.bounds.size.width;
            //return [self heightForLoadingCellForStory:story];
        }
    } else {
        if (story.storyType == StoryTypeMultimedia) {
            return self.view.bounds.size.width;
        } else {
            return [self heightForEmptyCellForStory:story indexPath:[NSIndexPath indexPathForRow:StoryCellImages inSection:0]];
        }
    }
    return 0.0f;
}

- (CGFloat)heightForContentCellForStory:(Story *)story {
    return CGRectIntegral([story.storyContent boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - [StoryDetailsContentCell contentLeftMargin] - [StoryDetailsContentCell contentRightMargin], CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[StoryDetailsContentCell font]} context:nil]).size.height + [StoryDetailsContentCell contentTopMargin] + [StoryDetailsContentCell contentBottomMargin];
}

- (CGFloat)heightForEmptyCellForStory:(Story *)story indexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == StoryCellImages || indexPath.row == MultimediaCellView || indexPath.row == LinkCellImages) {
        return self.headerView.bounds.size.height;
    }
    return 15.0f;
}

- (CGFloat)heightForQuestionCellForStory:(Story *)story {
    return ceil(290.0f * (self.view.bounds.size.width / 320.0f));
}

- (CGFloat)heightForViewOnWebCellForStory:(Story *)story {
    return [StoryDetailsGradientButtonCell height];
}

- (CGFloat)heightForBeFirstToCommentCellForStory:(Story *)story {
    return [StoryDetailsGradientButtonCell height];
}

- (CGFloat)heightForLoadingCellForStory:(Story *)story {
    return [StoryDetailsGradientButtonCell height];
}

- (CGFloat)heightForCommentCellForComment:(Comment *)comment {
    if (comment) {
        return CGRectIntegral([comment.commentContent boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - [StoryDetailsCommentCell contentLeftMargin] - [StoryDetailsCommentCell contentRightMargin], CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [StoryDetailsCommentCell font]} context:nil]).size.height + [StoryDetailsCommentCell contentTopMargin] + [StoryDetailsCommentCell contentBottomMargin];
    }
    return 0.0f;
}

- (CGFloat)heightForCategoryCellForStory:(Story *)story {
    if (story) {
        NSMutableArray *categoryNames = [NSMutableArray new];
        for (StoryCategory *category in story.categories) {
            if (category.categoryName) {
                [categoryNames addObject:category.categoryName];
            }
        }
        return [StoryDetailsCategoryCell fittedSizeForItems:categoryNames width:self.view.frame.size.width - [StoryDetailsCategoryCell contentLeftMargin] - [StoryDetailsCategoryCell contentRightMargin]].height;
    }
    return 0.0f;
}

- (CGFloat)heightForShareCellForStory:(Story *)story {
    return 180;
}

#pragma mark Cells hangling

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[StoryDetailsImageCell class]]) {
        StoryDetailsImageCell *imagesCell = (StoryDetailsImageCell *)cell;
        [imagesCell setCollectionViewDataSource:self delegate:self];
        imagesCell.showImagesButton.hidden = self.currentStory.storyImages.count <= 1;
    } else if ([cell isKindOfClass:[StoryDetailsShowImageCell class]]) {
        StoryDetailsShowImageCell *showImagesCell = (StoryDetailsShowImageCell *)cell;
        showImagesCell.hideButton.hidden = indexPath.row < (self.currentStory.storyImages.count - 1);
        if (indexPath.row == self.currentStory.storyImages.count - 1) {
            UIImage *image = [cell renderImage];
            DLog(@"IMAGE FRAME SIZE IS %f %f", image.size.width, image.size.height);
            CGFloat height = (image.size.width * self.imageView.bounds.size.height) / self.imageView.bounds.size.width;
            DLog(@"WILL CUT PIECE OF width %f, y = %f, h = %f", image.size.width, image.size.height - height, height);
            self.currentImage = image;//[image cropToRect:CGRectMake(0, image.size.height - height, image.size.width, height)];
            DLog(@"CURRENT IMAGE w = %f, h = %f", self.currentImage.size.width, self.currentImage.size.height);
        }
        
    } else if ([cell isKindOfClass:[StoryDetailsQuestionCell class]]) {
        UIImage *image = [cell renderImage];
        CGFloat height = (image.size.width * self.imageView.bounds.size.height) / self.imageView.bounds.size.width;
        self.currentImage = [image cropToRect:CGRectMake(0, image.size.height - height, image.size.width, height)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if (indexPath.section == SectionComments) {
        return [self commentCellForIndexPath:indexPath];
    } else {*/
    switch (self.currentStory.storyType) {
        case StoryTypeStory: {
            return [self storyCellForIndexPath:indexPath];
        } break;
        case StoryTypeLink: {
            return [self linkCellForIndexPath:indexPath];
        } break;
        case StoryTypeQuestion: {
            return [self questionCellForIndexPath:indexPath];
        } break;
        case StoryTypeMultimedia: {
            return [self multimediaCellForIndexPath:indexPath];
        } break;
        default: {
            return nil;
        } break;
    }
    //}
}

- (UITableViewCell *)storyCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            if (self.showImages) {
                return [self showImagesCellForStory:story indexPath:indexPath];
            } else {
                switch (indexPath.row) {
                    case StoryCellImages: {
                        return [self imageCellForStory:story];
                    } break;
                }
            }
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case StoryCellContent: {
                    return [self contentCellForStory:story];
                } break;
                case StoryCellCategories: {
                    return [self categoryCellForStory:story];
                } break;
                case StoryCellShare: {
                    return [self shareCellForStory:story];
                } break;
            }
        } break;
    }
    return cell;
}

- (UITableViewCell *)linkCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            if (self.showImages) {
                return [self showImagesCellForStory:story indexPath:indexPath];
            } else {
                switch (indexPath.row) {
                    case LinkCellImages: {
                        return [self imageCellForStory:story];
                    } break;
                }
            }
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case LinkCellContent: {
                    return [self contentCellForStory:story];
                } break;
                case LinkCellViewOnWeb: {
                    return [self viewOnWebCellForStory:story];
                } break;
                case LinkCellCategories: {
                    return [self categoryCellForStory:story];
                } break;
            }
        } break;
    }
    return cell;
}

- (UITableViewCell *)questionCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            switch (indexPath.row) {
                case QuestionCellView: {
                    return [self questionCellForStory:story];
                } break;
            }
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case QuestionCellCategories: {
                    return [self categoryCellForStory:story];
                } break;
            }
        } break;
    }
    return cell;
}

- (UITableViewCell *)multimediaCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    Story *story = self.currentStory;
    switch (indexPath.section) {
        case SectionHeader: {
            switch (indexPath.row) {
                case MultimediaCellView: {
                    return [self multimediaCellForStory:story];
                } break;
            }
        } break;
        case SectionInfo: {
            switch (indexPath.row) {
                case StoryCellContent: {
                    return [self contentCellForStory:story];
                } break;
                case StoryCellCategories: {
                    return [self categoryCellForStory:story];
                } break;
                case StoryCellShare: {
                    return [self shareCellForStory:story];
                } break;
            }
        } break;
    }
    return cell;
}

- (UITableViewCell *)commentCellForIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.currentStory;
    
    if (self.commentsContainer.count) {
        return [self commentCellForComment:[self.commentsContainer objectAtIndex:indexPath.row]];
    } else {
        return [self beFirstToCommentCellForStory:story];//self.commentsLoading ? [self loadingCellForStory:story] :
    }
}

#pragma mark Custom cells handling

- (StoryDetailsGradientButtonCell *)viewOnWebCellForStory:(Story *)story {
    StoryDetailsGradientButtonCell *gradientCell = [self.tableView dequeueReusableCellWithIdentifier:@"gradientCell"];
    if (story) {
        [gradientCell.gradientButton setTitle:@"View on Web" forState:UIControlStateNormal];
        [gradientCell.gradientButton addTarget:self action:@selector(viewOnWebButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return gradientCell;
}

- (StoryDetailsGradientButtonCell *)beFirstToCommentCellForStory:(Story *)story {
    StoryDetailsGradientButtonCell *gradientCell = [self.tableView dequeueReusableCellWithIdentifier:@"gradientCell"];
    if (story) {
        [gradientCell.gradientButton setTitle:@"Be the First to Comment" forState:UIControlStateNormal];
        [gradientCell.gradientButton addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return gradientCell;
}

- (UITableViewCell *)loadingCellForStory:(Story *)story {
    StoryDetailsLoadingCell *loadingCell = [self.tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    [loadingCell.activityIndicator startAnimating];
    return loadingCell;
}

- (UITableViewCell *)emptyCellForStory:(Story *)story {
    UITableViewCell *loadingCell = [self.tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
    return loadingCell;
}

- (StoryDetailsCommentCell *)commentCellForComment:(Comment *)comment {
    StoryDetailsCommentCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if (comment) {
        if (comment.author.profileImageLink || comment.author.fullName) {
            if (comment.author.profileImageLink) {
                [commentCell.authorImageView sd_setImageWithURL:[NSURL URLWithString:comment.author.profileImageLink] placeholderImage:[UIImage imageNamed:@"user_avatar"]];
            } else {
                [commentCell.authorImageView setImage:[UIImage imageNamed:@"user_avatar"]];
            }
            NSString *highlightedString = comment.author.fullName;
            NSString *dot = @"·";
            NSString *commentString = highlightedString; //[NSString stringWithFormat:@"%@ %@ %@", highlightedString, dot, [comment.commentDate timeAgo]];
            
            if (commentString) {
                NSMutableAttributedString *attributedString = [self attributedStringForString:commentString highlight:highlightedString];
                NSRange range = [attributedString.string rangeOfString:dot];
                if (range.location != NSNotFound) {
                    [attributedString setAttributes:[TTUtils attributesForDot] range:range];
                }
                commentCell.authorLabel.attributedText = attributedString;
            }
        } else {
            commentCell.authorImageView.image = [UIImage imageNamed:@"user_avatar"];
            commentCell.authorLabel.attributedText = nil;
        }
        commentCell.contentLabel.text = comment.commentContent;
    }
    return commentCell;
}

- (UITableViewCell *)showImagesCellForStory:(Story *)story indexPath:(NSIndexPath *)indexPath {
    NSString *imageLink = [[story.storyImages objectAtIndex:indexPath.row] objectForKeyOrNil:kRegularImage];
    if (imageLink.length) {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:imageLink]]) {
            StoryDetailsShowImageCell *showImageCell = (StoryDetailsShowImageCell *)[self.tableView dequeueReusableCellWithIdentifier:@"showImageCell"];
            [showImageCell.detailsImageView setImage:[[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:imageLink]];
            return showImageCell;
        } else {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageLink] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
            return [self loadingCellForStory:story];
        }
    } else {
        if (story.storyType == StoryTypeMultimedia) {
            return [self.tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        } else {
            return [self emptyCellForStory:story];
        }
    }
}

- (UITableViewCell *)imageCellForStory:(Story *)story {
    NSString *firstImageLink = [story.storyImages.firstObject objectForKeyOrNil:kRegularImage];
    if (firstImageLink.length) {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:firstImageLink]]) {
            return [self.tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        } else {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:firstImageLink] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                NSInteger index = NSNotFound;
                switch (story.storyType) {
                    case StoryTypeStory: {
                        index = StoryCellImages;
                    } break;
                    case StoryTypeLink: {
                        index = LinkCellImages;
                    } break;
                    case StoryTypeMultimedia: {
                        index = MultimediaCellView;
                    } break;
                    default: break;
                }
                if (index != NSNotFound) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:SectionHeader]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
            return [self loadingCellForStory:story];
        }
    } else {
        if (story.storyType == StoryTypeMultimedia) {
            return [self.tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        } else {
            return [self emptyCellForStory:story];
        }
    }
}

- (UITableViewCell *)multimediaCellForStory:(Story *)story {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    StoryDetailsImageCell *imageCell;
    if ([cell isKindOfClass:[StoryDetailsImageCell class]]) {
        imageCell = (StoryDetailsImageCell *)cell;
    }
    
    if (!self.videoContainerView) {
        self.videoContainerView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    }
    self.cellVideoContentView = cell.contentView;
    [cell.contentView addSubview:self.videoContainerView];
    
    
    if (!self.videoSpinnerView) {
        self.videoSpinnerView = [[JTMaterialSpinner alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2 - (30), CGRectGetWidth([UIScreen mainScreen].bounds)/2 - (30), 60, 60)];
        self.videoSpinnerView.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.videoSpinnerView.circleLayer.lineWidth = 2.0;
        [self.videoContainerView addSubview:self.videoSpinnerView];
    }
    
    if (!self.indicator) {
        self.indicator = [[UIActivityIndicatorView alloc] init];
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.indicator.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2 - (20), CGRectGetWidth([UIScreen mainScreen].bounds)/2 - (20), 40, 40);
        [self.videoContainerView addSubview:self.indicator];
    }
    
    self.currentPlayingLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //[self.videoContainerView.layer insertSublayer:self.currentPlayingLayer above:self.imageView.layer];
    
    [self startVideo];
    
    [self rotateVideoToPortrait];
    [self.videoContainerView addSubview:self.headerView];
    return cell;
}

- (StoryDetailsContentCell *)contentCellForStory:(Story *)story {
    StoryDetailsContentCell *contentCell = [self.tableView dequeueReusableCellWithIdentifier:@"contentCell"];
    if (story) {
        contentCell.contentLabel.text = story.storyContent;
    }
    return contentCell;
}

- (StoryDetailsShareCell *)shareCellForStory:(Story *)story {
    StoryDetailsShareCell *shareCell = [self.tableView dequeueReusableCellWithIdentifier:@"shareCell"];
    if (story) {
        [shareCell.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [shareCell.wantToWorkButton addTarget:self action:@selector(likeFromWannaWork:) forControlEvents:UIControlEventTouchUpInside];
        [shareCell.reportButton addTarget:self action:@selector(reportButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return shareCell;
}

- (void)likeFromWannaWork:(UIButton *)sender {
    //[self.dragVibeView animateManually];
    
    CompanyLookingForViewController *lookingForViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"companyLookingForViewController"];
    lookingForViewController.company = self.company;
    [self showViewController:lookingForViewController sender:self];
    
    [[Mixpanel sharedInstance] track:kLikeVibe properties:@{
                                                @"LikeFromWannaWork" : @(1),
                                                kCompany : self.company.companyName
                                              }];
    
}

- (StoryDetailsCategoryCell *)categoryCellForStory:(Story *)story {
    StoryDetailsCategoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
    if (story) {
        NSMutableArray *categoryNames = [NSMutableArray new];
        for (StoryCategory *category in story.categories) {
            if (category.categoryName) {
                [categoryNames addObject:category.categoryName];
            }
        }
        [cell setCategories:categoryNames];
        [cell setDelegate:self];
    }
    return cell;
}

- (StoryDetailsQuestionCell *)questionCellForStory:(Story *)story {
    StoryDetailsQuestionCell *questionCell = [self.tableView dequeueReusableCellWithIdentifier:@"questionCell"];
    if (story) {
        questionCell.titleLabel.text = story.storyTitle;
        if (story.author.profileImageLink || story.author.fullName) {
            if (story.author.profileImageLink) {
                [questionCell.authorImageView sd_setImageWithURL:[NSURL URLWithString:story.author.profileImageLink] placeholderImage:[UIImage imageNamed:@"user_avatar"]];
            } else {
                [questionCell.authorImageView setImage:[UIImage imageNamed:@"user_avatar"]];
            }
            NSString *highlightedString = story.author.fullName;
            NSString *authorString = [NSString stringWithFormat:@"%@ asks:", highlightedString];
            
            NSMutableAttributedString *attributedString = [TTUtils attributedStringForString:authorString highlight:highlightedString highlightedColor:UIColorFromRGB(0xffffff) defaultColor:UIColorFromRGB(0xffffff)];
            questionCell.authorLabel.attributedText = attributedString;
        } else {
            questionCell.authorImageView.image = [UIImage imageNamed:@"user_avatar"];
            questionCell.authorLabel.attributedText = nil;
        }
        if (story.storyUpdateTime) {
            NSString *dot = @"·";
            [questionCell.dateLabel setText:[NSString stringWithFormat:@"%@ %@", [[[[TTUtils sharedUtils] postDateFormatter] stringFromDate:story.storyUpdateTime] uppercaseString], dot]];
        }
        [questionCell setIndex:[self.company indexOfStoryByType:self.currentStory]];
    }
    return questionCell;
}

- (NSMutableAttributedString *)attributedStringForString:(NSString *)string highlight:(NSString *)highlight {
    return [TTUtils attributedStringForString:string highlight:highlight highlightedColor:UIColorFromRGB(0x8d8d8d) defaultColor:UIColorFromRGB(0x8d8d8d)];
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (indexPath.section == SectionComments) {
        Comment *comment = [self.commentsContainer objectAtIndex:indexPath.row];
#warning Check if we are able to update comment
        [self editComment:comment];
    }*/
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark StoryDetailsCategoryCell delegate

- (void)storyDetailsCategoryCell:(StoryDetailsCategoryCell *)cell didSelectCategoryAtIndex:(NSInteger)index {
    [self presentStoryFeedForCategory:[self.currentStory.categories objectAtIndex:index]];
}

#pragma mark Modal views

- (void)presentImagesViewForStory:(Story *)story {
    StoryImagesViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"storyImagesViewController"];
    controller.imagesArray = story.storyImages;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)presentWebViewForStory:(Story *)story {
    if (story.videoLink) {
        StoryWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"storyWebViewController"];
        [controller setUrl:[NSURL URLWithString:story.videoLink]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)presentStoryFeedForCategory:(StoryCategory *)storyCategory {
    if (storyCategory) {
        SearchResultsFeedViewController *results = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsFeedViewController"];
        [results setSelectedCategory:storyCategory];
        [self.navigationController pushViewController:results animated:YES];
    }
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentStory.storyType != StoryTypeMultimedia ? self.currentStory.storyImages.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = (self.currentStory.storyType == StoryTypeMultimedia) ? @"multimediaCell" : @"cell";
    StoryDetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (self.currentStory.storyImages.count) {
        DejalActivityView *activityUView = [DejalActivityView activityViewForView:cell];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[self.currentStory.storyImages objectAtIndex:indexPath.row] objectForKeyOrNil:kRegularImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image && !error) {
                if (self && collectionView && indexPath) {
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
                if ([indexPath isEqual:collectionView.indexPathsForVisibleItems.firstObject]) {
                    //CGFloat height = (image.size.width * self.imageView.bounds.size.height) / self.imageView.bounds.size.width;
                    self.currentImage = [image resizedImageToWidth:self.imageView.bounds.size.width];//[image cropToRect:CGRectMake(0, image.size.height - height, image.size.width, height)];
                }
            }
            [activityUView removeFromSuperview];
        }];
    } else if (self.currentStory.storyType == StoryTypeMultimedia) {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imageView sd_setImageWithURL:self.currentStory.videoThumbnailLink ? [NSURL URLWithString:self.currentStory.videoThumbnailLink] : [NSURL URLWithString:@"http://www.wpclipart.com/computer/keyboard_keys/special_keys/computer_key_Delete.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.currentImage = [image resizedImageToWidth:CGRectGetWidth([UIScreen mainScreen].bounds)]; //self.imageView.bounds.size.width
        }];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Story *story = self.currentStory;
    switch (story.storyType) {
        case StoryTypeStory: {
        } break;
        case StoryTypeLink: {
            [self presentImagesViewForStory:story];
        } break;
        case StoryTypeMultimedia: {
        } break;
        default: break;
    }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    UIImage *image;
    if (self.showImages) {
        if (scrollView.contentOffset.y >= [self heightForShowImageCellsForStory:self.currentStory] - self.headerView.frame.size.height) {
            image = self.currentImage;
            if (activateMotionManager) {
                activateMotionManager(NO);
            }
            [self playVideo:NO];
        } else {
            image = nil;
            if (activateMotionManager) {
                activateMotionManager(YES);
            }
        }
    } else {
        if (scrollView.contentOffset.y >= [self heightForImageCellForStory:self.currentStory] - self.headerView.frame.size.height) {
            image = self.currentImage;
            if (activateMotionManager) {
                activateMotionManager(NO);
            }
            [self playVideo:NO];
        } else {
            image = nil;
            if (activateMotionManager) {
                activateMotionManager(YES);
            }
        }
    }
    
    self.imageView.image = image;
    if (self.delegate) {
        [self.delegate headerViewBackgroundImage:image];
    }
}

#pragma mark Drag view handling

- (void)setupDragViewOnView:(UIView *)view {
    [view addSubview:self.dragVibeView];
    [self.dragVibeView setUserVibed:self.company.wannaWork];
    
    UIView *parent = view;
    UIView *child = self.dragVibeView;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    
    [parent layoutIfNeeded];
}

- (void)didHideDragView:(TTDragVibeView *)cell {
}

- (void)didFinishDecelerating {
    DLog(@"didFinishDecelerating %@", self.currentStory.videoLink);
    self.repeat = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self repeatEverySecondOnMain];
    });
}

- (void)didHideDragView {
    [DataManager sharedManager].likeOpen = NO;
}

#pragma mark View lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.commentsFooterView = [StoryDetailsFooterView loadFromXib];
    //self.commentsFooterView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"StoryHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"story"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LinkHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"link"];
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"question"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MultimediaHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"multimedia"];
    [self.tableView registerNib:[UINib nibWithNibName:@"StoryDetailsFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"storyDetailsFooterView"];
    
    [self slk_setScrollView:self.tableView];
    [self setInverted:NO];
    
    [self.view bringSubviewToFront:self.headerView];
    
    if (self.storyDetailsControllerType == StoryDetailsTypeViewController) {
        [self setupDragViewOnView:self.view];
    }
    
    if ([self.company.companyId isEqualToString:STORYFEED_DEFAULT_GENERAL_ID]) {
        self.tableView.tableHeaderView = nil;
    }
    
    //[self createBarButtonItem:self.navigationItem];
    self.currentStory.storyImages.count <= 1 ? [self hideImagesButtonPressed:nil] : [self showImagesButtonPressed:nil];
    self.tableView.dataSource = nil;
    
    if (self.shouldDownloadStory) {
        self.spinnerView.circleLayer.lineWidth = 3.0;
        self.spinnerView.circleLayer.strokeColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0].CGColor;
        [self.view bringSubviewToFront:self.spinnerView];
    
        [self createNavigationView];
        [self hideViews:YES];
        [self.spinnerView beginRefreshing];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:self.currentStory.storyId forKey:@"storyId"];
        [[DataManager sharedManager] getStoryWithParams:@{@"storyId" : self.currentStory.storyId} completionHandler:^(id result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView endRefreshing];
                self.spinnerView.hidden = YES;
                [self hideViews:NO];
                self.currentStory = [[Story alloc] initWithDictionary:result];
                [self didFinishDecelerating];
            });
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView setHeaderViewInsets:UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DLog(@"didFinishDecelerating %@", self.currentStory.videoLink);
    self.repeat = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self repeatEverySecondOnMain];
    });
    
    if (self.openedByDeeplink) {
        [self handleDeeplinkMode];
    }
}

- (void)hideViews:(BOOL)hide {
    if (self.storyDetailsControllerType == StoryDetailsTypeViewController) {
        self.tableView.hidden = hide;
        return;
    }
    //self.headerView.hidden = hide;
    self.tableView.hidden = hide;
}

-(void)handleDeeplinkMode
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStyleDone target:self action:@selector(closeButtonClicked)];
    self.navigationItem.leftBarButtonItem = doneButton;
}

-(void)closeButtonClicked
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)createNavigationView {
    CGFloat logoSize = 25;
    CGFloat space = 5;
    
    UILabel *companyName = [[UILabel alloc] init];
    companyName.text = self.currentStory.companyName;
    companyName.textColor = [UIColor whiteColor];
    companyName.textAlignment = NSTextAlignmentLeft;
    companyName.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:16];
    
    CGSize actualSize = [companyName sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 0.5 - logoSize + space, CGRectGetHeight(self.navigationController.navigationBar.bounds))];
    companyName.frame = CGRectMake(logoSize + space, 0, actualSize.width, CGRectGetHeight(self.navigationController.navigationBar.bounds));
    
    UIImageView *companyLogo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(companyName.frame) - (logoSize + space), CGRectGetMidY(self.navigationController.navigationBar.bounds) - (logoSize/2), logoSize, logoSize)];
    [companyLogo sd_setImageWithURL:[NSURL URLWithString:self.currentStory.companyLogo]];
    companyLogo.layer.cornerRadius = CGRectGetWidth(companyLogo.bounds)/2;
    
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, actualSize.width + logoSize, CGRectGetHeight(self.navigationController.navigationBar.bounds))];
    self.navigationItem.titleView = navigationView;
    
    [navigationView addSubview:companyName];
    [navigationView addSubview:companyLogo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationViewTapped)];
    [navigationView addGestureRecognizer:tap];
}

- (void)navigationViewTapped {
    if (self.canOpenCompanyDetails) {
        [self presentCompanyDetailsForCompany:self.company item:MenuItemStories];
    }
}

#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultSent:
            DLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            DLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            DLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            DLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            DLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)animateView:(BOOL)animate {
    if (!animate) {
        //[self.videoSpinnerView endRefreshing];
        [self.indicator stopAnimating];
        return;
    }
    
    [self.indicator.superview bringSubviewToFront:self.indicator];
    if (!self.indicator.isAnimating) {
        [self.indicator startAnimating];
    }
}

#pragma mark - Report Story

- (void)reportButtonPressed {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"REPORT A STORY"];
        
        NSString *html = [NSString stringWithFormat:@"<html><p><b>Tell us why you reporting this story:</p></b></br></br></br></br><img src=%@ style=\"width:100%%;\" width=\"100%%;\" /><p>%@</p></br>%@</br><p>ID: %@</p></html>", self.currentStory.storyImages && !self.currentStory.videoLink ? self.currentStory.storyImages[0][@"regular"] :  self.currentStory.videoThumbnailLink, self.currentStory.storyTitle, self.currentStory.storyContent, self.currentStory.storyId];
        [mail setMessageBody:html isHTML:YES];
        [mail setToRecipients:@[@"support@talenttribe.me"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    } else {
        NSLog(@"This device cannot send email");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.storyDetailsControllerType == StoryDetailsTypeViewController) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        //self.headerView.hidden = YES;
        self.companyImageView.hidden = YES;
        self.companyTitle.hidden = YES;
    }

    self.companyImageView.hidden = YES;
    self.companyTitle.hidden = YES;
    
    [self performSelectorOnMainThread:@selector(initializeMotionManager) withObject:nil waitUntilDone:NO];
    //self.currentPlayingLayer = [self playerLayerWithPlayer:self.player];
    //[self.videoContainerView.layer insertSublayer:self.currentPlayingLayer above:self.imageView.layer];
    
    self.imageView.image = self.currentImage;
    self.videoContainerView.hidden = YES;
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.block) {
        DLog(@"Block Canceled");
        dispatch_block_cancel(self.block);
        self.block = nil;
    }
    [self.player pause];
    self.player = nil;
    
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeStoryDetails];
    [DataManager sharedManager].likeOpen = NO;
    self.strongMotionManager = nil;
    self.motionManager = nil;
    self.playing = NO;
    self.repeat = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player pause];
   // [self.currentPlayingLayer removeFromSuperlayer];
}

- (NSTimeInterval)availableDurationForPlayerItem:(AVPlayerItem *)item {
    NSArray *loadedTimeRanges = [item loadedTimeRanges];
    if (loadedTimeRanges.count == 0) {
        return 0.0;
    }
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
    Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

#pragma mark Misc methods

- (void)dealloc {
    [self.companyImageView sd_cancelCurrentImageLoad];
    self.strongMotionManager = nil;
    self.motionManager = nil;
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeStoryDetails];
}

@end
