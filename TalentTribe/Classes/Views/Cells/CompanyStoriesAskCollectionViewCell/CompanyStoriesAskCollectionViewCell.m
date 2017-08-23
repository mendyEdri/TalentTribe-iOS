//
//  CompanyStoriesAskCollectionViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/29/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyStoriesAskCollectionViewCell.h"
#import "TTGradientHandler.h"

@implementation CompanyStoriesAskButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    
    [self setBackgroundImage:[TTGradientHandler gradientImageForType:TTGradientType1 size:self.frame.size] forState:UIControlStateNormal];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:UIColorFromRGB(0xe8e8e8) forState:UIControlStateHighlighted];
    [self setTitleColor:UIColorFromRGBA(0xffffff, 0.5f) forState:UIControlStateDisabled];
}

@end

@implementation CompanyStoriesAskCollectionViewCell

+ (CGFloat)height {
    return 60.0f;
}

@end
