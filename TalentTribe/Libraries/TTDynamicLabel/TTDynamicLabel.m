//
//  TTDynamicLabel.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/4/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTDynamicLabel.h"


@interface TTDynamicLabel ()

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation TTDynamicLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
            self.heightConstraint = constraint;
            break;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.heightConstraint.constant = [self sizeThatFits:CGSizeMake(self.frame.size.width, FLT_MAX)].height;
}

@end
