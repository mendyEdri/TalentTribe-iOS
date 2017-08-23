//
//  LinkedInToken.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/14/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "LinkedInToken.h"

#define kAccessToken @"access_token"
#define kExpiresIn @"expires_in"
#define kExpirationDate @"expiration_date"
#define kRegistered @"registered"

@implementation LinkedInToken

#pragma mark Initialization

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.accessToken = [dict objectForKeyOrNil:kAccessToken];
        NSNumber *expirationInterval = [dict objectForKeyOrNil:kExpiresIn];
        if (expirationInterval) {
            self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expirationInterval.integerValue];
        }
    }
    return self;
}

- (BOOL)isValid {
    return [[NSDate date] timeIntervalSinceDate:self.expirationDate] <= 0;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.accessToken = [aDecoder decodeObjectForKey:kAccessToken];
        self.expirationDate = [aDecoder decodeObjectForKey:kExpirationDate];
        //self.registered = [aDecoder decodeBoolForKey:kRegistered];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.accessToken forKey:kAccessToken];
    [aCoder encodeObject:self.expirationDate forKey:kExpirationDate];
    //[aCoder encodeBool:self.registered forKey:kRegistered];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LinkedInToken *instance = [[[self class] allocWithZone:zone] init];
    instance.accessToken = self.accessToken;
    instance.expirationDate = self.expirationDate;
    return instance;
}

- (BOOL)isEqualToToken:(LinkedInToken *)token {
    if ([self.accessToken isEqualToString:token.accessToken] &&
        [self.expirationDate isEqualToDate:token.expirationDate]) {
        return YES;
    }
    return NO;
}


@end
