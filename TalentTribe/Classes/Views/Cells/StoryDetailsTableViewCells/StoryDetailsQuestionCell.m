//
//  StoryDetailsQuestionCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsQuestionCell.h"
#import "TTGradientHandler.h"

@interface StoryDetailsQuestionCell ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet TTCustomGradientView *gradientView;

@end

@implementation StoryDetailsQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setIndex:(NSInteger)index {
    [self.gradientView setGradientType:(TTGradientType)(index % gradientTypeCount)];
}

#pragma mark Layout constants

+ (CGFloat)contentBottomMargin {
    return 20.0f;
}

@end
