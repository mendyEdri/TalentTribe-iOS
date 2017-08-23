//
//  AssociateCompanyAlertViewController.m
//  TalentTribe
//
//  Created by Mendy on 23/12/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "AssociateCompanyAlertViewController.h"
#import "DataManager.h"

typedef enum : NSUInteger {
    Email,
    Code,
} validationMode;

@interface AssociateCompanyAlertViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *close;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *codeExistButton;
@property (assign, nonatomic) validationMode mode;
@end

@implementation AssociateCompanyAlertViewController

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClosedAlertViewControllerAndAssociationSucceed:)]) {
            [self.delegate didClosedAlertViewControllerAndAssociationSucceed:NO];
        }
    }];
}

- (IBAction)send:(id)sender {
    if (self.mode == Email) {
        if ([DataManager validateEmail:self.textField.text]) {
            [self associateEmail:self.textField.text];
            [self.textField resignFirstResponder];
        } else {
            self.textField.textColor = [UIColor redColor];
        }
        [self.textField resignFirstResponder];
        return;
    }
    if (self.textField.text.length < 3) {
        [self.textField resignFirstResponder];
        return;
    }
    [self validateCode:self.textField.text];
    [self.textField resignFirstResponder];
}

- (IBAction)codeExist:(id)sender {
    if (self.mode == Email) {
        self.mode = Code;
        [self setTextsForMode:self.mode];
        return;
    }
    self.mode = Email;
    [self setTextsForMode:self.mode];
}

- (void)associateEmail:(NSString *)email {
    [[DataManager sharedManager] validateUserEmailToCompany:email completion:^(BOOL success, NSError *error) {
        if (!error && success) {
            self.mode = Code;
            [self setTextsForMode:self.mode];
         } else {
             NSString *reason = [error userInfo][@"error"][@"reason"];
             if (!reason) {
                 reason = @"Something went wrong. probably we working to fix it by now.";
                 return ;
             }
             DLog(@"Error %@", reason);
             [self animateLabel:self.descriptionLabel withText:reason];
         }
     }];
}

- (void)validateCode:(NSString *)code {
    [[DataManager sharedManager] validateUserCodeToCompany:code completion:^(BOOL codeIsOK, NSError *error) {
        [TTActivityIndicator dismiss];
        if (!error) {
            if (codeIsOK) {
                [self animateLabel:self.descriptionLabel withText:@""];
                __block id weakDelegate = self.delegate;
                [self dismissViewControllerAnimated:YES completion:^{
                    if (weakDelegate && [weakDelegate respondsToSelector:@selector(didClosedAlertViewControllerAndAssociationSucceed:)]) {
                        [weakDelegate didClosedAlertViewControllerAndAssociationSucceed:YES];
                    }
                }];
            }
            else {
                [self animateLabel:self.descriptionLabel withText:@"Opps..wrong code :("];
            }
        } else if (error) {
            [self animateLabel:self.descriptionLabel withText:@"Something went wrong. Please try again later"];
        }
    }];
}

- (void)setTextsForMode:(validationMode)mode {
    if (mode == Code) {
        __block NSString *email = self.textField.text;
        self.textField.placeholder = @"Insert Code";
        self.textField.text = @"";
        [self.codeExistButton setTitle:@"OK. I don't have code." forState:UIControlStateNormal];
        [self animateLabel:self.titleLabel withText:@"One step a way."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateLabel:self.descriptionLabel withText:email.length ? [NSString stringWithFormat:@"Check %@ for access code", email] : @"Insert Your Code:"];
        });
        return;
    }
    
    [self animateLabel:self.titleLabel withText:@"Share your company culture and vibe with stories and videos."];
    [self animateLabel:self.descriptionLabel withText:@"Please let us know which company you work for."];
    self.textField.placeholder = @"Your Work Email";
    self.textField.text = @"";
    [self.codeExistButton setTitle:@"I Have Code" forState:UIControlStateNormal];
}

- (void)animateLabel:(UILabel *)label withText:(NSString *)text {
    [UIView animateWithDuration:0.7 delay:0.0 options:kNilOptions animations:^{
        label.alpha = 0.0;
    } completion:^(BOOL finished) {
        label.text = text;
        [UIView animateWithDuration:0.4 delay:0.0 options:kNilOptions animations:^{
            label.alpha = 1.0;
        } completion:nil];
    }];
}

#pragma mark - UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.textField.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send:self.sendButton];
    return YES;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
    self.textField.layer.cornerRadius = 4.0;
    self.descriptionLabel.alpha = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.descriptionLabel.alpha == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateLabel:self.descriptionLabel withText:self.descriptionLabel.text];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
