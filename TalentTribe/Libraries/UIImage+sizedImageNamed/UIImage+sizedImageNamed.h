//
//  UIImage+sizedImageNamed.h
//  MomSense
//
//  Created by Bogdan Andresyuk on 4/21/15.
//  Copyright (c) 2015 OnO Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (sizedImageNamed)

+ (UIImage *)sizedImageNamed:(NSString *)imageNamed;
+ (NSString *)scaledNameForName:(NSString *)imageName;
+ (NSString *)sizedNameForName:(NSString *)imageName;

@end
