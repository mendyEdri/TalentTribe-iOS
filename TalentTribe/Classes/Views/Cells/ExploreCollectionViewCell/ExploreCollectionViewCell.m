//
//  ExploreCollectionViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ExploreCollectionViewCell.h"
#import "TTGradientHandler.h"

@implementation ExploreCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.gradientView setLocations:@[@(0.0f), @(1.0f)]];
    [self.gradientView setColors:@[UIColorFromRGBA(0x000000, 0.0f), UIColorFromRGBA(0x000000, 0.74f)]];
}

@end
