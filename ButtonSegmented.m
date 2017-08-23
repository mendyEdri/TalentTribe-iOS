//
//  ButtonSegmented.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/9/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ButtonSegmented.h"

@implementation ButtonSegmented

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.titleLabel setFont:TITILLIUMWEB_REGULAR([self.titleLabel font].pointSize)];
        
    }
    return self;
}

@end
