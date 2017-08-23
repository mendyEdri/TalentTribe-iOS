//
//  RoundedView.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "RoundedView.h"

@implementation RoundedView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        CALayer *viewLayer = self.layer;
        [viewLayer setCornerRadius:3.0];
        [viewLayer setMasksToBounds:YES];
    }
    return self;
}

@end
