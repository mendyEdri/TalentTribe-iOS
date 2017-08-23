//
//  TeamMember.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TeamMember.h"

#define kMemberId @"memberId"
#define kProfileImage @"image"
#define kFullName @"fullName"
#define kOccupation @"occupation"
#define kType @"type"

@implementation TeamMember

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.memberId = [dict objectForKeyOrNil:kMemberId];
            self.fullName = [dict objectForKeyOrNil:kFullName];
            self.occupation = [dict objectForKeyOrNil:kOccupation];
            self.type = [TeamMember teamMemberTypeForString:[dict objectForKeyOrNil:kType]];
            
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

+ (TeamMemberType)teamMemberTypeForString:(NSString *)string {
    if ([string isEqualToString:[TeamMember stringForTeamMemberType:TeamMemberTypeFounder]]) {
        return TeamMemberTypeFounder;
    } else if ([string isEqualToString:[TeamMember stringForTeamMemberType:TeamMemberTypeRest]]) {
        return TeamMemberTypeRest;
    }
    return TeamMemberTypeRest;
}

+ (NSString *)stringForTeamMemberType:(TeamMemberType)type {
    switch (type) {
        case TeamMemberTypeFounder: {
            return @"FOUNDER";
        } break;
        case TeamMemberTypeRest: {
            return @"REST_OF_TEAM";
        } break;
        default: {
            return nil;
        } break;
    }
}


@end
