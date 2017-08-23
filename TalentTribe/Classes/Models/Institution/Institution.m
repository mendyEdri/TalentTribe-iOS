//
//  Institution.m
//  TalentTribe
//
//  Created by Mendy on 15/12/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "Institution.h"

#define kInstitutionID @"institutionId"
#define KInstitutionType @"type"
#define kInstitutionName @"institutionName"
#define kInstitutionLogo @"logo"

@implementation Institution

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.institutionID = [dict objectForKeyOrNil:kInstitutionID];
        self.institutionType = [dict objectForKeyOrNil:KInstitutionType];
        self.institutionName = [dict objectForKeyOrNil:kInstitutionName];
        self.institutionLogo = [dict objectForKeyOrNil:kInstitutionLogo];
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.institutionID ? self.institutionID : @"" forKey:kInstitutionID];
    [dict setObject:self.institutionType ? self.institutionType : @"" forKey:KInstitutionType];
    [dict setObject:self.institutionName ? self.institutionName : @"" forKey:kInstitutionName];
    [dict setObject:self.institutionLogo ? self.institutionLogo : @"" forKey:kInstitutionLogo];
    return [dict copy];
}

@end
