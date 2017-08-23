//
//  CreateChangeColorsView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/19/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateChangeColorsView.h"

@interface CreateChangeColorsView ()

@property BOOL animating;

@end

@implementation CreateChangeColorsView

- (void)showViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            void (^innerCompletion)(void) = ^{
                self.animating = NO;
                self.visible = YES;
                if (completion) {
                    completion();
                }
            };
            if (!self.visible) {
                self.alpha = 0.0f;
                self.hidden = NO;
                [UIView animateWithDuration:animated ? 0.3f : 0.0f animations:^{
                    self.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    innerCompletion();
                    
                }];
            } else {
                innerCompletion();
            }
        }
    }
}

- (void)hideViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            void (^innerCompletion)(void) = ^{
                self.hidden = YES;
                self.visible = NO;
                self.animating = NO;
                if (completion) {
                    completion();
                }
            };
            if (self.visible) {
                self.alpha = 1.0f;
                self.hidden = NO;
                [UIView animateWithDuration:animated ? 0.3f : 0.0f animations:^{
                    self.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    innerCompletion();
                }];
            } else {
                innerCompletion();
            }
        }
    }
}

@end
