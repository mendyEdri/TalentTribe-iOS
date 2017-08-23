//
//  ChangeEmailViewController.m
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "User.h"

@interface ChangeEmailViewController ()

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@end

@implementation ChangeEmailViewController

#pragma mark Interface actions

- (IBAction)savePressed:(id)sender {
    [self validateInputAndContinue];
}

- (void)validateInputAndContinue {
    if ([self validateInput]) {
        [self.view endEditing:YES];
        User *user = [[[DataManager sharedManager] currentUser] copy];
        user.userEmail = self.emailTextField.text;
        [TTActivityIndicator showOnMainWindow];
        [[DataManager sharedManager] updateUser:user completionHandler:^(BOOL success, NSError *error) {
            if (success && !error) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if (error) {
                    [TTUtils showAlertWithText:@"Unable to update at the moment"];
                }
            }
            [TTActivityIndicator dismiss];
        }];
    } else {
        [TTUtils showAlertWithText:@"Please check your input"];
    }
}

- (BOOL)validateInput {
    return [TTUtils validateEmail:self.emailTextField.text];
}

#pragma mark Reload data

- (void)reloadData {
    self.emailTextField.text = [[[DataManager sharedManager] currentUser] userEmail];
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomBackButton];
}

@end
