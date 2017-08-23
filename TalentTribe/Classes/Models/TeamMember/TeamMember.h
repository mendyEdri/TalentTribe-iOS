//
//  TeamMember.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TeamMemberTypeFounder,
    TeamMemberTypeRest,
} TeamMemberType;

@interface TeamMember : NSObject

@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *profileImageLink;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *occupation;

@property TeamMemberType type;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
