//
//  TTGradientButton.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/7/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTGradientButton.h"
#import "TTGradientHandler.h"

@implementation TTGradientButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 7.0f;
    self.layer.masksToBounds = YES;
    
    [self setBackgroundImage:[TTGradientHandler gradientImageForType:TTGradientType8 size:self.frame.size] forState:UIControlStateNormal];
    [self setBackgroundImage:[TTGradientHandler gradientImageForStartColor:UIColorFromRGB(0x0d7daa) endColor:UIColorFromRGB(0x0f99ce) size:self.frame.size] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[TTGradientHandler gradientImageForStartColor:UIColorFromRGB(0x5fcfff) endColor:UIColorFromRGB(0x8cdcff) size:self.frame.size] forState:UIControlStateDisabled];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:UIColorFromRGB(0xe8e8e8) forState:UIControlStateHighlighted];
    [self setTitleColor:UIColorFromRGBA(0xffffff, 0.5f) forState:UIControlStateDisabled];
    
}

@end
