//
//  Snippets.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Snippets.h"

@implementation Snippets

- (instancetype)initWithHeader:(NSString *)header content:(NSString *)content {
    self = [super init];
    if (self) {
        self.header = header;
        self.content = content;
    }
    return self;
}

@end
