//
//  TTRoundedBorderImageView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/22/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTRoundedBorderImageView.h"

@implementation TTRoundedBorderImageView

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
    self.layer.borderColor = UIColorFromRGB(0xb4b4b4).CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.width / 2.0f;
}

@end
