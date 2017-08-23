//
//  DetailsPageViewController.m
//  TalentTribe
//
//  Created by Mendy on 27/10/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "DetailsPageViewController.h"
#import "StoryDetailsViewController.h"
#import "CompanyProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import "DataManager.h"
#import "TTTabBarController.h"
#import "GeneralMethods.h"
#import "SocialManager.h"
#import "CreateViewController.h"
#import "CreateStoryViewController.h"
#import "Author.h"
#import "User.h"
#import "JTMaterialSpinner.h"
#import "Mixpanel.h"

@interface DetailsPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, StoryDetailsProtocol, TTDragVibeViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (nonatomic, strong) UIBarButtonItem *shareBarItem;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *companyImageView;
@property (nonatomic, weak) IBOutlet UILabel *companyTitle;
@property (nonatomic, strong) StoryDetailsViewController *currentViewController;
@property (nonatomic, strong) UIButton *rightArrow;
@property (nonatomic, strong) UIButton *leftArrow;
@property (nonatomic, strong) NSMutableArray *dataContainer;

@property (nonatomic, strong) TTDragVibeView *dragVibeView;
@property (nonatomic, weak) IBOutlet JTMaterialSpinner *spinnerView;

@end

@implementation DetailsPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pages = [[NSMutableArray alloc] init];

    self.spinnerView.circleLayer.lineWidth = 3.0;
    self.spinnerView.circleLayer.strokeColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0].CGColor;
    [self.view bringSubviewToFront:self.spinnerView];

    [self loadHeaderViewData];
    [self initiatePageViewController];
    [self.currentViewController didFinishDecelerating];
}

- (void)initiatePageViewController {
    [self storiesViewControllerFromStoriesArray:[self companyStoriesSubstructHardFacts:self.company.storiesFeed.count ? [self.company.storiesFeed copy] : [self.company.stories copy]]];
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.startingIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:self.headerView];
    [self loadHeaderViewData];
    
    [self createStoriesArrowsButton];
    [self hideArrowsButtonsLeft:NO right:NO];
    
    [self createBarButtonItems:self.navigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self createNavigationView];
    [self createCustomBackButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.motionManager = nil;
    [self.currentViewController playVideo:NO];
    [self.dragVibeView hideVibeView];
}

- (void)loadHeaderViewData {
    StoryDetailsViewController *storyVC = [self viewControllerAtIndex:self.startingIndex];
    [storyVC.dragVibeView setCurrentCompany:self.company];
    [storyVC.dragVibeView setLikeTop:YES companyProfile:NO];
    
    self.companyImageView.hidden = YES;
    self.companyTitle.hidden = YES;
    
    if (self.company.companyLogo) {
        [self.companyImageView sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {//
            [storyVC setupDragViewOnView:self.view];
            storyVC.dragVibeView.delegate = self;
            self.dragVibeView = storyVC.dragVibeView;
            [self.dragVibeView hideHiringButton:YES];
            [self.dragVibeView showLikeTitleLabel:YES];
        }];
    }
    if (self.company.companyName) {
        self.companyTitle.attributedText = [TTUtils attributedCompanyName:self.company.companyName industry:self.company.industry];
    }
    
    [storyVC updateHeaderButtonsState];
}

- (void)reloadData {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            //[TTActivityIndicator showOnView:self.view];
            [self.dragVibeView setCurrentCompany:self.company];
            if (self.company.companyLogo) {
                [self.companyImageView sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo]];
            }
            if (self.company.companyName) {
                self.companyTitle.attributedText = [TTUtils attributedCompanyName:self.company.companyName industry:self.company.industry];
            } else {
                self.companyTitle.attributedText = nil;
            }
            loading = NO;
        }
    }
}

#pragma mark - TTDragView Delegate

- (void)unlikeVibeOnDragView:(TTDragVibeView *)cell {
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((StoryDetailsViewController*) viewController).pageIndex;
    
    self.currentIndex = index;
    self.currentStory = self.pages[self.currentIndex];
    [self updateLikeButtonState];
    [self hideArrowsButtonsLeft:NO right:NO];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    StoryDetailsViewController *storyController = [self viewControllerAtIndex:index];
    return storyController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((StoryDetailsViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    
    self.currentIndex = index;
    self.currentStory = self.pages[self.currentIndex];
    [self updateLikeButtonState];
    [self hideArrowsButtonsLeft:NO right:NO];
    index++;
    if (index == self.pages.count) {
        return nil;
    }
    StoryDetailsViewController *storyController = [self viewControllerAtIndex:index];
    return storyController;
}

- (StoryDetailsViewController *)viewControllerAtIndex:(NSUInteger)index {
    if ((index >= self.pages.count) && !self.openedByDeeplink) {
        return nil;
    }
    
    self.currentIndex = index;
    if (index >= self.pages.count - 3 && index > 0) {
        [self updateStoriesListWithIndex:self.pages.count atRow:self.row completion:^(id result, NSError *error) {
            if (result && !error) {
                [self storiesViewControllerFromStoriesArray:result];
                //[self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil]; // ? self.currentIndex - 1 : self.currentIndex
            }
        }];
    }

    // Create a new view controller and pass suitable data. (TT is change story object)
    Story *currentStory = self.openedByDeeplink ? self.currentStory : self.pages[index];
    if ([self viewControllerForStoryID:currentStory.storyId]) {
        [self updateLikeButtonState];
        self.currentViewController = [self viewControllerForStoryID:currentStory.storyId];
        return self.currentViewController;
    }

    StoryDetailsViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
    pageContentViewController.company = self.company;
    pageContentViewController.currentStory = self.openedByDeeplink ? self.currentStory : self.pages[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.storyDetailsControllerType = StoryDetailsTypePageController;
    pageContentViewController.delegate = self;
    self.dragVibeView.delegate = pageContentViewController;
    [pageContentViewController setDragHandler:^(BOOL visible){
        [self.leftArrow setHidden:visible];
        [self.rightArrow setHidden:visible];
    }];
    self.currentViewController = pageContentViewController;
    [self updateLikeButtonState];
    if (!self.viewControllers) {
        self.viewControllers = [[NSMutableArray alloc] init];
    }
    [self.viewControllers addObject:pageContentViewController];
    
    return pageContentViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
}

- (void)shareButtonPressed {
    [[self viewControllerForStoryID:self.currentStory.storyId] playVideo:NO];
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

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (StoryDetailsViewController *)viewControllerForStoryID:(NSString *)storyID {
    for (StoryDetailsViewController *viewController in self.viewControllers) {
        if ([viewController.currentStory.storyId isEqualToString:storyID]) {
            return viewController;
        }
    }
    return nil;
}

#pragma mark - StoryDetailsViewController Delegate

- (void)headerViewBackgroundImage:(UIImage *)backgroundImage {
    backgroundImage ? [self hideArrowsButtonsLeft:YES right:YES] : [self hideArrowsButtonsLeft:NO right:NO];
    backgroundImage ? [self endableScrollToSides:NO] : [self endableScrollToSides:YES];
    self.imageView.image = backgroundImage;
}

- (void)openProfilePage {
    [(TTTabBarController *)self.rdv_tabBarController moveToProfileTab];
}

#pragma mark ContentView Methods

- (void)createStoriesArrowsButton {
    self.rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat buttonDiameter = 60;
    self.rightArrow.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - buttonDiameter, (CGRectGetWidth([UIScreen mainScreen].bounds) / 2) - buttonDiameter/2, buttonDiameter, buttonDiameter);
    [self.rightArrow setImage:[UIImage imageNamed:@"next_s"] forState:UIControlStateNormal];
    [self.rightArrow addTarget:self action:@selector(moveNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightArrow];
    
    self.leftArrow.frame = CGRectMake(0, (CGRectGetWidth([UIScreen mainScreen].bounds) / 2) - buttonDiameter/2, buttonDiameter, buttonDiameter);
    [self.leftArrow setImage:[UIImage imageNamed:@"back_s"] forState:UIControlStateNormal];
    [self.leftArrow addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftArrow];
}

- (void)hideArrowsButtonsLeft:(BOOL)hideLeft right:(BOOL)hideRight {
    if (self.pages.count == 1) {
        hideLeft = YES;
        hideRight = YES;
    } else if (self.currentIndex == 0) {
        hideLeft = YES;
    } else if (self.currentIndex == self.pages.count-1) {
        hideRight = YES;
    }
    
    [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:12.0 options:kNilOptions animations:^{
        hideLeft ? [self alphaView:self.leftArrow alpha:0.0] : [self alphaView:self.leftArrow alpha:1.0];
        hideRight ? [self alphaView:self.rightArrow alpha:0.0] : [self alphaView:self.rightArrow alpha:1.0];
    } completion:nil];
}

- (void)alphaView:(UIView *)view alpha:(CGFloat)alpha {
    view.alpha = alpha;
}

- (void)endableScrollToSides:(BOOL)enable {
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = enable;
        }
    }
}

- (void)createCustomBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"back"];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_s"] forState:UIControlStateHighlighted];
    [backButton setFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backBarItem;
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
    [companyLogo sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo]];
    companyLogo.layer.cornerRadius = CGRectGetWidth(companyLogo.bounds)/2;
    
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, actualSize.width + logoSize, CGRectGetHeight(self.navigationController.navigationBar.bounds))];
    self.navigationItem.titleView = navigationView;
    
    [navigationView addSubview:companyName];
    [navigationView addSubview:companyLogo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationViewTapped)];
    [navigationView addGestureRecognizer:tap];
    
//    navigationView.backgroundColor = [UIColor blackColor];
//    companyName.backgroundColor = [UIColor redColor];
}

- (IBAction)showCompanyDetails:(id)sender {
    if (self.canOpenCompanyDetails) {
        [self presentCompanyDetailsForCompany:self.company item:MenuItemStories];
    }
}

- (void)navigationViewTapped {
    if (self.canOpenCompanyDetails) {
        [self presentCompanyDetailsForCompany:self.company item:MenuItemStories];
    }
}

- (void)moveNext {
    UIViewController *vc = [self pageViewController:self.pageViewController viewControllerAfterViewController:[self viewControllerAtIndex:self.currentIndex]];
    __weak StoryDetailsViewController *weakSelf = (StoryDetailsViewController *)vc;
    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [weakSelf didFinishDecelerating];
    }];
    NSLog(@"Current Index %ld", (long)self.currentIndex);
    self.currentStory = self.pages[self.currentIndex];
    DLog(@"Story Title %@", self.currentStory.storyTitle);
    DLog(@"Story index %ld", self.currentIndex);
    [self hideArrowsButtonsLeft:NO right:NO];
    [self updateLikeButtonState];
}

- (void)moveBack {
    UIViewController *vc = [self pageViewController:self.pageViewController viewControllerBeforeViewController:[self viewControllerAtIndex:self.currentIndex]];
    __weak StoryDetailsViewController *weakSelf = (StoryDetailsViewController *)vc;
    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        [weakSelf didFinishDecelerating];
    }];
    NSLog(@"Current Index %ld", (long)self.currentIndex);
    self.currentStory = self.pages[self.currentIndex];
    DLog(@"Story Title %@", self.currentStory.storyTitle);
    DLog(@"Story index %ld", self.currentIndex);
    [self hideArrowsButtonsLeft:NO right:NO];
    [self updateLikeButtonState];
}

- (void)presentCompanyDetailsForCompany:(Company *)company item:(MenuItem)item {
    [[Mixpanel sharedInstance] track:kCompanyProfile properties:@{
                                                                  kScreenName : @"StoryDetails",
                                                                  kCompany : company.companyName
                                                                  }];
    CompanyProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"companyProfileViewController"];
    controller.company = company;
    controller.currentSelectedItem = item;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateStoriesListWithIndex:(NSInteger)index atRow:(NSInteger)row completion:(SimpleResultBlock)completion {
    DLog(@"Index load %ld", index);
    [[DataManager sharedManager] storyFeedIndexesForXAxis:index inRow:row maxCount:5 completionHandler:^(id result, NSError *error) {
        if (!error && result) {
            DLog(@"Details: First X ids %@", result);
            NSDictionary *params = @{@"ids" : result,
                                     @"size" : [GeneralMethods screenSizeDict]
                                     };
            
            [[DataManager sharedManager] storyFeedIndexesWithParams:nil forceReload:NO completionHandler:^(id result, NSError *error) {
                [[DataManager sharedManager] storiesByIds:params orderByIndexes:result completionHandler:^(id result, NSError *error) {
                    if (result && !error) {
                        if (!self.dataContainer) {
                            self.dataContainer = [[NSMutableArray alloc] init];
                        }
                        
                        NSMutableArray *newStories = [NSMutableArray new];
                        NSMutableArray *urls = [NSMutableArray new];
                        for (Company *company in result) {
                            for (Story *story in company.stories) {
                                [self.dataContainer addObject:story];
                                [newStories addObject:story];
                                NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
                                if (story.videoLink) {
                                    DLog(@"New Story VideoLink %@", story.videoLink);
                                }
                                if (url) {
                                    DLog(@"Downloading story image with URL %@", url);
                                    [urls addObject:url];
                                }
                            }
                        }
                        
                        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
                        
                        if (completion) {
                            completion(newStories, error);
                        }
                    }
                }];
            }];
        }
    }];
}

- (void)storiesViewControllerFromStoriesArray:(NSArray *)storiesArray {
    for (Story *story in storiesArray) {
        if (!story.storyId) {
            continue;
        }
        if (story.storyType == StoryTypeHardFacts) {
            continue;
        }
        if ([self.pages containsObject:story]) {
           continue;
        }
        
        StoryDetailsViewController *storyDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
        storyDetails.company = self.company;
        storyDetails.currentStory = story;
        storyDetails.storyDetailsControllerType = StoryDetailsTypePageController;
        [self.pages addObject:story];
    }
    
    [self hideArrowsButtonsLeft:NO right:NO];
}

- (void)createBarButtonItems:(UINavigationItem *)item {
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *shareImage = [UIImage imageNamed:@"share"];
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    [shareButton setFrame:CGRectMake(0, 0, shareImage.size.width * 1.5, shareImage.size.height)];
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.shareBarItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    item.rightBarButtonItems = @[self.shareBarItem];
}

- (void)updateLikeButtonState {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dragVibeView setUserVibed:self.currentStory.userLike];
    });
}

- (NSArray *)companyStoriesSubstructHardFacts:(NSArray *)stories {
    NSMutableArray *cleanStories = [NSMutableArray new];
    for (Story *story in stories) {
        if (story.storyType == StoryTypeHardFacts) {
            continue;
        }
        [cleanStories addObject:story];
    }
    return [cleanStories copy];
}

- (void)enableScrolling:(BOOL)enable {
    //[self setScrollingEnabled:enable];
    //[self.tableView setScrollEnabled:enable];
}

- (void)showWannaWorkFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"It seems that you are interested in quite a few companies, that's very nice\r\nAnyway,It looks like you have reached your maximum daily quota.\r\nFeel free to continue looking for other companies, and tomorrow you will be able to express your interest in them" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
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

- (NSInteger)companyStoriesCountSubtractHardFact:(Company *)company {
    return [self isCompanyContainsHardFactCell:company] ? company.stories.count - 1 : company.stories.count;
}

- (BOOL)isCompanyContainsHardFactCell:(Company *)company {
    for (Story *story in company.stories) {
        if (story.storyType == StoryTypeHardFacts) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    DLog(@"BEGIN DEVELERATING");
}

#pragma mark - TTDragView Delegate

- (void)willBeginDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    [self enableScrolling:NO];
}

- (void)willEndDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    [self enableScrolling:YES];
}

- (void)profileOnDragVibeView:(TTDragVibeView *)cell {
    [(TTTabBarController *)self.rdv_tabBarController presentCreateUserProfileScreenAnimated:YES];
}

- (void)signupOnDragVibeView:(TTDragVibeView *)cell {
    [[DataManager sharedManager] showLoginScreen];
}

- (void)vibeOnDragVibeView:(TTDragVibeView *)cell completion:(SimpleCompletionBlock)completion {
   [self likeStory:self.currentStory inCompany:self.company completion:^(BOOL success, NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [TTActivityIndicator dismiss];
       });
       if (!error && success) {
           //
       } else {
           // show error
       }
       completion(success, error);
   }];
}

- (void)didHideDragView:(TTDragVibeView *)cell {
    [self enableScrolling:YES];
}

- (void)dealloc {
    self.motionManager = nil;
}

@end
