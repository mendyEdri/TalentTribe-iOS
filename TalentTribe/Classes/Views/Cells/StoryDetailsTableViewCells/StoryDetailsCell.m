//
//  StoryDetailsCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/17/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsCell.h"

@implementation StoryDetailsCell

#pragma mark Layout constants

+ (CGFloat)height {
    return 42.0f;
}

+ (CGFloat)contentLeftMargin {
    return 15.0f;
}

+ (CGFloat)contentRightMargin {
    return 15.0f;
}

+ (CGFloat)contentTopMargin {
    return 0.0f;
}

+ (CGFloat)contentBottomMargin {
    return 0.0f;
}

+ (UIFont *)font {
    return [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:13.0f];
}

@end
