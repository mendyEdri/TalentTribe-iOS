//
//  Author.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Author.h"

#define kUserId @"userId"
#define kFirstName @"firstName"
#define kLastName @"lastName"
#define kFullName @"fullName"
#define kProfileImage @"profileImage"
#define kEmail @"email"

@implementation Author

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.userId = [dict objectForKeyOrNil:kUserId];
            self.firstName = [dict objectForKeyOrNil:kFirstName];
            self.lastName = [dict objectForKeyOrNil:kLastName];
            self.fullName = [dict objectForKeyOrNil:kFullName];
            self.email = [dict objectForKeyOrNil:kEmail];
            
            id imageString = [dict objectForKeyOrNil:kProfileImage];
            if (imageString && [imageString isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:imageString];
                if (url && url.scheme && url.host) {
                    self.profileImageLink = imageString;
                }
            }
        }
    }
    return self;
}

- (NSString *)fullName {
    if (!_fullName) {
        NSMutableString *fullNameContainer = [NSMutableString new];
        if (self.firstName) {
            [fullNameContainer appendString:self.firstName];
        }
        if (self.lastName) {
            if (self.fullName) {
                [fullNameContainer appendString:@" "];
            }
            [fullNameContainer appendString:self.lastName];
        }
        _fullName = fullNameContainer.length ? fullNameContainer : nil;
    }
    return _fullName;
}

@end
