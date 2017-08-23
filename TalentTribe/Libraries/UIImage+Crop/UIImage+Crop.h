//
//  UIImage+Crop.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)resizedImageToWidth:(CGFloat)targetWidth;
- (void)resizedImageToWidth:(CGFloat)targetWidth withCompletion:(SimpleResultBlock)completion;
- (UIImage *)cropToRect:(CGRect)rect;

@end
