//
//  TTGradientHandler.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTGradientHandler.h"

@implementation TTGradientHandler

+ (UIImage *)gradientImageForType:(TTGradientType)type size:(CGSize)size {
    return [TTGradientHandler gradientImageForStartColor:[TTGradientHandler startColorForGradientType:type] endColor:[TTGradientHandler endColorForGradientType:type] size:size];
}

+ (UIImage *)gradientImageForStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size {
    return [TTGradientHandler imageWithView:[TTGradientHandler gradientViewForStartColor:startColor endColor:endColor size:size]];
}

+ (UIImage *)gradientImageForColors:(NSArray *)colors locations:(NSArray *)locations size:(CGSize)size {
    return [TTGradientHandler imageWithView:[TTGradientHandler gradientViewForColors:colors locations:locations size:size]];
}

+ (UIView *)gradientViewForType:(TTGradientType)type size:(CGSize)size {
    return [TTGradientHandler gradientViewForStartColor:[TTGradientHandler startColorForGradientType:type] endColor:[TTGradientHandler endColorForGradientType:type] size:size];
}

+ (UIView *)gradientViewForStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size {
    return [TTGradientHandler gradientViewForColors:@[startColor, endColor] locations:@[@(0.0f), @(1.0f)] size:size];
}

+ (UIView *)gradientViewForColors:(NSArray *)colors locations:(NSArray *)locations size:(CGSize)size {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    [TTGradientHandler addGradientToView:view colors:colors locations:locations];
    return view;
}

+ (void)addGradientToView:(UIView *)view forType:(TTGradientType)type {
    return [TTGradientHandler addGradientToView:view startColor:[TTGradientHandler startColorForGradientType:type] endColor:[TTGradientHandler endColorForGradientType:type]];
}

+ (void)addGradientToView:(UIView *)view startColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addGradientToView:view startColor:startColor endColor:endColor alpha:1.0f];
}

+ (void)addGradientToView:(UIView *)view startColor:(UIColor *)startColor endColor:(UIColor *)endColor alpha:(CGFloat)alpha {
    [self addGradientToView:view colors:@[startColor, endColor] locations:@[@(0.0f), @(1.0f)] alpha:alpha];
}

+ (void)addGradientToView:(UIView *)view colors:(NSArray *)colors locations:(NSArray *)locations {
    [self addGradientToView:view colors:colors locations:locations alpha:1.0f];
}

+ (void)addGradientToView:(UIView *)view colors:(NSArray *)colors locations:(NSArray *)locations alpha:(CGFloat)alpha {
    TTCustomGradientView *gradientView = [[TTCustomGradientView alloc] initWithColors:colors locations:locations];
    gradientView.alpha = alpha;
    [view addSubview:gradientView];
    UIView * parent = view;
    UIView * child = gradientView;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent layoutIfNeeded];
}

+ (UIImage *)navBarImage {
    return [TTGradientHandler gradientImageForType:TTGradientType8 size:CGSizeMake(320.0f, 64.0f)];
}

+ (UIColor *)startColorForGradientType:(TTGradientType)type {
    switch (type) {
        case TTGradientType1: {
            return UIColorFromRGB(0x22cfe6);
        } break;
        case TTGradientType2: {
            return UIColorFromRGB(0xff6835);
        } break;
        case TTGradientType3: {
            return UIColorFromRGB(0x79f113);
        } break;
        case TTGradientType4: {
            return UIColorFromRGB(0xc0c6ff);
        } break;
        case TTGradientType5: {
            return UIColorFromRGB(0xb300df);
        } break;
        case TTGradientType6: {
            return UIColorFromRGB(0x562ece);
        } break;
        case TTGradientType7: {
            return UIColorFromRGB(0xffde00);
        } break;
        case TTGradientType8: {
            return UIColorFromRGB(0x28beff);
        } break;
        default: break;
    }
    return nil;
}

+ (UIColor *)endColorForGradientType:(TTGradientType)type {
    switch (type) {
        case TTGradientType1: {
            return UIColorFromRGB(0x08eec2);
        } break;
        case TTGradientType2: {
            return UIColorFromRGB(0xf82d6a);
        } break;
        case TTGradientType3: {
            return UIColorFromRGB(0x04f291);
        } break;
        case TTGradientType4: {
            return UIColorFromRGB(0x00f8e6);
        } break;
        case TTGradientType5: {
            return UIColorFromRGB(0xff1e9d);
        } break;
        case TTGradientType6: {
            return UIColorFromRGB(0xb66bd3);
        } break;
        case TTGradientType7: {
            return UIColorFromRGB(0xff0014);
        } break;
        case TTGradientType8: {
            return UIColorFromRGB(0x23a7e0);
        } break;
        default: break;
    }
    return nil;
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

@implementation TTCustomGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithColors:(NSArray *)colors locations:(NSArray *)locations {
    self = [super init];
    if (self) {
        [self customInitWithColors:colors locations:locations];
    }
    return self;
}

- (instancetype)initWithGradientType:(TTGradientType)type {
    self = [super init];
    if (self) {
        [self customInitWithColors:@[[TTGradientHandler startColorForGradientType:type], [TTGradientHandler endColorForGradientType:type]] locations:@[@(0.0f), @(1.0f)]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self customInitWithColors:@[[TTGradientHandler startColorForGradientType:TTGradientType1], [TTGradientHandler endColorForGradientType:TTGradientType1]] locations:@[@(0.0f), @(1.0f)]];
    }
    return self;
}

- (void)setGradientType:(TTGradientType)type {
    [self setGradientType:type animated:NO];
}

- (void)setGradientType:(TTGradientType)type animated:(BOOL)animated {
    [self setColors:@[[TTGradientHandler startColorForGradientType:type], [TTGradientHandler endColorForGradientType:type]] animated:animated];
}

- (void)setLocations:(NSArray *)locations {
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    gradient.locations = locations;
}

- (void)setColors:(NSArray *)colors {
    [self setColors:colors animated:NO];
}

- (void)setColors:(NSArray *)colors animated:(BOOL)animated {
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    NSMutableArray *cgiColors = [NSMutableArray new];
    for (UIColor *color in colors) {
        [cgiColors addObject:(id)color.CGColor];
    }
    if (animated) {
        [gradient removeAllAnimations];
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"colors"];
        animation.fromValue = gradient.colors;
        animation.toValue = cgiColors;
        animation.duration = 0.3f;
        animation.fillMode = kCAFillModeBoth;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [gradient addAnimation:animation forKey:@"animation"];
        gradient.colors = cgiColors;
    } else {
        gradient.colors = cgiColors;
    }
}

- (void)customInitWithColors:(NSArray *)colors locations:(NSArray *)locations {
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    NSMutableArray *cgiColors = [NSMutableArray new];
    for (UIColor *color in colors) {
        [cgiColors addObject:(id)color.CGColor];
    }
    gradient.colors = cgiColors;
    gradient.locations = locations;
}

@end