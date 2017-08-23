//
//  CreateTabViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface CreateTabViewController : UIViewController

@property (nonatomic, weak) Company *company;

@property BOOL keyboardShown;
@property CGRect keyboardFrame;
@property double keyboardTransitionDuration;
@property UIViewAnimationOptions keyboardTransitionAnimationCurve;

@property BOOL anonymously;

- (Story *)story;

- (void)keyboardWillShow;
- (void)keyboardWillHide;

- (BOOL)validateInput;
- (void)showInputAlertWithText:(NSString *)text;
- (NSData *)videoData;

@end
