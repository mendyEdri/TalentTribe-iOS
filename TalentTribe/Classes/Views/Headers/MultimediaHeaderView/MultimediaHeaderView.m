//
//  MultimediaHeaderView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "MultimediaHeaderView.h"
#import "TTUtils.h"

@implementation MultimediaHeaderView

+ (CGFloat)heightForTitle:(NSString *)title author:(NSString *)author size:(CGFloat)width {
    return 37.0f;
}

- (void)setAuthor:(NSString *)author date:(NSDate *)date {
    NSString *highlightedString = author;
    NSString *dot = @"·";
    NSString *authorString = [NSString stringWithFormat:@"By %@ %@ %@ %@", highlightedString, dot, [[[[TTUtils sharedUtils] postDateFormatter] stringFromDate:date ?: [NSDate date]] uppercaseString], dot];
    [self setAuthor:authorString highlight:highlightedString];
}

@end
