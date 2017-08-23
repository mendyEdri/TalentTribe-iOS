//
//  RoundStrokeButton.m
//  TalentTribe
//
//  Created by Mendy on 15/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "RoundStrokeButton.h"

@implementation RoundStrokeButton

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end
