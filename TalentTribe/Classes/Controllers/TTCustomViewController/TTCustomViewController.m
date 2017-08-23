//
//  TTCustomViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/7/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTCustomViewController.h"

@implementation TTCustomViewController

#pragma mark View lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![self.navigationController.viewControllers.firstObject isEqual:self]) {
        [self createCustomBackButton];
    }
}

#pragma mark Misc methods

- (void)createCustomBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"back"];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_s"] forState:UIControlStateHighlighted];
    [backButton setFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backBarItem;
}

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
