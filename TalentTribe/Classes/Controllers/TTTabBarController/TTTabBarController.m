//
//  TTTabBarController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/22/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTTabBarController.h"
#import "StoryFeedViewController.h"
#import "ExploreViewController.h"
#import "CreateViewController.h"
#import "UserProfileViewController.h"
#import "UserProfileCreateViewController.h"
#import "UserProfileSummaryViewController.h"
#import "UserProfileSkillsViewController.h"
#import "NotificationsViewController.h"
#import "RDVTabBarItem.h"
#import "AssociateCompanyAlertViewController.h"

@interface TTTabBarController () <RDVTabBarControllerDelegate, AssociateCompanyAlertDelegate>

@property (nonatomic, strong) StoryFeedViewController *storyFeedViewController;
@property (nonatomic, strong) ExploreViewController *exploreViewController;
@property (nonatomic, strong) CreateViewController *createViewController;
@property (nonatomic, strong) UserProfileViewController *userProfileViewController;
@property (nonatomic, strong) UserProfileCreateViewController *userProfileCreateViewController;
@property (nonatomic, strong) UserProfileSummaryViewController *userProfileSummaryViewController;
@property (nonatomic, strong) NotificationsViewController *notificationsViewController;
@property (nonatomic, strong) NSArray *controllersClassArray;
@end

@implementation TTTabBarController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTabBarNotificationBadge) name:kRemoteNotification object:nil];
    }
    return self;
}

#pragma mark Getters

- (StoryFeedViewController *)storyFeedViewController {
    if (!_storyFeedViewController) {
        _storyFeedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyFeedViewController"];
    }
    return _storyFeedViewController;
}

- (ExploreViewController *)exploreViewController {
    if (!_exploreViewController) {
        _exploreViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreViewController"];
    }
    return _exploreViewController;
}

- (CreateViewController *)createViewController {
    if (!_createViewController) {
        _createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewController"];
    }
    return _createViewController;
}

- (UserProfileViewController *)userProfileViewController {
    if (!_userProfileViewController) {
        _userProfileViewController = [[UIStoryboard storyboardWithName:@"UserProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"userProfileViewController"];
    }
    return _userProfileViewController;
}

- (NotificationsViewController *)notificationsViewController {
    if (!_notificationsViewController) {
        _notificationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"notificationsViewController"];
    }
    return _notificationsViewController;
}

- (UserProfileCreateViewController *)userProfileCreateViewController {
    if (!_userProfileCreateViewController) {
        _userProfileCreateViewController = [[UIStoryboard storyboardWithName:@"UserProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"userProfileCreateViewController"];
    }
    return _userProfileCreateViewController;
}

- (UserProfileSummaryViewController *)userProfileSummaryViewController {
    if (!_userProfileSummaryViewController) {
        _userProfileSummaryViewController = [[UIStoryboard storyboardWithName:@"UserProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"userProfileSummaryViewController"];
    }
    return _userProfileSummaryViewController;
}

#pragma mark TabController delegate

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    BOOL (^handleSelection)(void) = ^(void){
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)viewController;
            [navController popToRootViewControllerAnimated:NO];
            if([navController isEqual:[self.viewControllers objectAtIndex:TabItemCreate]])
            {
                self.scheduledTabItem = TabItemFeed;
                if ([DataManager sharedManager].isCredentialsSavedInKeychain) {
                    __block User *user = [[DataManager sharedManager] currentUser];
                    if (!user.validatedCompanies || [user.validatedCompanies count] < 1) {
                        [self showCreateStoryAlert];
                        return NO;
                    }
                }
                [self presentCreateScreen];
                return NO;
            }
        }
        return YES;
    };
    
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)self.selectedViewController;
        if ([navController.viewControllers.firstObject isKindOfClass:[UserProfileViewController class]]) {
            UserProfileViewController *userProfile = (UserProfileViewController *)navController.viewControllers.firstObject;
            BOOL canMoveAway = [userProfile canMoveAwayFromController];
            if (canMoveAway) {
                return handleSelection();
            } else {
                self.scheduledTabItem = (TabItem)[self.viewControllers indexOfObject:viewController];
                return NO;
            }
        } else {
            return handleSelection();
        }
    } else {
        return handleSelection();
    }
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self notifyTabChange:(TabItem)[self.viewControllers indexOfObject:viewController]];
}

- (void)showCreateStoryAlert {
    UIStoryboard *alertStoryboard = [UIStoryboard storyboardWithName:@"Alert" bundle:nil];
    AssociateCompanyAlertViewController *alert = [alertStoryboard instantiateViewControllerWithIdentifier:@"associateCompanyAlertViewController"];
    alert.delegate = self;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentCreateScreen
{
    _createViewController = nil;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.createViewController];
    [navController.navigationBar setTranslucent:NO];
    BOOL animated = ([DataManager sharedManager].isCredentialsSavedInKeychain);

    [self.view.window makeKeyAndVisible];
    [self presentViewController:navController animated:animated completion:nil];
}

- (void)presentCreateUserProfileScreen {
    [self presentCreateUserProfileScreenAnimated:NO];
}

- (void)presentCreateUserProfileScreenAnimated:(BOOL)animated {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.userProfileSummaryViewController];
    [navController.navigationBar setTranslucent:NO];
    [self presentViewController:navController animated:animated completion:nil];
}


- (void)presentSettingsViewControllerScreen {
    UINavigationController *navController = (UINavigationController *)self.selectedViewController;
    if ([navController.viewControllers.firstObject isKindOfClass:[UserProfileViewController class]]) {
        UserProfileViewController *userProfile = (UserProfileViewController *)navController.viewControllers.firstObject;
        BOOL canMoveAway = [userProfile canMoveAwayFromController];
        if (canMoveAway) {
            [self presentSettingsViewController];
        } else {
            self.scheduledTabItem = TabItemSettings;
        }
    }
}

- (void)presentSettingsViewController {
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
    UIViewController *setttingsVC = [settingsStoryboard instantiateInitialViewController];
    [self presentViewController:setttingsVC animated:YES completion:^{
        
    }];
}

- (void)handleBackgroundScheduledTabSelection {
    if ([DataManager sharedManager].isCredentialsSavedInKeychain)
    {
        if (self.scheduledTabItem != TabItemNone && self.scheduledTabItem != TabItemCreate && self.scheduledTabItem != TabItemCreateUserProfile && self.scheduledTabItem != TabItemSettings)
        {
            [self notifyTabChange:self.scheduledTabItem];
            [self setSelectedIndex:self.scheduledTabItem];
            self.scheduledTabItem = TabItemNone;
        }
    }
}

- (void)handleForegroundScheduledTabSelection {
    if ([DataManager sharedManager].isCredentialsSavedInKeychain) {
        if (self.scheduledTabItem == TabItemCreate) {
            if ([[[DataManager sharedManager] currentUser] isProfileFilled]) {
                [self presentCreateScreen];
            }
        } else if (self.scheduledTabItem == TabItemCreateUserProfile) {
            [self presentCreateUserProfileScreen];
        }
        self.scheduledTabItem = TabItemNone;
    }
}

- (void)moveToTabItem:(TabItem)item {
    [self notifyTabChange:item];
    [self setSelectedIndex:item];
}

- (void)moveToScheduledTabItem {
    if ([DataManager sharedManager].isCredentialsSavedInKeychain) {
        if (self.scheduledTabItem != TabItemNone) {
            if (self.scheduledTabItem == TabItemCreate) {
                if ([[[DataManager sharedManager] currentUser] isProfileFilled]) {
                    [self presentCreateScreen];
                }
            } else if (self.scheduledTabItem == TabItemCreateUserProfile) {
                [self presentCreateUserProfileScreen];
            } else if (self.scheduledTabItem == TabItemSettings) {
                [self presentSettingsViewController];
            } else {
                [self notifyTabChange:self.scheduledTabItem];
                [self setSelectedIndex:self.scheduledTabItem];
            }
            self.scheduledTabItem = TabItemNone;
        }
    }
}

- (void)moveToProfileTab {
    UserProfileViewController *userProfile = (UserProfileViewController *)[[(UINavigationController *)[self.viewControllers objectAtIndex:TabItemUserProfile]  viewControllers] firstObject];
    [userProfile setScrollToEmptyField:YES];
    [self moveToTabItem:TabItemUserProfile];
}

- (void)moveToCreateStoryTab {
    [self presentCreateScreen];
}

- (void)notifyTabChange:(TabItem)item {
    UIViewController *controller = (UserProfileViewController *)[[(UINavigationController *)[self.viewControllers objectAtIndex:item]  viewControllers] firstObject];
    if ([controller respondsToSelector:@selector(handleTabChanged:)]) {
        [controller performSelector:@selector(handleTabChanged:) withObject:@(YES)];
    }
    /*if ([controller isKindOfClass:[UserProfileViewController class]]) {
        UserProfileViewController *userProfile = (UserProfileViewController *)controller;
        [userProfile setTabChanged:YES];
    }*/
}

#pragma mark - AssociateCompanyAlert Delegate

- (void)didClosedAlertViewControllerAndAssociationSucceed:(BOOL)succeed {
    if (succeed) {
        [self presentCreateScreen];
    }
}

#pragma mark View lifeCycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleForegroundScheduledTabSelection];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
    [self handleBackgroundScheduledTabSelection];
    
//    if (self.shouldContinueCreateStoryProcess && [DataManager sharedManager].isCredentialsSavedInKeychain) // if the user logged in and tried to open "CreateStory" before
//    {
//        self.shouldContinueCreateStoryProcess = NO;
//        [self presentCreateScreen];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBar setHeight:45.0f];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    UINavigationController *storyNavController = [[UINavigationController alloc] initWithRootViewController:self.storyFeedViewController];
    [storyNavController.navigationBar setTranslucent:NO];
    
    UINavigationController *exploreNavController = [[UINavigationController alloc] initWithRootViewController:self.exploreViewController];
    [exploreNavController.navigationBar setTranslucent:NO];
    
    UINavigationController *createNavController = [[UINavigationController alloc] initWithRootViewController:self.createViewController];
    [createNavController.navigationBar setTranslucent:NO];
    
    UINavigationController *notificationsNavController = [[UINavigationController alloc] initWithRootViewController:self.notificationsViewController];
    [notificationsNavController.navigationBar setTranslucent:NO];
    
    UINavigationController *userProfileCreateNavController = [[UINavigationController alloc] initWithRootViewController:self.userProfileSummaryViewController];
    [userProfileCreateNavController.navigationBar setTranslucent:NO];
    
    UINavigationController *userProfileNavController = [[UINavigationController alloc] initWithRootViewController:self.userProfileViewController];
    [userProfileNavController.navigationBar setTranslucent:NO];
    
    
    // KEEP "self.controllersClassArray" ALAWAYS ORDERD SAME AS "self.viewControllers"
    self.viewControllers = @[storyNavController, exploreNavController, createNavController, notificationsNavController, userProfileNavController];
    
    self.controllersClassArray = @[_storyFeedViewController, _exploreViewController, _createViewController, _notificationsViewController, _userProfileSummaryViewController];
    
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        NSString *imageName;
        switch (index) {
            case 0: {
                imageName = @"home";
            } break;
            case 1: {
                imageName = @"search";
            } break;
            case 2: {
                imageName = @"create";
            } break;
            case 3: {
                imageName = @"notifications";
            } break;
            case 4: {
                imageName = @"profile";
            } break;
            default:
                break;
        }
        if (imageName) {
            UIImage *normal = [UIImage imageNamed:imageName];
            UIImage *selected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_s", imageName]];
            [item setBackgroundUnselectedColor:UIColorFromRGB(0xFFFFFF)];
            [item setBackgroundSelectedColor:UIColorFromRGB(0x00B3EA)];
            [item setFinishedSelectedImage:selected withFinishedUnselectedImage:normal];
        }
        index++;
    }
    
    [self updateTabBarNotificationBadge];
}

- (void)updateTabBarNotificationBadge {
    RDVTabBarItem *item = [[self tabBar] items][3];
    item.badgePositionAdjustment = UIOffsetMake(-15, 0);
    NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    NSString *badgeValue;
    if (badgeNumber > 0) {
        badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeNumber];
    }
    item.badgeValue = badgeValue;
}

#pragma mark -

-(int)getTabNumberByClass:(id)controller
{
    int result = -1;
    for (id localController in self.controllersClassArray)
    {
        if (controller == [localController class])
        {
            result = (int)[self.controllersClassArray indexOfObject:localController];
            break;
        }
    }
    return result;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
