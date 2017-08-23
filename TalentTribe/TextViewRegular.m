//
//  TextViewRegular.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/9/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TextViewRegular.h"

@implementation TextViewRegular

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        
        [self setFont:TITILLIUMWEB_REGULAR([self font].pointSize)];
        
    }
    return self;
}

@end
