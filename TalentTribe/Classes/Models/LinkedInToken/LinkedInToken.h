//
//  LinkedInToken.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/14/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkedInToken : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSDate *expirationDate;
//@property BOOL registered;

- (id)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isEqualToToken:(LinkedInToken *)token;
- (BOOL)isValid;

@end
