//
//  CompanyAboutDescriptionCollectionViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/29/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyAboutDescriptionCollectionViewCell.h"

@implementation CompanyAboutDescriptionCollectionViewCell

+ (NSAttributedString *)attributedStringForTitle:(NSString *)title content:(NSString *)content {
    if (title || content) {
        NSMutableString *string = [[NSMutableString alloc] init];
        if (title && content) {
            [string appendFormat:@"%@\r\n%@", title, content];
        } else {
            [string setString:title ?: content];
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        if (title) {
            [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:18.0f], NSForegroundColorAttributeName : UIColorFromRGB(0x030000)} range:[string rangeOfString:title]];
        }
        if (content) {
            [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-Light" size:18.0f], NSForegroundColorAttributeName : UIColorFromRGB(0x030000)} range:[string rangeOfString:content]];
        }
        return attributedString;
    }
    return nil;
}

#pragma mark Layout constants

+ (CGFloat)contentLeftMargin {
    return 15.0f;
}

+ (CGFloat)contentRightMargin {
    return 15.0f;
}

+ (CGFloat)contentTopMargin {
    return 5.0f;
}

+ (CGFloat)contentBottomMargin {
    return 5.0f;
}

@end
