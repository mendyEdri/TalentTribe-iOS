//
//  UserProfileViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/23/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserProfileHeaderView.h"
#import "UserProfileTabProfileViewController.h"
#import "TTSlidingViewController.h"
#import "UIViewController+Container.h"
#import "TTSlidingMenuView.h"
#import "TTTabBarController.h"
#import "RDVTabBarController.h"

typedef enum {
    MenuItemProfile,
    MenuItemLiked,
    MenuItemStories,
    menuItemsCount,
    MenuItemNone
} MenuItem;

#define kHeaderProportions (320.0f / 210.0f)
#define kMinHeaderHeightMultiplier 0.4f

@interface UserProfileViewController () <TTSlidingViewControllerDataSource, TTSlidingViewControllerDelegate, UserProfileTabProfileViewControllerDelegate, TTScrollableViewDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (nonatomic, weak) TTSlidingViewController *slidingController;

@property (nonatomic, strong) NSMutableDictionary *viewControllers;

@property (nonatomic) MenuItem currentSelectedItem;
@property (nonatomic) MenuItem scheduledItem;

@property CGFloat maxHeaderHeight;
@property CGFloat minHeaderHeight;
@property CGFloat companyTopMargin;
@property CGFloat companyNameWidth;

@property (nonatomic, assign) dispatch_once_t onceToken;

@property BOOL tabChanged;
@property BOOL loginScreenShown;

@property (nonatomic, strong) NSTimer *loginTimer;

@end

@implementation UserProfileViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.loginScreenShown = NO;
        self.tabChanged = YES;
        self.setupObservations = NO;
        self.viewControllers = [NSMutableDictionary new];
        self.currentSelectedItem = MenuItemProfile;
        self.scheduledItem = MenuItemNone;
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)settingsButtonPressed:(id)sender {
    [self.view endEditing:YES];
    [(TTTabBarController *)self.rdv_tabBarController presentSettingsViewControllerScreen];
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.view endEditing:YES];
    UserProfileTabProfileViewController *userProfile = (UserProfileTabProfileViewController *) [self viewControllerForMenuItem:MenuItemProfile];
    [userProfile saveButtonPressed];
}

#pragma mark Data reloading

- (void)reloadData {
    if (self.loginScreenShown) {
        self.loginScreenShown = NO;
        if ([DataManager sharedManager].isCredentialsSavedInKeychain) {
            [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemUserProfile];
        } else {
            [(TTTabBarController *)self.rdv_tabBarController moveToTabItem:TabItemFeed];
        }
    } else {
        if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
            [self setBackButtonHidden:YES];
            [self.settingsButton setHidden:NO];
        } else {
            [self setBackButtonHidden:NO];
            [self.settingsButton setHidden:YES];
        }
        
        self.headerView.bottomConstraint.constant = 30.0f;
        [self.headerView layoutIfNeeded];
        
        [self.slidingController setCurrentSelectedIndex:self.currentSelectedItem];
        [self.slidingController reloadData];
    }
}

#pragma mark Sliding handling

- (TTSlidingViewController *)slidingController {
    if (!_slidingController) {
        _slidingController = [self.storyboard instantiateViewControllerWithIdentifier:@"slidingViewController"];
        _slidingController.delegate = self;
        _slidingController.dataSource = self;
        _slidingController.maxNumberOfMenuItemsOnScreen = menuItemsCount;
        [_slidingController setMenuEdgeInsets:UIEdgeInsetsMake(0.0f, 15.0f, 10.0f, 15.0f)];
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

- (BOOL)slidingViewController:(TTSlidingViewController *)controller shouldSelectItemAtIndex:(NSInteger)index {
    if (self.currentSelectedItem == MenuItemProfile) {
        UserProfileTabProfileViewController *profileTab = (UserProfileTabProfileViewController *) [self viewControllerForMenuItem:MenuItemProfile];
        self.scheduledItem = (MenuItem)index;
        return [profileTab handleMoveAwayFromControllerOnSlide];
    }
    return YES;
}

- (void)slidingViewController:(TTSlidingViewController *)controller didSelectItemAtIndex:(NSInteger)index {
    self.currentSelectedItem = (MenuItem)index;
}

#pragma mark Menu Items handling

- (NSString *)titleForMenuItem:(MenuItem)item {
    switch (item) {
        case MenuItemProfile: {
            return @"MY PROFILE";
        } break;
        case MenuItemLiked: {
            return @"LIKED COMPANIES";
        } break;
        case MenuItemStories: {
            return @"MY STORIES";
        } break;
        default: {
            return nil;
        } break;
    }
}

- (UIViewController *)viewControllerForMenuItem:(MenuItem)item {
    if ([self.viewControllers objectForKey:@(item)]) {
        return [self.viewControllers objectForKey:@(item)];
    } else {
        NSString *identifier;
        switch (item) {
            case MenuItemProfile: {
                identifier = @"userProfileTabProfileViewController";
            } break;
            case MenuItemLiked: {
                identifier = @"userProfileTabLikedViewController";
            } break;
            case MenuItemStories: {
                identifier = @"userProfileTabStoriesViewController";
            } break;
            default: {
                return nil;
            } break;
        }
        if (identifier) {
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            if ([controller respondsToSelector:@selector(setDelegate:)]) {
                [controller performSelector:@selector(setDelegate:) withObject:self];
            }
            if ([controller respondsToSelector:@selector(setScrollDelegate:)]) {
                [controller performSelector:@selector(setScrollDelegate:) withObject:self];
            }
            if ([controller respondsToSelector:@selector(setTempUser:)]) {
                [controller performSelector:@selector(setTempUser:) withObject:self.tempUser];
            }
            [self.viewControllers setObject:controller forKey:@(item)];
            return controller;
        }
    }
    return nil;
}

- (BOOL)canMoveAwayFromController {
    UserProfileTabProfileViewController *userProfile = (UserProfileTabProfileViewController *)[self viewControllerForMenuItem:MenuItemProfile];
    return [userProfile handleMoveAwayFromController];
}

- (void)updateSaveButtonState {
    BOOL state = NO;
    if (self.tempUser) {
        state = ([self.tempUser isEqualToUser:[[DataManager sharedManager] currentUser]]);
    } else {
        state = YES;
    }
    self.saveButton.hidden = state;
}

#pragma mark UserProfileTabProfileViewController delegate

- (void)profileTabProfileViewController:(UserProfileTabProfileViewController *)controller shouldChangeSaveButtonState:(BOOL)hidden {
    self.saveButton.hidden = hidden;
}

- (void)profileTabProfileViewController:(UserProfileTabProfileViewController *)controller reloadUserState:(BOOL)reloadUser {
    self.reloadUser = reloadUser;
}

- (void)reloadUserOnProfileTabProfileViewController:(UserProfileTabProfileViewController *)controller {
    self.reloadUser = YES;
    [self reloadHeaderData];
    [controller setTempUser:self.tempUser];
}

- (void)moveAwayFromProfileTabProfileViewController:(UserProfileTabProfileViewController *)controller {
    if (self.scheduledItem != MenuItemNone) {
        [self.slidingController selectItemAtIndex:self.scheduledItem animated:YES completion:nil];
        self.currentSelectedItem = self.scheduledItem;
    }
    self.scheduledItem = MenuItemNone;
}

- (void)cancelMoveAwayFromProfileTabProfileViewController:(UserProfileTabProfileViewController *)controller {
    self.scheduledItem = MenuItemNone;
}

- (void)setScrollToEmptyField:(BOOL)scrollToEmptyField {
    UserProfileTabProfileViewController *userProfile = (UserProfileTabProfileViewController *) [self viewControllerForMenuItem:MenuItemProfile];
    [userProfile setScrollToEmptyField:scrollToEmptyField];
}

#pragma mark Header scrolling

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
    self.headerView.maxHeight = self.maxHeaderHeight;
    self.headerView.minHeight = self.minHeaderHeight;
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

#pragma mark Misc

- (void)handleUnregisteredUser {
    [self invalidateLoginTimer];
    if (self.tabChanged) {
        if (![[DataManager sharedManager] isCredentialsSavedInKeychain]) {
            [self.view setUserInteractionEnabled:NO];
            [self showLoginScreenAfterDelay];
        } else {
            [self.view setUserInteractionEnabled:YES];
        }
        self.tabChanged = NO;
    } else {
        [self.view setUserInteractionEnabled:YES];
    }
}

- (void)handleTabChanged:(NSNumber *)tabChanged {
    self.tabChanged = tabChanged.boolValue;
}

- (void)showLoginScreenAfterDelay {
    [self invalidateLoginTimer];
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showLoginScreen) userInfo:nil repeats:NO];
}

- (void)showLoginScreen {
    self.loginScreenShown = YES;
    [[DataManager sharedManager] showLoginScreen];
}

- (void)invalidateLoginTimer {
    if (self.loginTimer) {
        if ([self.loginTimer isValid]) {
            [self.loginTimer invalidate];
        }
    }
    self.loginTimer = nil;
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
    [self handleUnregisteredUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self invalidateLoginTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [self invalidateLoginTimer];
}

@end
