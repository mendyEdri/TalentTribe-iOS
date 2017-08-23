//
//  StoryHeaderView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryHeaderView.h"
#import "TTUtils.h"

@implementation StoryHeaderView

- (void)setAuthor:(NSString *)author date:(NSDate *)date {
    NSString *highlightedString = author;
    __unused NSString *dot = @"·";
    NSString *authorString =  highlightedString; //[NSString stringWithFormat:@"%@ %@ %@ %@", highlightedString, dot, [[[[TTUtils sharedUtils] postDateFormatter] stringFromDate:date ?: [NSDate date]] uppercaseString], dot];
    [self setAuthor:authorString highlight:highlightedString];
}

#pragma mark Layout constants

+ (CGFloat)contentTopMargin {
    return 0.0f;
}

+ (CGFloat)contentBottomMargin {
    return 37.0f;
}

@end
