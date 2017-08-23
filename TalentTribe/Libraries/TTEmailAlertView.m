//
//  TTEmailAlertView.m
//  TalentTribe
//
//  Created by Mendy on 22/09/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "TTEmailAlertView.h"
#import "UIView+Additions.h"
#import "TTRoundedCornersButton.h"

@interface TTEmailAlertView () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@property (nonatomic, weak) IBOutlet UIButton *acceptButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet TTRoundedCornersButton *largeCancelButton;

@property (nonatomic, weak)IBOutlet UIButton *closeButton;

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *acceptTitle;
@property (nonatomic, strong) NSString *cancelTitle;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@property BOOL animating;

@end

@implementation TTEmailAlertView

- (id)initWithMessage:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle {
    if (acceptTitle.length == 0 || cancelTitle.length == 0) {
        self = [self initWithMessage:message cancelTitle:acceptTitle.length > 0 ? acceptTitle : cancelTitle];
    } else {
        self = [TTEmailAlertView loadFromXib];
        if (self) {
            self.message = message;
            self.acceptTitle = acceptTitle;
            self.cancelTitle = cancelTitle;
            
            [self commonInit];
        }
    }
    return self;
}

- (id)initWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    self = [TTEmailAlertView loadFromXib];
    if (self) {
        self.message = message;
        self.cancelTitle = cancelTitle;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.isVisible = NO;
    self.animating = NO;
    
    self.contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentContainer.layer.shadowOpacity = 0.3f;
    self.contentContainer.layer.shadowRadius = 4.0f;
    self.contentContainer.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.contentContainer.layer.cornerRadius = 10.0;
    
    [self.largeCancelButton setCornerRadius:8];
    
    if (self.acceptTitle.length > 0 && self.cancelTitle.length > 0) {
        [self.acceptButton setHidden:NO];
        [self.cancelButton setHidden:NO];
        [self.largeCancelButton setHidden:YES];
        [self.acceptButton setTitle:self.acceptTitle forState:UIControlStateNormal];
        [self.cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
    } else {
        [self.acceptButton setHidden:YES];
        [self.cancelButton setHidden:YES];
        [self.largeCancelButton setHidden:NO];
        [self.largeCancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
    }
    
    self.emailTextField.layer.cornerRadius = 4;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"]) {
        self.emailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
    }
    [self.messageLabel setText:self.message];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.emailTextField resignFirstResponder];
}

- (IBAction)acceptButtonPressed:(id)sender {
    self.email = self.emailTextField.text;
    if (self.delegate) {
        [self.delegate emailAlertView:self pressedButtonWithindex:ButtonIndexAccept2];
    } else {
        [self dismiss:YES];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    self.email = self.emailTextField.text;
    if (self.delegate) {
        [self.delegate emailAlertView:self pressedButtonWithindex:ButtonIndexCancel2];
    } else {
        [self dismiss:YES];
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    self.email = self.emailTextField.text;
    if (self.delegate) {
        [self.delegate emailAlertView:self pressedButtonWithindex:ButtonIndexClose2];
    } else {
        [self dismiss:YES];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Apperance handling

- (void)showOnMainWindow:(BOOL)animated {
    @synchronized(self) {
        if (!self.isVisible && !self.animating) {
            self.animating = YES;
            self.contentContainer.alpha = 0.0f;
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            self.frame = mainWindow.bounds;
            [mainWindow addSubview:self];
            [UIView animateWithDuration:animated ? 0.3f : 0.0f delay:0.0f options:0 animations:^{
                self.contentContainer.alpha = 1.0f;
            } completion:^(BOOL finished) {
                self.animating = NO;
                self.isVisible = YES;
            }];
        }
    }
}

- (void)dismiss:(BOOL)animated {
    @synchronized(self) {
        if (self.isVisible && !self.animating) {
            self.animating = YES;
            [UIView animateWithDuration:animated ? 0.3f : 0.0f delay:0.0f options:0 animations:^{
                self.contentContainer.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                self.animating = NO;
                self.isVisible = NO;
            }];
        }
    }
}



@end
