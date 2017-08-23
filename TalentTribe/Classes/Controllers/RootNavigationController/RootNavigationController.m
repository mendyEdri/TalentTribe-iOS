//
//  RootNavigationController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "RootNavigationController.h"
#import "DataManager.h"
#import "User.h"
#import "LinkedInToken.h"
#import "TalentTribe-Swift.h"
#import "StrokeLogoIndicator.h"

@interface RootNavigationController ()
@property BOOL restorationIdentifier;
@end

@implementation RootNavigationController

- (void)checkAndHandleCurrentView {
    DataManager *dMgr = [DataManager sharedManager];
    if ([dMgr isCredentialsSavedInKeychain]) {
        [self moveToTabBar:NO skip:NO];
    } else if ([dMgr isAnonymous]) {
        [self moveToTabBar:NO skip:YES];
    } else if (dMgr.currentUser.linkedInToken.isValid) {
        [self moveToSignupScreen:NO];
    } else {
        [self moveToLoginScreen:NO viewState:ViewStateRegular modal:NO];
    }
}

- (void)showLoginScreen:(NSNotification *)object
{
    BOOL modal = [object.object boolValue];
    if (modal)
    {
        [self moveToLoginScreen:YES viewState:ViewStateAction modal:YES];
    }
    else
    {
        [self moveToLoginScreen:YES viewState:ViewStateRegular modal:NO];
    }
}

- (void)moveToLoginScreen:(BOOL)animated {
    [self moveToLoginScreen:animated viewState:ViewStateRegular modal:NO];
}

- (void)moveToLoginScreen:(BOOL)animated viewState:(ViewState)state modal:(BOOL)modal
{
    self.delegate = nil;
    LoginSelectionViewController *loginController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginController.viewState = state;
    if (modal)
    {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        [navController setNavigationBarHidden:YES];
        
        [self presentViewController:navController animated:animated completion:nil];
    }
    else
    {
        [self setViewControllers:@[loginController] animated:animated];
    }
}

- (void)moveToTCScreen:(BOOL)animated {
    self.delegate = nil;
    UIViewController *tcController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"termsConditionsViewController"];
    [self setViewControllers:@[tcController] animated:animated];
}

- (void)moveToSignupScreen:(BOOL)animated {
    self.delegate = nil;
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginSelectionViewController *loginController = [loginStoryboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginController.viewState = ViewStateRegular;
    UIViewController *signupController = [loginStoryboard instantiateViewControllerWithIdentifier:@"loginSignupViewController"];
    [self setViewControllers:@[loginController, signupController] animated:animated];
}

- (void)moveToTabBar:(BOOL)animated {
    [self moveToTabBar:animated skip:YES];
}

- (void)moveToTabBar:(BOOL)animated skip:(BOOL)skip {
    self.delegate = nil;
    if (skip) {
        UIViewController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        [self setViewControllers:@[tabBarController] animated:animated];
    } else {
        //[TTActivityIndicator showOnMainWindowOnTop];
        [StrokeLogoIndicator showOnMainWindow];
        [[DataManager sharedManager] silentLoginWithCompletion:^(id result, NSError *error) {
            if (result && !error) {
                UIViewController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
                [self setViewControllers:@[tabBarController] animated:animated];
            } else {
                [self moveToLoginScreen:YES];
                [TTActivityIndicator dismiss];
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkAndHandleCurrentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen:) name:kShowLoginScreenNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
