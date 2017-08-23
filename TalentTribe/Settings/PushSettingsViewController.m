//
//  PushSettingsViewController.m
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "PushSettingsViewController.h"

@interface PushSettingsViewController ()

@end

@implementation PushSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomBackButton];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:3];
    [switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


- (void)switchValueChanged
{
    
}


@end
