//
//  UserProfileHeaderView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileHeaderView.h"
#import "TTRoundButton.h"
#import "TTAlertView.h"

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.,\'\"\\;:/?=+-!@#$%^&*()`~§±"

#define SCALED_CONSTANT(a) (a * (CGRectGetWidth([[UIScreen mainScreen] bounds]) / 320.0f))
#define kMinImageWidth SCALED_CONSTANT(30.0f)
#define kMaxImageWidth (SCALED_CONSTANT(80.0f) / 568) * screenHeight
#define kLeftMargin 10.0f
#define kSideMargins 120.0f

@interface UserProfileHeaderView () <UITextFieldDelegate, TTAlertViewDelegate>

@property BOOL animating;

@end

@implementation UserProfileHeaderView

#pragma mark Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    self.animating = NO;
    _progress = 0.0f;
    [self.userImageButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.animationTitleLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self setupInputTextFields];
    [self setGradientType:TTGradientType8];
}

- (void)setupInputTextFields {
    self.inputFirstNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:[self placeholderAttributes]];
    self.inputLastNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:[self placeholderAttributes]];
    
    [self.inputFirstNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputLastNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSDictionary *)placeholderAttributes {
    return @{NSForegroundColorAttributeName : UIColorFromRGB(0xffffff), NSFontAttributeName : TITILLIUMWEB_SEMIBOLD(20.0f)};
    
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self shouldBeginEditing];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}

- (void)textDidChange:(UITextField *)textField {
    if ([textField isEqual:self.inputFirstNameField]) {
        self.inputLastNameUnderline.backgroundColor = [UIColor whiteColor];
        [self.delegate userFirstNameUpdatedOnProfileHeaderView:self];
    } else if ([textField isEqual:self.inputLastNameField]) {
        self.inputLastNameUnderline.backgroundColor = [UIColor whiteColor];
        [self.delegate userLastNameUpdatedOnProfileHeaderView:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self textDidChange:textField];
}

- (BOOL)shouldBeginEditing {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        return YES;
    } else {
        [self showLoginAlert];
    }
    return NO;
}

- (void)showLoginAlert {
    TTAlertView *alert = [[TTAlertView alloc] initWithMessage:@"Please log in to continue" cancelTitle:@"LOG IN"];
    [alert setDelegate:self];
    [alert showOnMainWindow:YES];
}

- (NSString *)animationTitle {
    if (!self.inputContainer.hidden) {
        if (self.inputFirstNameField.text.length > 0 || self.inputLastNameField.text.length > 0) {
            return [NSString stringWithFormat:@"%@ %@", self.inputFirstNameField.text, self.inputLastNameField.text];
        }
    } else if (!self.nameContainer.hidden) {
        return self.userTitleLabel.text;
    }
    return @"Full name";
}

#pragma mark TTAlertView delegate

- (void)alertView:(TTAlertView *)alertView pressedButtonWithindex:(ButtonIndex)index {
   if (index != ButtonIndexClose) {
       [[DataManager sharedManager] showLoginScreen];
   }
    [alertView dismiss:YES];
}

#pragma mark Interface actions

- (IBAction)backButtonPressed:(id)sender {
    [self.delegate backButtonPressedOnProfileHeaderView:self];
}

- (IBAction)nextButtonPressed:(id)sender {
    [self.delegate nextButtonPressedOnProfileHeaderView:self];
}

- (IBAction)imageButtonPressed:(id)sender {
    if ([self shouldBeginEditing]) {
        [self.delegate imageButtonPressedOnProfileHeaderView:self];
    }
}

#pragma mark Custom setters

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(MAX(0.0f, progress), 1.0f);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setProgress:(CGFloat)progress withAnimationDuration:(CGFloat)duration {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            CGFloat tmpProgress = MIN(MAX(0.0f, progress), 1.0f);
            
            CGRect newImageFrame = [self frameForUserImageProgress:tmpProgress];
            CGRect newAnimationFrame = [self frameForAnimationTitleProgress:tmpProgress];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.fromValue = @(self.userImageButton.frame.size.width / 2.0f);
            animation.toValue = @(newImageFrame.size.width / 2.0f);
            animation.duration = duration;
            [self.userImageButton.layer addAnimation:animation forKey:@"cornerRadius"];
            [UIView animateWithDuration:duration animations:^{
                self.userImageButton.frame = newImageFrame;
                self.animationTitleLabel.frame = newAnimationFrame;
                [self updateAlphaForProgress:self.progress];
            } completion:^(BOOL finished) {
                self.animating = NO;
                [self setProgress:tmpProgress];
            }];
        }
    }
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.animating) {
        self.userImageButton.frame = [self frameForUserImageProgress:self.progress];
        self.animationTitleLabel.frame = [self frameForAnimationTitleProgress:self.progress];
        [self updateAlphaForProgress:self.progress];
        self.animationTitleLabel.text = [self animationTitle];
    }
}

- (void)updateAlphaForProgress:(CGFloat)progress {
    self.animationTitleLabel.alpha = progress < 0.2f ? 0.0f : 1.0f;
    self.inputContainer.alpha = progress > 0.2f ? 0.0f : 1.0f;
    self.nameContainer.alpha = progress > 0.2f ? 0.0f : 1.0f;
}

- (CGRect)frameForUserImageProgress:(CGFloat)progress {
    CGFloat viewHeight = [self viewHeightForProgress:progress];
    CGFloat width = kMinImageWidth + (1.0f - progress) * (kMaxImageWidth - kMinImageWidth);
    CGFloat height = width;
    CGFloat originX = (self.frame.size.width - width) / 2.0f - (([self titleWidthForProgress:progress] + kMinImageWidth + 10.0f) / 2.0f) * progress;
    CGFloat originY = (viewHeight - height) / 2.0f - 10.0f;
    CGRect frame = CGRectIntegral(CGRectMake(originX, originY, width, height));
    return frame;
}

- (CGRect)frameForAnimationTitleProgress:(CGFloat)progress {
    CGFloat viewHeight = [self viewHeightForProgress:progress];
    CGFloat width = [self titleWidthForProgress:progress];
    CGFloat height = 50.0f;
    CGFloat originX = (self.frame.size.width - width) / 2.0f;
    CGFloat originY = (viewHeight - height) / 2.0f - 10.0f + ((1.0f - progress) * (self.userImageButton.frame.size.height / 2.0f + 30.0f));
    CGRect frame = CGRectIntegral(CGRectMake(originX, originY, width, height));
    return frame;
}

- (CGFloat)titleWidthForProgress:(CGFloat)progress {
    CGSize size = CGRectIntegral([[self animationTitle] boundingRectWithSize:CGSizeMake(self.frame.size.width - kMinImageWidth - kLeftMargin - kSideMargins, 50.0f) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.animationTitleLabel.font} context:nil]).size;
    return size.width;
}

- (CGFloat)viewHeightForProgress:(CGFloat)progress {
    if (progress <= 0.00001f) {
        if (self.maxHeight <= 0.01f) {
            return self.frame.size.height;
        } else {
            return self.maxHeight;
        }
    } else if (progress >= 0.99999f) {
        if (self.minHeight <= 0.01f) {
            return self.frame.size.height;
        } else {
            return self.minHeight;
        }
    } else {
        return self.frame.size.height;
    }
}

@end
