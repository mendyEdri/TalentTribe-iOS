//
//  TTGradientHandler.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TTGradientType1,
    TTGradientType2,
    TTGradientType3,
    TTGradientType4,
    TTGradientType5,
    TTGradientType6,
    TTGradientType7,
    TTGradientType8,
    gradientTypeCount
} TTGradientType;


@interface TTCustomGradientView : UIView

- (instancetype)initWithColors:(NSArray *)colors locations:(NSArray *)locations;
- (instancetype)initWithGradientType:(TTGradientType)type;

- (void)setGradientType:(TTGradientType)type;
- (void)setGradientType:(TTGradientType)type animated:(BOOL)animated;
- (void)setLocations:(NSArray *)locations;
- (void)setColors:(NSArray *)colors;

@end

@interface TTGradientHandler : NSObject

+ (UIImage *)gradientImageForType:(TTGradientType)type size:(CGSize)size;
+ (UIImage *)gradientImageForStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size;
+ (UIImage *)gradientImageForColors:(NSArray *)colors locations:(NSArray *)locations size:(CGSize)size;

+ (UIView *)gradientViewForType:(TTGradientType)type size:(CGSize)size;
+ (UIView *)gradientViewForStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size;
+ (UIView *)gradientViewForColors:(NSArray *)colors locations:(NSArray *)locations size:(CGSize)size;

+ (void)addGradientToView:(UIView *)view forType:(TTGradientType)type;
+ (void)addGradientToView:(UIView *)view startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
+ (void)addGradientToView:(UIView *)view startColor:(UIColor *)startColor endColor:(UIColor *)endColor alpha:(CGFloat)alpha;
+ (void)addGradientToView:(UIView *)view colors:(NSArray *)colors locations:(NSArray *)locations;

+ (UIImage *)navBarImage;

@end
