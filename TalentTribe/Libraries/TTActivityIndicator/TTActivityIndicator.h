//
//  TTActivityIndicator.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/29/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTActivityIndicator : UIView

+ (void)showOnMainWindow;
+ (void)showOnMainWindowOnTop;
+ (void)showOnMainWindowAnimated:(BOOL)animated;
+ (void)showOnView:(UIView *)view;
+ (void)showOnView:(UIView *)view animated:(BOOL)animated;

+ (void)dismiss;
+ (void)dismiss:(BOOL)animated;

+ (TTActivityIndicator *)activityIndicator;

- (void)startAnimating;
- (void)stopAnimating;

@end