//
//  UIImage+sizedImageNamed.m
//  MomSense
//
//  Created by Bogdan Andresyuk on 4/21/15.
//  Copyright (c) 2015 OnO Apps. All rights reserved.
//

#import "UIImage+sizedImageNamed.h"
#import <objc/runtime.h>

@implementation UIImage (sizedImageNamed)

+ (UIImage *)sizedImageNamed:(NSString *)imageName {
    return [UIImage imageNamed:[UIImage sizedNameForName:imageName]] ?: [UIImage imageNamed:imageName];
}

+ (NSString *)scaledNameForName:(NSString *)imageName {
    // only change the name if no '@2x' or '@3x' are specified
    if ([imageName rangeOfString:@"@"].location == NSNotFound) {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        NSString *extension = @"";
        if (scale == 3.f) {
            extension = @"@3x";
        } else if (scale == 2.f) {
            extension = @"@2x";
        }
        // add the extension to the image name
        NSRange dot = [imageName rangeOfString:@"."];
        NSMutableString *imageNameMutable = [imageName mutableCopy];
        if (dot.location != NSNotFound)
            [imageNameMutable insertString:extension atIndex:dot.location];
        else
            [imageNameMutable appendString:extension];
        
        if (imageNameMutable) {
            return imageNameMutable;
        }
    }
    return imageName;
}

+ (NSString *)sizedNameForName:(NSString *)imageName {
    // only change the name if no '@2x' or '@3x' are specified
    if ([imageName rangeOfString:@"@"].location == NSNotFound) {
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat scale = [UIScreen mainScreen].scale;
        
        // generate the current valid file extension depending on the current device screen size.
        NSString *extension = @"";
        if (scale == 3.f) {
            extension = @"-736h@3x";
        } else if (scale == 2.f && h == 568.0f && w == 320.0f) {
            extension = @"-568h@2x";
        } else if (scale == 2.f && h == 667.0f && w == 375.0f) {
            extension = @"-667h@2x";
        } else if (scale == 2.f && h == 480.0f && w == 320.0f) {
            extension = @"@2x";
        }
        
        // add the extension to the image name
        NSRange dot = [imageName rangeOfString:@"."];
        NSMutableString *imageNameMutable = [imageName mutableCopy];
        if (dot.location != NSNotFound)
            [imageNameMutable insertString:extension atIndex:dot.location];
        else
            [imageNameMutable appendString:extension];
        
        if (imageNameMutable) {
            return imageNameMutable;
        }
    }
    return imageName;
}

@end
