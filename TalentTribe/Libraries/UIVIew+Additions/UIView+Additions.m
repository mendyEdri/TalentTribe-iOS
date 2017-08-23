//
//  UIView+Additions.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

+ (id)loadFromXibNamed:(NSString *) xibName {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:xibName
                                                             owner:nil
                                                           options:nil];
    for(id currentObject in topLevelObjects) {
        if([currentObject isKindOfClass:self]) {
            return currentObject;
        }
    }
    return nil;
}

+ (id)loadFromXib {
    return [self loadFromXibNamed:NSStringFromClass(self)];
}

- (UIImage *)renderImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    CGRect rect = self.bounds;
    
    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
}

- (void)removeRoundedCorners {
    self.layer.mask = nil;
}

@end

