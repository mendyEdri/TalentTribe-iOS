//
//  StoryFeedCollectionViewHardFactsCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedCollectionViewHardFactsCell.h"

@implementation StoryFeedCollectionViewHardFactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self.blackoutGradientView removeFromSuperview];
    [self.gradientView setColors:@[UIColorFromRGB(0x13bafc), UIColorFromRGB(0x212b2f)]];
    [self.gradientView setLocations:@[@(0.0), @(1.0)]];
    
    self.openPositionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.openPositionsButton.layer.borderWidth = 1.0;
    self.openPositionsButton.layer.cornerRadius = CGRectGetHeight(self.openPositionsButton.bounds)/2;
}

@end
