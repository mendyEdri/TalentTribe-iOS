//
//  TTRoundedCornersButton.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/13/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTRoundedCornersButton.h"

@interface TTRoundedCornersButton()
@property (assign, nonatomic) CGFloat radius;
@end

@implementation TTRoundedCornersButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.radius ? self.radius : 3.5f;
}

- (void)setCornerRadius:(CGFloat)radius {
    self.radius = radius;
}

@end
