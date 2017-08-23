//
//  LinkHeaderView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "LinkHeaderView.h"
#import "TTUtils.h"

@implementation LinkHeaderView

- (void)setAuthor:(NSString *)author date:(NSDate *)date {
    NSString *highlightedString = author;
    NSString *authorString = [NSString stringWithFormat:@"%@ posted a link", highlightedString];
    [self setAuthor:authorString highlight:highlightedString];
}

- (void)setLinkURL:(NSString *)linkURL date:(NSDate *)date {
    if (linkURL) {
        NSString *highlightedString = [[[NSURL URLWithString:linkURL] host] stringByReplacingOccurrencesOfString:@"www." withString:@""];
        NSString *dot = @"·";
        NSString *linkString = [NSString stringWithFormat:@"%@ %@ %@ %@", highlightedString, dot, [[[[TTUtils sharedUtils] postDateFormatter] stringFromDate:date ?: [NSDate date]] uppercaseString], dot];
        NSMutableAttributedString *attributedString = [TTUtils attributedStringForString:linkString highlight:highlightedString highlightedColor:UIColorFromRGB(0x28beff) defaultColor:UIColorFromRGB(0x8d8d8d)];
        NSRange range = [attributedString.string rangeOfString:dot];
        if (range.location != NSNotFound) {
            [attributedString setAttributes:[TTUtils attributesForDot] range:range];
        }
        self.linkLabel.attributedText = attributedString;
    } else {
        self.linkLabel.attributedText = nil;
    }
}

+ (CGFloat)contentTopMargin {
    return 0.0f;
}

+ (CGFloat)contentBottomMargin {
    return 64.0f;
}

@end
