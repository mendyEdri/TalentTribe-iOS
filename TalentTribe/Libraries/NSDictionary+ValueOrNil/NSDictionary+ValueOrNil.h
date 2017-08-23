//
//  NSDictionary+ValueOrNil.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ValueOrNil)

- (id)objectForKeyOrNil:(id)aKey;
- (id)valueForKeyOrNil:(NSString *)key;

@end
