//
//  UIView+Additions.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

+ (id)loadFromXibNamed:(NSString *)xibName;
+ (id)loadFromXib;

- (UIImage *)renderImage;

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;
- (void)removeRoundedCorners;

@end

