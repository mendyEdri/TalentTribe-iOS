//
//  StoryDetailsCommentCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsCommentCell.h"

@implementation StoryDetailsCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark Layout constants

+ (CGFloat)contentLeftMargin {
    return 40.0f;
}

+ (CGFloat)contentRightMargin {
    return 15.0f;
}

+ (CGFloat)contentTopMargin {
    return 25.0f;
}

+ (CGFloat)contentBottomMargin {
    return 25.0f;
}

+ (UIFont *)font {
    return [UIFont fontWithName:@"TitilliumWeb-Light" size:13.0f];
}

@end
