//
//  StrokeLogoIndicator.h
//  TalentTribe
//
//  Created by Mendy on 15/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StrokeLogoIndicator : UIView
+ (void)showOnMainWindow;
+ (void)showOnMainWindowOnTop;
+ (void)showOnMainWindowAnimated:(BOOL)animated;
+ (void)showOnView:(UIView *)view;
+ (void)showOnView:(UIView *)view animated:(BOOL)animated;

+ (void)dismiss;
+ (void)dismiss:(BOOL)animated;

+ (StrokeLogoIndicator *)strokeIndicator;

- (void)startAnimating;
- (void)stopAnimating;
@end
