//
//  KeyboardStateListener.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "KeyboardStateListener.h"

@implementation KeyboardStateListener

- (id)init {
    self = [super init];
    if (self) {
        self.keyboardFrame = CGRectZero;
        self.keyboardShown = NO;
        
        [self setupObservations];
    }
    return self;
}

+ (id)sharedListener {
    static KeyboardStateListener *listener = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        listener = [KeyboardStateListener new];
    });
    return listener;
}

+ (void)setupObservations {
    [KeyboardStateListener sharedListener];
}

- (void)setupObservations {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    self.keyboardFrame = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    self.keyboardFrame = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardShown = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
