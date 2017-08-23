//
//  NSDictionary+ValueOrNil.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "NSDictionary+ValueOrNil.h"

@implementation NSDictionary (ValueOrNil)

- (id)objectForKeyOrNil:(id)aKey {
    if (aKey) {
        if ([self objectForKey:aKey] && (![[self objectForKey:aKey] isEqual:[NSNull null]])) {
            return [self objectForKey:aKey];
        }
    }
    return nil;
}

- (id)valueForKeyOrNil:(NSString *)key {
    if (key) {
        if ([self valueForKey:key] && (![[self valueForKey:key] isEqual:[NSNull null]])) {
            return [self valueForKey:key];
        }
    }
    return nil;
}

@end
