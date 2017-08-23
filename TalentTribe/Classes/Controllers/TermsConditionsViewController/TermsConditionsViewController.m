//
//  TermsConditionsViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/11/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TermsConditionsViewController.h"
#import "UIViewController+Modal.h"
#import "RootNavigationController.h"
#import "UIViewController+RootNavigationController.h"

@interface TermsConditionsViewController ()

@end

@implementation TermsConditionsViewController

#pragma mark Interface actions

- (IBAction)applyButtonPressed:(id)sender {
    if (self.isModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.rootNavigationController moveToTabBar:YES];
    }
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL hideNavBar = ([self.parentViewController isMemberOfClass:[RootNavigationController class]]);
    
    [self.navigationController setNavigationBarHidden:hideNavBar animated:animated];
}

@end
