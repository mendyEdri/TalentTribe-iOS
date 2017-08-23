//
//  ChangePassViewController.m
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ChangePassViewController.h"

@interface ChangePassViewController ()
@property (strong, nonatomic) IBOutlet UITextField *passTextField;
@property (strong, nonatomic) IBOutlet UITextField *bottomPassTextField;

@end

@implementation ChangePassViewController

#pragma mark Interface actions

- (IBAction)savePressed:(id)sender {
    [self validateInputAndContinue];
}

- (void)validateInputAndContinue {
    if ([self validateInput]) {
        [self.view endEditing:YES];
        [TTActivityIndicator showOnMainWindow];
        [[DataManager sharedManager] updatePassword:self.passTextField.text newPassword:self.bottomPassTextField.text completionHandler:^(BOOL success, NSError *error) {
            if (success && !error) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [TTActivityIndicator dismiss];
                        [TTUtils showAlertWithText:error.userInfo[@"error"][@"reason"]];
                    });
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTActivityIndicator dismiss];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [TTUtils showAlertWithText:@"Please check your input"];
        });
    }
}

- (BOOL)validateInput {
    return [TTUtils validatePassword:self.passTextField.text] && [TTUtils validatePassword:self.bottomPassTextField.text];
}

#pragma mark Reload data

- (void)reloadData {
    
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
