//
//  FilterCell.m
//  TalentTribe
//
//  Created by Anton Vilimets on 7/20/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell
{
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
