//
//  UserProfileTextFieldTableViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileTextFieldTableViewCell.h"

@implementation UserProfileTextFieldTableViewCell

- (void)setAttributedPlaceholder:(NSString *)placeholder {
    [self setAttributedPlaceholder:placeholder attributes:[self placeholderAttributes]];
}

- (void)setAttributedPlaceholder:(NSString *)placeholder attributes:(NSDictionary *)attributes {
    if (placeholder) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributes ?: [self placeholderAttributes]];
    } else {
        self.textField.attributedPlaceholder = nil;
    }
}

- (NSDictionary *)placeholderAttributes {
    return @{NSForegroundColorAttributeName : UIColorFromRGB(0xdddddd), NSFontAttributeName : TITILLIUMWEB_SEMIBOLD(20.0f)};
    
}

@end
