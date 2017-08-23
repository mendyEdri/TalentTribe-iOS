//
//  CompanyProfileViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/11/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TTDragVibeView.h"
#import "TTGradientHandler.h"
#import "UIViewController+Container.h"
#import "UIView+Additions.h"
#import "DataManager.h"
#import "TTSlidingMenuView.h"
#import "CompanyInfo.h"
#import "CompanyTabViewController.h"
#import "CompanyProfileHeaderView.h"
#import "TTSlidingViewController.h"
#import "TTTabBarController.h"
#import "User.h"

#define kHeaderProportions (320.0f / 165.0f)
#define kMinHeaderHeightMultiplier 0.5f

@interface CompanyProfileViewController () <TTSlidingViewControllerDataSource, TTSlidingViewControllerDelegate, TTDragVibeViewDelegate, TTScrollableViewDelegate>

@property (nonatomic, weak) IBOutlet TTCustomGradientView *headerContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, weak) IBOutlet CompanyProfileHeaderView *headerView;

@property (nonatomic, weak) TTSlidingViewController *slidingController;

@property (nonatomic, strong) TTDragVibeView *dragVibeView;

@property (nonatomic, strong) NSMutableDictionary *viewControllers;

@property BOOL animating;

@property CGFloat maxHeaderHeight;
@property CGFloat minHeaderHeight;
@property CGFloat companyTopMargin;
@property CGFloat companyNameWidth;

@property (nonatomic, assign) dispatch_once_t onceToken;

@property BOOL pendingVibe;

@end

@implementation CompanyProfileViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.pendingVibe = NO;
        self.viewControllers = [NSMutableDictionary new];
        self.dragVibeView = [TTDragVibeView loadFromXib];
        self.dragVibeView.delegate = self;
        self.currentSelectedItem = MenuItemStories;
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Data reloading 

- (void)reloadData {
    [self.dragVibeView setCurrentCompany:self.company];
    [self.dragVibeView setLikeTop:YES companyProfile:YES];
    [self.dragVibeView hideHiringButton:YES];
    [self.dragVibeView showLikeTitleLabel:YES];
    
    [self.headerView.companyImageView sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo]];
    [self.headerView setCompanyTitle:self.company.companyName];
    
    if (!self.company.companyInfo) {
        [TTActivityIndicator showOnView:self.view];
        [[DataManager sharedManager] companyInfoForCompany:self.company completionHandler:^(id result, NSError *error) {
            [self.slidingController setCurrentSelectedIndex:self.currentSelectedItem];
            [self.slidingController reloadData];
            [TTActivityIndicator dismiss];
        }];
        
    } else {
        [self.slidingController setCurrentSelectedIndex:self.currentSelectedItem];
        [self.slidingController reloadData];
    }
    
    if (self.pendingVibe) {
        DataManager *dMgr = [DataManager sharedManager];
        if ([dMgr isCredentialsSavedInKeychain] && [dMgr.currentUser isProfilePartiallyFilled]) {
            [self.dragVibeView performVibeActionManually];
        }
        self.pendingVibe = NO;
    }
    
}

#pragma mark Sliding handling

- (TTSlidingViewController *)slidingController {
    if (!_slidingController) {
        _slidingController = [self.storyboard instantiateViewControllerWithIdentifier:@"slidingViewController"];
        _slidingController.delegate = self;
        _slidingController.dataSource = self;
        [_slidingController setMenuEdgeInsets:UIEdgeInsetsMake(0.0f, 15.0f, 15.0f, 15.0f)];
        [self containerAddChildViewController:_slidingController toContainerView:self.contentContainer useAutolayout:YES];
    }

    return _slidingController;
}

- (CGFloat)heightForMenuInSlidingViewController:(TTSlidingViewController *)controller {
    return 40.0f;
}

- (NSInteger)numberOfItemsInSlidingViewController:(TTSlidingViewController *)controller {
    return menuItemsCount;
}

- (UIView <TTSlidingView> *)slidingViewController:(TTSlidingViewController *)controller viewForMenuItemAtIndex:(NSInteger)index {
    return [[TTSlidingMenuView alloc] initWithTitle:[self titleForMenuItem:(MenuItem)index]];
}

- (UIViewController *)slidingViewController:(TTSlidingViewController *)controller viewControllerAtIndex:(NSInteger)index {
    return [self viewControllerForMenuItem:(MenuItem)index];
}

#pragma mark SlidingViewController delegate

- (void)slidingViewController:(TTSlidingViewController *)controller didSelectItemAtIndex:(NSInteger)index {
    self.currentSelectedItem = (MenuItem)index;
}

#pragma mark Menu Items handling

- (NSString *)titleForMenuItem:(MenuItem)item {
    switch (item) {
        case MenuItemStories: {
            return @"STORIES";
        } break;
        case MenuItemAbout: {
            return @"ABOUT";
        } break;
        case MenuItemLookingFor: {
            return @"LOOKING FOR";
        } break;
        /*case MenuItemPeople: {
            return @"PEOPLE";
        } break;*/
        /*case MenuItemOurOffices: {
            return @"OUR OFFICES";
        } break;*/
        /*case MenuItemProducts: {
            return @"PRODUCTS";
        } break;*/
        default: {
            return nil;
        } break;
    }
}

- (CompanyTabViewController *)viewControllerForMenuItem:(MenuItem)item {
    if ([self.viewControllers objectForKey:@(item)]) {
        return [self.viewControllers objectForKey:@(item)];
    } else {
        NSString *identifier;
        switch (item) {
            case MenuItemStories: {
                identifier = @"companyStoriesViewController";
            } break;
            case MenuItemAbout: {
                identifier = @"companyAboutViewController";
            } break;
            /*case MenuItemPeople: {
                identifier = @"companyPeopleViewController";
            } break;*/
            case MenuItemLookingFor: {
                identifier = @"companyLookingForViewController";
            } break;
            /*case MenuItemOurOffices: {
                identifier = @"companyOfficesViewController";
            } break;*/
            /*case MenuItemProducts: {
                identifier = @"companyProductsViewController";
            } break;*/
            default: {
                return nil;
            } break;
        }
        if (identifier) {
            CompanyTabViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            [controller setCompany:self.company];
            controller.isProfileTab = YES;
            [controller setScrollDelegate:self];
            
            [self.viewControllers setObject:controller forKey:@(item)];
            return controller;
        }
    }
    return nil;
}

#pragma mark TTDragView delegate

- (void)willBeginDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
}

- (void)willEndDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    
}

- (void)profileOnDragVibeView:(TTDragVibeView *)cell {
    self.pendingVibe = YES;
    [(TTTabBarController *)self.rdv_tabBarController presentCreateUserProfileScreenAnimated:YES];
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
    [self wannaWorkInCompany:self.company completion:completion];
}

#pragma mark Wanna work handling

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

#pragma mark Alerts

- (void)showWannaWorkFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"It seems that you are interested in quite a few companies, that's very nice\r\nAnyway,It looks like you have reached your maximum daily quota.\r\nFeel free to continue looking for other companies, and tomorrow you will be able to express your interest in them" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Drag view handling

- (void)setupDragView {
    [self.view addSubview:self.dragVibeView];
    [self.dragVibeView setUserVibed:self.company.wannaWork];
    
    UIView *parent = self.view;
    UIView *child = self.dragVibeView;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    
    [parent layoutIfNeeded];
}

- (void)didHideDragView:(TTDragVibeView *)cell {
    
}

#pragma mark Scrolling header

- (UIView *)tt_headerView {
    return self.headerContainer;
}

- (CGFloat)tt_maxHeaderHeight {
    return self.maxHeaderHeight;
}

- (CGFloat)tt_minHeaderHeight {
    return self.minHeaderHeight;
}

- (CGFloat)tt_companyTopMargin {
    return self.companyTopMargin;
}

- (CGFloat)tt_companyNameWidth {
    return self.companyNameWidth;
}

- (NSLayoutConstraint *)tt_headerHeightConstraint {
    NSAssert(self.headerHeightConstraint != nil, @"Please specify header height constraint");
    return self.headerHeightConstraint;
}

- (void)tt_updateHeaderConstraints {
    self.headerHeightConstraint.constant = ceil(self.view.frame.size.width / kHeaderProportions);
    self.maxHeaderHeight = self.tt_headerHeightConstraint.constant;
    self.minHeaderHeight = ceil(self.tt_headerHeightConstraint.constant * kMinHeaderHeightMultiplier);
}

#pragma mark TTScrollableView delegate

- (void)scrollableView:(UIScrollView *)scrollableView scrollWithDelta:(CGFloat)delta onController:(id <TTScrollableViewProtocol>)controller {
    CGRect frame = self.tt_headerView.frame;
    
    BOOL shouldUpdate = NO;
    CGFloat height = 0.0f;
    
    if (delta > 0) {
        if (frame.size.height - delta < self.tt_minHeaderHeight) {
            delta = frame.size.height - self.tt_minHeaderHeight;
        }
        height = MAX(self.tt_minHeaderHeight, frame.size.height - delta);
        shouldUpdate = YES;
    }
    if (delta < 0) {
        if (frame.size.height + fabs(delta) > self.tt_maxHeaderHeight) {
            delta = self.tt_maxHeaderHeight - frame.size.height;
        }
        height = MIN(self.tt_maxHeaderHeight, frame.size.height + fabs(delta));
        shouldUpdate = YES;
    }
    
    if (shouldUpdate) {
        CGFloat progress = (self.tt_maxHeaderHeight - height) / (self.tt_maxHeaderHeight - self.tt_minHeaderHeight);
        self.tt_headerHeightConstraint.constant = height;
        
        [self.headerView setProgress:progress];
        
        [self.headerContainer setNeedsLayout];
        [self.headerContainer layoutIfNeeded];
        [controller restoreContentOffset:delta];
    }
}

- (void)scrollableView:(UIScrollView *)scrollableView checkForPartialScrollonController:(id<TTScrollableViewProtocol>)controller {
    CGFloat height = self.tt_headerView.frame.size.height - self.minHeaderHeight;
    CGFloat space = (self.maxHeaderHeight - self.minHeaderHeight) / 2.0f;
    CGFloat duration = 0.0f;
    CGFloat newHeight = height;
    static CGFloat maxDuration = 0.5f;
    if (height >= (space)) {
        duration = (ABS(space * 2 - height) / space) * maxDuration;
        newHeight = self.maxHeaderHeight;
    } else {
        duration = (ABS(height) / space) * maxDuration;
        newHeight = self.minHeaderHeight;
    }
    
    CGFloat progress = (self.tt_maxHeaderHeight - newHeight) / (self.tt_maxHeaderHeight - self.tt_minHeaderHeight);
    
    [self.headerView setProgress:progress withAnimationDuration:duration];
    
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.tt_headerHeightConstraint.constant = newHeight;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark View lifeCycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    dispatch_once(&_onceToken, ^{
        [self tt_updateHeaderConstraints];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyProfile];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDragView];
    [self.headerContainer setGradientType:TTGradientType8];
    [self.slidingController setMaxNumberOfMenuItemsOnScreen:menuItemsCount];
}

- (void)dealloc {
    [self.headerView.companyImageView sd_cancelCurrentImageLoad];
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyProfile];
}

@end
