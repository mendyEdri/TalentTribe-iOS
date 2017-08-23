//
//  StrokeLogoWhiteIndicator.h
//  TalentTribe
//
//  Created by Mendy on 16/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StrokeColoredLogoIndicator : UIView
+ (void)showOnMainWindow;
+ (void)showOnMainWindowOnTop;
+ (void)showOnMainWindowAnimated:(BOOL)animated;
+ (void)showOnView:(UIView *)view;
+ (void)showOnView:(UIView *)view animated:(BOOL)animated;

+ (void)dismiss;
+ (void)dismiss:(BOOL)animated;

+ (StrokeColoredLogoIndicator *)strokeColoredLogoIndicator;

- (void)startAnimating;
- (void)stopAnimating;
@end
