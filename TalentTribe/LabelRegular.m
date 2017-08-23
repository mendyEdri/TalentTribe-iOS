//
//  LabelRegular.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/10/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "LabelRegular.h"

@implementation LabelRegular

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        
        self.adjustsFontSizeToFitWidth = YES;
        [self setFont:TITILLIUMWEB_REGULAR([self font].pointSize)];
    }
    return self;
}

@end
