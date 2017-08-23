//
//  TTRoundButton.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTRoundButton.h"

@implementation TTRoundButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0f;
}

@end
