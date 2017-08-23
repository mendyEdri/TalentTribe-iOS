//
//  RoundCornerButton.m
//  TalentTribe
//
//  Created by Anton Vilimets on 7/20/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "RoundCornerButton.h"

@implementation RoundCornerButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.cornerRadius;
}

@end
