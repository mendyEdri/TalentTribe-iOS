//
//  CreateStoryAlert.m
//  TalentTribe
//
//  Created by Asi Givati on 10/22/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "CreateStoryAlert.h"
#import "GeneralMethods.h"
#import "RootNavigationController.h"
#import "TTActivityIndicator.h"
#import "Company.h"

@interface CreateStoryAlert()

@property NSString *userEmail;
@property UIColor *mainColor;
@property NSString *generalAlertText;
@property NSString *generalAlertProcessButtonText;
@property BOOL generalAlertWithCloseButton;

@end

@implementation CreateStoryAlert

#pragma mark Views lifeCycle

-(void)awakeFromNib
{
    self.movementConstraintDefaultPosition = self.alertContainerMovementConstraint.constant;
    self.alertContainerInputTextField.delegate = self;
    self.mainColor = [GeneralMethods colorWithRed:31 green:172 blue:228];
}

-(void)resetAlertContainer
{
    self.alertMode = resetMode;
    [self.alertContainerProcessButton setHidden:NO];
    [self.alertContainerProcessButton.titleLabel setText:@""];
    [self.alertContainerTitle setText:@""];
    [self.alertContainerInputTextField setText:@""];
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomButton setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.progressView setProgress:0];
    [self.progressView setHidden:YES];
    [self.alertContainerInputTextField resignFirstResponder];
    self.generalAlertProcessButtonText = @"";
    self.generalAlertWithCloseButton = YES;
    self.generalAlertText = @"";
    [self setHidden:YES];
}

#pragma mark UITextFiewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.alertMode == codeProcessMode && (textField.text.length >= CODE_CHARS_LIMIT && range.length == 0) &&
        [textField isEqual:self.alertContainerInputTextField])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark Setup views

-(void)loadAlertContainerViewWithGeneralAlert:(NSString *)alert showCloseButton:(BOOL)showCloseButton processButtonText:(NSString *)processButtonText
{
    self.generalAlertText = alert;
    self.generalAlertWithCloseButton = showCloseButton;
    self.generalAlertProcessButtonText = processButtonText;
    [self loadAlertContainerViewWithMode:generalAlert];
}

-(void)loadAlertContainerViewWithMode:(AlertModes)mode
{
    if (self.alertMode == mode)
    {
        return;
    }
    [self setFrame:[self superview].bounds];
//    self.frame = CGRectMake(CGRectGetMinX(self.superview.frame), -CGRectGetMinY(self.superview.frame), CGRectGetWidth(self.superview.bounds), CGRectGetHeight(self.superview.frame));
    if (self.alpha == 1 || self.hidden == NO)
    {
        [self resetAlertContainer];
    }
    
    [self.alertContainerProcessButton.layer setCornerRadius:4];
    [self.alertContainerProcessButton.titleLabel setFont: [self.alertContainerProcessButton.titleLabel.font fontWithSize:15]];
    
//    [self.alertContainerTitle setText:title];
    self.alertMode  = mode;
    if (self.alertMode == emptyProfileMode)
    {
        [self.alertContainerTitle setText:EMPTY_PROFILE_ALERT];
        [self handleEmptyProfileAlert];
    }
    else if (self.alertMode == halfFilledProfileMode)
    {
        [self.alertContainerTitle setText:HALF_FILLED_PROFILE_ALERT];
        [self handleHalfFilledProfileAlert];
    }
    else if (self.alertMode == emailProcessMode)
    {
        [self.alertContainerTitle setText:EMAIL_PROCESS_ALERT];
        [self handleEmailVerificationAlert];
    }
    else if (self.alertMode == codeProcessMode)
    {
        [self.alertContainerTitle setText:CODE_PROCESS_ALERT];
        [self handleCodeAlert];
    }
    else if (self.alertMode == uploadCompleteMode)
    {
        [self.alertContainerTitle setText:UPLOAD_COMPLETE_ALERT];
        [self handleUploadCompleteAlert];
    }
    else if (self.alertMode == uploadVideoProgressMode)
    {
        [self.alertContainerTitle setText:UPLOAD_VIDEO_PROGRESS_MODE];
        [self handleUploadVideoProgressAlert];
    }
    else if (self.alertMode == uploadStoryProgressMode)
    {
        [self.alertContainerTitle setText:UPLOAD_STORY_PROGRESS_MODE];
        [self handleUploadStoryProgressAlert];
    }
    else if (self.alertMode == generalAlert)
    {
        [self.alertContainerTitle setText:self.generalAlertText];
        [self handleGeneralAlert];
    }

    self.alpha = 0;
    [self setHidden:NO];
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 1;
    }];
}

-(void)handleHalfFilledProfileAlert
{
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.alertContainerProcessButton setTitle:@"UPDATE PROFILE" forState:UIControlStateNormal];
    [self updateMovementViewConstraints];
}

-(void)handleEmptyProfileAlert
{
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.alertContainerProcessButton setTitle:@"CREATE PROFILE" forState:UIControlStateNormal];
    [self updateMovementViewConstraints];
}

-(void)handleEmailVerificationAlert
{
    [self showBottomButtonWithTitle:@"I already have code"];
    [self.alertContainerProcessButton setTitle:@"SEND VERIFICATION EMAIL" forState:UIControlStateNormal];
    self.alertContainerInputTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.alertContainerInputTextField becomeFirstResponder];
    [self showAlertTextFieldWithPlaceholder:@"Email"];
    [self updateMovementViewConstraints];
}

-(void)handleCodeAlert
{
    [self showBottomButtonWithTitle:@"Send code again"];
    [self.alertContainerProcessButton setTitle:@"VERIFY" forState:UIControlStateNormal];
    self.alertContainerInputTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.alertContainerInputTextField becomeFirstResponder];
    [self showAlertTextFieldWithPlaceholder:@"Code"];
    [self updateMovementViewConstraints];
}


-(void)handleUploadCompleteAlert
{
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.alertContainerProcessButton setTitle:@"OK" forState:UIControlStateNormal];
    [self updateMovementViewConstraints];
}

-(void)handleUploadVideoProgressAlert
{
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.alertContainerProcessButton setHidden:YES];
    [self.alertContainerCloseButton setHidden:YES];
    [self.progressView setHidden:NO];
    [self.progressView setProgress:0];
    [self updateMovementViewConstraints];
}

-(void)handleUploadStoryProgressAlert
{
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.alertContainerProcessButton setHidden:YES];
    [self.alertContainerCloseButton setHidden:YES];
    [self.progressView setHidden:YES];
    [self updateMovementViewConstraints];
}

-(void)handleGeneralAlert
{
    [self.alertContainerInputTextField setHidden:YES];
    [self.alertContainerBottomline setHidden:YES];
    [self.alertContainerProcessButton setHidden:YES];
    [self.alertContainerCloseButton setHidden:!self.generalAlertWithCloseButton];
    [self.alertContainerProcessButton setTitle:self.generalAlertProcessButtonText forState:UIControlStateNormal];
    [self.progressView setHidden:YES];
    [self updateMovementViewConstraints];
}


-(void)setNewValueToProgressView:(CGFloat)value
{
    if (self.alertMode == uploadVideoProgressMode)
    {
        [self.progressView setProgress:value animated:YES];
    }
}

-(void)showBottomButtonWithTitle:(NSString *)title
{
    [self.alertContainerBottomButton setHidden:NO];
    [self.alertContainerBottomButton setTitle:title forState:UIControlStateNormal];
}

-(void)showAlertTextFieldWithPlaceholder:(NSString *)placeholder
{
    [self.alertContainerInputTextField setHidden:NO];
    [self.alertContainerBottomline setHidden:NO];
    [self.alertContainerInputTextField setPlaceholder:placeholder];
}

-(void)updateMovementViewConstraints
{
    CGFloat buttonSize;
    
    if (self.alertMode == codeProcessMode || self.alertMode == emailProcessMode)
    {
        buttonSize = self.alertContainerBottomButton.frame.size.height * 0.6;
    }
    else
    {
        buttonSize = 0;
    }
    
    self.alertContainerMovementConstraint.constant = self.movementConstraintDefaultPosition - buttonSize;
    [self layoutIfNeeded];
}

#pragma mark Buttons Actions

- (IBAction)processAlertButtonClicked:(id)sender
{
    if (self.alertMode == emptyProfileMode || self.alertMode == halfFilledProfileMode)
    {
        [self emptyProfileProcessButtonClicked:sender];
    }
    else if (self.alertMode == emailProcessMode)
    {
        [self emailProcessButtonClicked];
    }
    else if (self.alertMode == codeProcessMode)
    {
        [self codeVerifyButtonClicked];
    }
    else if (self.alertMode == uploadCompleteMode)
    {
        [self closeAlertButtonClicked:self.alertContainerCloseButton];
    }
}

-(void)emptyProfileProcessButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(createStoryAlert:emptyOrHalfFilledProfileButtonClicked:)])
    {
        [self.delegate createStoryAlert:self emptyOrHalfFilledProfileButtonClicked:sender];
    }
}

-(void)emailProcessButtonClicked
{
//    self.alertContainerInputTextField.text = @"qa@talenttribe.me"; // QA ONLY
    
    if ([DataManager validateEmail:self.alertContainerInputTextField.text]) // validate Email syntax
    {
        [self emailSender];
    }
    else
    {
        [self markAlertBottomline];
    }
}


-(void)codeVerifyButtonClicked
{
    NSString *inputCode = self.alertContainerInputTextField.text;
    
    if (inputCode.length < CODE_CHARS_LIMIT)
    {
        [self markAlertBottomline];
        return;
    }
    [TTActivityIndicator showOnView:self animated:YES];
    [[DataManager sharedManager] validateUserCodeToCompany:inputCode completion:^(BOOL codeIsOK, NSError *error)
    {
        [TTActivityIndicator dismiss];
        
        void (^showError)() = ^
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Something went wrong. Please try again later!" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [[GeneralMethods getTopViewController] presentViewController:alert animated:YES completion:nil];
        };
        
        if (!error)
        {
            if (codeIsOK)
            {
                if ([self.delegate respondsToSelector:@selector(createStoryAlertDidFinishCodeVerification:)])
                {
                    [self.delegate createStoryAlertDidFinishCodeVerification:self];
                }
                [self setHidden:YES];
                [self removeFromSuperview];
            }
            else
            {
                self.alertContainerTitle.text = @"Wrong Code";
                [self markAlertBottomline];
            }
        }
        else if (error)
        {
            showError();
        }
    }];
}

- (IBAction)bottomButtonClicked:(id)sender
{
    if (self.alertMode == emailProcessMode) // Already have code clicked
    {
        [self loadAlertContainerViewWithMode:codeProcessMode];
    }
    else if (self.alertMode) // Send code again clicked
    {
        [self emailSender];
    }
}

- (IBAction)closeAlertButtonClicked:(id)sender
{
    [self.alertContainerInputTextField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(createStoryAlert:closeButtonClicked:)])
    {
        [self.delegate createStoryAlert:self closeButtonClicked:sender];
    }
}

#pragma mark Other

-(void)emailSender
{
    [TTActivityIndicator showOnView:self animated:YES];
    
    if (self.alertContainerInputTextField.text.length > 0)// first time of the user to req sending email
    {
        self.userEmail = self.alertContainerInputTextField.text;
    }
    else
    {
        if (self.userEmail.length == 0) // user's email not exxist
        {
            [TTActivityIndicator dismiss];
            [self loadAlertContainerViewWithMode:emailProcessMode];
            return;
        }
    }
    
    [[DataManager sharedManager] validateUserEmailToCompany:self.userEmail completion:^(BOOL success, NSError *error)
    {
        [TTActivityIndicator dismiss];
        
        if(success)
        {
            if (self.alertMode == codeProcessMode) // code sent again
            {
                [self handleCodeSentAgain];
            }
            else
            {
                [self loadAlertContainerViewWithMode:codeProcessMode];
            }
        }
        else
        {
            NSString *reason = [[[error userInfo]objectForKey:@"error"]objectForKey:@"reason"];
            if (!reason)
            {
                reason = @"Something went wrong...Please try again later!";
            }
            self.alertContainerTitle.text = reason;
        }
    }];
}

-(void)handleCodeSentAgain
{
    self.alertContainerBottomButton.enabled = NO;
    [self.alertContainerBottomButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [self.alertContainerBottomButton setTitle:@"Code Sent!" forState:UIControlStateNormal];
    self.alertContainerBottomButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}

-(void)markAlertBottomline
{
    __block UIColor *current = self.alertContainerBottomline.backgroundColor;
    [GeneralMethods vibrateDevice];
    [UIView animateWithDuration:0.3 animations:^
     {
         [self.alertContainerBottomline setBackgroundColor:[UIColor redColor]];
     }
      completion:^(BOOL finished)
     {
         [UIView animateWithDuration:1.3 animations:^
          {
              [self.alertContainerBottomline setBackgroundColor:current];
          }
          completion:nil];
     }];
}

//-(NSString *)generateVerificationCode
//{
//    NSString *str = @"";
//    for (int i = 0; i < CODE_CHARS_LIMIT; i++)
//    {
//        str = [str stringByAppendingString:@"9"];
//    }
//    
//    int code = [GeneralMethods generateRandom_Int_From:0 To:[str intValue]];
//    return [NSString stringWithFormat:@"%04d", code];
//}

-(void)animatedContainerAlert
{
    [GeneralMethods vibrateDevice];
    CGFloat movementRange = 10;
    CGFloat interval = 0.1;
    
    [UIView animateWithDuration:interval animations:^
     {
         [self.alertContainer setFrame:CGRectMake(self.alertContainer.frame.origin.x + movementRange, self.alertContainer.frame.origin.y, self.alertContainer.frame.size.width, self.alertContainer.frame.size.height)];
     }
     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:interval animations:^
          {
              [self.alertContainer setFrame:CGRectMake(self.alertContainer.frame.origin.x - (movementRange * 2), self.alertContainer.frame.origin.y, self.alertContainer.frame.size.width, self.alertContainer.frame.size.height)];
          }
           completion:^(BOOL finished)
          {
              [UIView animateWithDuration:interval animations:^
               {
                   [self.alertContainer setFrame:CGRectMake(self.alertContainer.frame.origin.x + movementRange, self.alertContainer.frame.origin.y, self.alertContainer.frame.size.width, self.alertContainer.frame.size.height)];
               }
               completion:nil];
          }];
     }];
}



@end
