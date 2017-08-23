//
//  CreateTabViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateTabViewController.h"

static inline UIViewAnimationOptions AnimationOptionsForCurve(UIViewAnimationCurve curve) {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
        default:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
    }
}

@interface CreateTabViewController ()

@end

@implementation CreateTabViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

#pragma mark Input validation

- (BOOL)validateInput {
    return NO;
}

- (void)showInputAlertWithText:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (Story *)story {
    return nil;
}

- (NSData *)videoData
{
    return nil;
}

#pragma mark Keyboard handling

- (void)keyboardWillShow {
    
}

- (void)keyboardWillHide {

}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyboardShown = YES;
    [self updateKeyboardPropertiesFromNotification:notification];
    [self keyboardWillShow];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardShown = NO;
    [self updateKeyboardPropertiesFromNotification:notification];
    [self keyboardWillHide];
}

- (void)updateKeyboardPropertiesFromNotification:(NSNotification *)notification {
    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    CGRect keyboardEndFrameView = [self.view convertRect:keyboardEndFrameWindow fromView:nil];
    
    self.keyboardFrame = keyboardEndFrameView;
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    self.keyboardTransitionDuration = keyboardTransitionDuration;
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    self.keyboardTransitionAnimationCurve = AnimationOptionsForCurve(keyboardTransitionAnimationCurve);
}

- (void)setupKeyboardNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
