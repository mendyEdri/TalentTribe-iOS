//
//  TTAlertView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/20/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "TTAlertView.h"
#import "UIView+Additions.h"

@interface TTAlertView ()

@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@property (nonatomic, weak) IBOutlet UIButton *acceptButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *largeCancelButton;

@property (nonatomic, weak)IBOutlet UIButton *closeButton;

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *acceptTitle;
@property (nonatomic, strong) NSString *cancelTitle;

@property BOOL animating;

@end

@implementation TTAlertView

#pragma mark Initialization

- (id)initWithMessage:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle {
    if (acceptTitle.length == 0 || cancelTitle.length == 0) {
        self = [self initWithMessage:message cancelTitle:acceptTitle.length > 0 ? acceptTitle : cancelTitle];
    } else {
        self = [TTAlertView loadFromXib];
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
    self = [TTAlertView loadFromXib];
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
    [self.messageLabel setText:self.message];
    
}

#pragma mark Interface actions

- (IBAction)acceptButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate alertView:self pressedButtonWithindex:ButtonIndexAccept];
    } else {
        [self dismiss:YES];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate alertView:self pressedButtonWithindex:ButtonIndexCancel];
    } else {
        [self dismiss:YES];
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate alertView:self pressedButtonWithindex:ButtonIndexClose];
    } else {
        [self dismiss:YES];
    }
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
