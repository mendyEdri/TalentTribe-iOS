//
//  User.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "User.h"
#import "Position.h"
#import "Education.h"
#import "LinkedInToken.h"

#define kUserId @"userId"
#define kFirstName @"firstName"
#define kLastName @"lastName"
#define kEmail @"email"
#define kContactEmail @"contactEmail"
#define kPhone @"phone"
#define kCountry @"country"
#define kCity @"city"
#define kAddress @"address"
#define kEducation @"education"
#define kPositions @"positions"
#define kValidatedCompanies @"companyValidated"
#define kUserVibeCount @"userVibeCount"
#define kLinkedInToken @"linkedInToken"
#define kProfileImage @"profileImage"
#define kSkills @"skills"
#define kSummary @"freeText"
#define kLanguages @"languages"
#define kCompany @"userCompany"
#define kRoles @"roles"
#define kUserCV @"userCV"
#define kCVURL @"cvLink"

@implementation User

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self populateFromDict:dict];
    }
    return self;
}

- (void)populateFromDict:(NSDictionary *)dict {
    if ([dict objectForKeyOrNil:kUserId]) {
        self.userID = [dict objectForKeyOrNil:kUserId];
    }
    if ([dict objectForKeyOrNil:kFirstName]) {
        self.userFirstName = [dict objectForKeyOrNil:kFirstName];
    }
    if ([dict objectForKeyOrNil:kLastName]) {
        self.userLastName = [dict objectForKeyOrNil:kLastName];
    }
    if ([dict objectForKeyOrNil:kEmail]) {
        self.userEmail = [dict objectForKeyOrNil:kEmail];
    }
    if ([dict objectForKeyOrNil:kContactEmail]) {
        self.userContactEmail = [dict objectForKeyOrNil:kContactEmail];
    }
    if (!self.userContactEmail.length) {
        self.userContactEmail = self.userEmail;
    }
    if ([dict objectForKeyOrNil:kProfileImage]) {
        self.userProfileImageURL = [dict objectForKeyOrNil:kProfileImage];
    }
    if ([dict objectForKeyOrNil:kCountry]) {
        self.userCountry = [dict objectForKeyOrNil:kCountry];
    }
    if ([dict objectForKeyOrNil:kCity]) {
        self.userCity = [dict objectForKeyOrNil:kCity];
    }
    if ([dict objectForKeyOrNil:kAddress]) {
        self.userAddress = [dict objectForKeyOrNil:kAddress];
    }
    if ([dict objectForKeyOrNil:kPhone]) {
        self.userPhone = [dict objectForKeyOrNil:kPhone];
    }
    if ([dict objectForKeyOrNil:kSummary]) {
        self.userProfileSummary = dict[kSummary];
        if (self.userProfileSummary.length > kSummaryCharacterLimit) {
            self.userProfileSummary = [dict[kSummary] substringToIndex:kSummaryCharacterLimit];
        }
    }
    if ([dict objectForKeyOrNil:kSkills]) {
        self.skills = [[NSMutableArray alloc] initWithArray:[dict objectForKeyOrNil:kSkills]];
    }
    if ([dict objectForKeyOrNil:kPositions] && [[dict objectForKeyOrNil:kPositions] isKindOfClass:[NSArray class]]) {
        [self setPositionsFromArray:(NSArray *)[dict objectForKeyOrNil:kPositions]];
    }
    if ([dict objectForKeyOrNil:kEducation] && [[dict objectForKeyOrNil:kEducation] isKindOfClass:[NSArray class]]) {
        [self setEducationFromArray:(NSArray *)[dict objectForKeyOrNil:kEducation]];
    }
    if ([dict objectForKeyOrNil:kValidatedCompanies] && [[dict objectForKeyOrNil:kValidatedCompanies] isKindOfClass:[NSArray class]]) {
        [self setValidatedCompaniesFromArray:(NSArray *)[dict objectForKeyOrNil:kValidatedCompanies]];
    }
    if ([dict objectForKeyOrNil:kLanguages]) {
        [self setLanguagesFromArray:(NSArray *)[dict objectForKeyOrNil:kLanguages]];
    }
    if ([dict objectForKeyOrNil:kCompany])
    {
        self.company = [[Company alloc]initWithDictionary:dict];
    }
    if ([dict objectForKeyOrNil:kRoles] && [[dict objectForKeyOrNil:kRoles] isKindOfClass:[NSArray class]]) {
        self.userRoles = [[NSMutableArray alloc] initWithArray:[dict objectForKeyOrNil:kRoles]];
    }
    if ([dict objectForKeyOrNil:kUserCV][kCVURL] && [[dict objectForKeyOrNil:kUserCV][kCVURL] isKindOfClass:[NSString class]]) {
        self.userCVURL = [dict objectForKeyOrNil:kUserCV][kCVURL];
    }
}

- (void)setPositionsFromDict:(NSDictionary *)dict {
    if (dict) {
        NSArray *values = [dict objectForKeyOrNil:@"values"];
        [self setPositionsFromArray:values];
    }
}

- (void)setPositionsFromArray:(NSArray *)array {
    if (array) {
        NSMutableArray *positions = [NSMutableArray new];
        for (NSDictionary *positionDict in array) {
            Position *position = [[Position alloc] initWithDictionary:positionDict];
            [positions addObject:position];
        }
        if (positions.count) {
            self.positions = [[NSMutableArray alloc] initWithArray:positions];
        }
    }
}

- (void)setEducationFromArray:(NSArray *)array {
    if (array) {
        NSMutableArray *educations = [NSMutableArray new];
        for (NSDictionary *educationDict in array) {
            Education *education = [[Education alloc] initWithDictionary:educationDict];
            [educations addObject:education];
        }
        if (educations.count) {
            self.educations = [[NSMutableArray alloc] initWithArray:educations];
        }
    }
}

- (void)setLanguagesFromArray:(NSArray *)array {
    if (array) {
        NSMutableArray *languages = [[NSMutableArray alloc] initWithArray:array];
        if (languages.count) {
            self.languages = languages;
        }
    }
}

- (void)setValidatedCompaniesFromArray:(NSArray *)array {
    if (array) {
        NSMutableArray *companies = [NSMutableArray new];
        for (NSDictionary *companyDict in array) {
            NSDictionary *companyDictKey = @{@"company": companyDict};
            Company *company = [[Company alloc] initWithDictionary:companyDictKey];
            [companies addObject:company];
        }
        if (companies.count) {
            self.validatedCompanies = [[NSMutableArray alloc] initWithArray:companies];
        }
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.userID) {
        [dict setObject:self.userID forKey:kUserId];
    }
    if (self.userFirstName) {
        [dict setObject:self.userFirstName forKey:kFirstName];
    }
    if (self.userLastName) {
        [dict setObject:self.userLastName forKey:kLastName];
    }
    if (self.userEmail) {
        [dict setObject:self.userEmail forKey:kEmail];
    }
    if (self.userContactEmail) {
        [dict setObject:self.userContactEmail forKey:kContactEmail];
    }
    if (self.userProfileImage) {
        [dict setObject:[UIImagePNGRepresentation(self.userProfileImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:kProfileImage];
    }
    
    if (self.positions) {
        NSMutableArray *positionsDicts = [NSMutableArray new];
        for (Position *position in self.positions) {
            [positionsDicts addObject:[position dictionary]];
        }
        
        if (self.removedPositions.count) {
            for (Position *position in self.removedPositions) {
                NSDictionary *removeDict = [position removeDictionary];
                if (removeDict) {
                    [positionsDicts addObject:removeDict];
                }
            }
            [self.removedPositions removeAllObjects];
        }
        
        [dict setObject:positionsDicts forKey:kPositions];
    }
    
    if (self.educations) {
        NSMutableArray *educationsDicts = [NSMutableArray new];
        for (Education *education in self.educations) {
            [educationsDicts addObject:[education dictionary]];
        }
        if (self.removedEducations.count) {
            for (Education *education in self.removedEducations) {
                NSDictionary *removeDict = [education removeDictionary];
                if (removeDict) {
                    [educationsDicts addObject:removeDict];
                }
            }
            [self.removedEducations removeAllObjects];
        }
        [dict setObject:educationsDicts forKey:kEducation];
    }
    
    if (self.userRoles) {
        [dict setObject:self.userRoles forKey:kRoles];
    }
    
    if (self.languages) {
        [dict setObject:self.languages forKey:kLanguages];
    }
    
    if (self.skills) {
        [dict setObject:self.skills forKey:kSkills];
    }
    
    if (self.userPhone) {
        [dict setObject:self.userPhone forKey:kPhone];
    }
    if (self.userProfileSummary) {
        [dict setObject:self.userProfileSummary forKey:kSummary];
    }
    if (self.company)
    {
        [dict setObject:[self.company dictionary] forKey:kCompany];
    }
    
    if (self.userRoles) {
        [dict setObject:self.userRoles forKey:kRoles];
    }
    
    return dict;
}

- (NSMutableArray *)userRoles {
    if (!_userRoles) {
        _userRoles = [NSMutableArray new];
    }
    return _userRoles;
}

- (NSMutableArray *)positions {
    if (!_positions) {
        _positions = [NSMutableArray new];
    }
    return _positions;
}

- (NSMutableArray *)languages {
    if (!_languages) {
        _languages = [NSMutableArray new];
    }
    return _languages;
}

- (NSMutableArray *)educations {
    if (!_educations) {
        _educations = [NSMutableArray new];
    }
    return _educations;
}

- (NSMutableArray *)skills {
    if (!_skills) {
        _skills = [NSMutableArray new];
    }
    return _skills;
}

- (NSMutableArray *)removedPositions {
    if (!_removedPositions) {
        _removedPositions = [NSMutableArray new];
    }
    return _removedPositions;
}

- (NSMutableArray *)removedEducations {
    if (!_removedEducations) {
        _removedEducations = [NSMutableArray new];
    }
    return _removedEducations;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userID = [aDecoder decodeObjectForKey:kUserId];
        self.userFirstName = [aDecoder decodeObjectForKey:kFirstName];
        self.userLastName = [aDecoder decodeObjectForKey:kLastName];
        self.userEmail = [aDecoder decodeObjectForKey:kEmail];
        self.userContactEmail = [aDecoder decodeObjectForKey:kContactEmail];
        self.userPhone = [aDecoder decodeObjectForKey:kPhone];
        self.userCountry = [aDecoder decodeObjectForKey:kCountry];
        self.userCity = [aDecoder decodeObjectForKey:kCity];
        self.userAddress = [aDecoder decodeObjectForKey:kAddress];
        self.remainVibeCount = [aDecoder decodeIntegerForKey:kUserVibeCount];
        self.linkedInToken = [aDecoder decodeObjectForKey:kLinkedInToken];
        self.userProfileImageURL = [aDecoder decodeObjectForKey:kProfileImage];
        self.positions = [aDecoder decodeObjectForKey:kPositions];
        self.educations = [aDecoder decodeObjectForKey:kEducation];
        self.languages = [aDecoder decodeObjectForKey:kLanguages];
        self.userRoles = [aDecoder decodeObjectForKey:kRoles];
        self.userProfileSummary = [aDecoder decodeObjectForKey:kSummary];
        self.company = [aDecoder decodeObjectForKey:kCompany];
        self.validatedCompanies = [aDecoder decodeObjectForKey:kValidatedCompanies];
        self.userCVURL = [aDecoder decodeObjectForKey:kUserCV];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userID forKey:kUserId];
    [aCoder encodeObject:self.userFirstName forKey:kFirstName];
    [aCoder encodeObject:self.userLastName forKey:kLastName];
    [aCoder encodeObject:self.userEmail forKey:kEmail];
    [aCoder encodeObject:self.userContactEmail forKey:kContactEmail];
    [aCoder encodeObject:self.userPhone forKey:kPhone];
    [aCoder encodeObject:self.userCountry forKey:kCountry];
    [aCoder encodeObject:self.userCity forKey:kCity];
    [aCoder encodeObject:self.userAddress forKey:kAddress];
    [aCoder encodeInteger:self.remainVibeCount forKey:kUserVibeCount];
    [aCoder encodeObject:self.linkedInToken forKey:kLinkedInToken];
    [aCoder encodeObject:self.userProfileImageURL forKey:kProfileImage];
    [aCoder encodeObject:self.positions forKey:kPositions];
    [aCoder encodeObject:self.educations forKey:kEducation];
    [aCoder encodeObject:self.languages forKey:kLanguages];
    [aCoder encodeObject:self.userRoles forKey:kRoles];
    [aCoder encodeObject:self.userProfileSummary forKey:kSummary];
    [aCoder encodeObject:self.company forKey:kCompany];
    [aCoder encodeObject:self.validatedCompanies forKey:kValidatedCompanies];
    [aCoder encodeObject:self.userCVURL forKey:kUserCV];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    User *instance = [[[self class] allocWithZone:zone] init];
    instance.userID = [self.userID copy];
    instance.userFirstName = [self.userFirstName copy];
    instance.userLastName = [self.userLastName copy];
    instance.userEmail = [self.userEmail copy];
    instance.userContactEmail = [self.userContactEmail copy];
    instance.userPhone = [self.userPhone copy];
    instance.userCountry = [self.userCountry copy];
    instance.userCity = [self.userCity copy];
    instance.userAddress = [self.userAddress copy];
    instance.remainVibeCount = self.remainVibeCount;
    instance.linkedInToken = [self.linkedInToken copy];
    instance.userProfileImageURL = [self.userProfileImageURL copy];
    instance.userProfileImage = [self.userProfileImage copy];
    instance.positions = [self.positions mutableCopy];
    instance.educations = [self.educations mutableCopy];
    instance.languages = [self.languages mutableCopy];
    instance.userRoles = [self.userRoles mutableCopy];
    instance.userProfileSummary = [self.userProfileSummary copy];
    instance.company = [self.company copy];
    instance.skills = [self.skills mutableCopy];
    instance.validatedCompanies = [self.validatedCompanies mutableCopy];
    instance.userCVURL = [self.userCVURL copy];
    return instance;
}

- (BOOL)isEqualToUser:(User *)user {
    if ([self compareObject:self.userID withObject:user.userID] &&
        [self compareObject:self.userFirstName withObject:user.userFirstName] &&
        [self compareObject:self.userLastName withObject:user.userLastName] &&
        [self compareObject:self.userEmail withObject:user.userEmail] &&
        [self compareObject:self.userContactEmail withObject:user.userContactEmail] &&
        [self compareObject:self.userPhone withObject:user.userPhone] &&
        [self compareObject:self.userCountry withObject:user.userCountry] &&
        [self compareObject:self.userCity withObject:user.userCity] &&
        [self compareObject:self.userAddress withObject:user.userAddress] &&
        [self compareObject:self.userProfileSummary withObject:user.userProfileSummary] &&
        [self compareObject:self.linkedInToken withObject:user.linkedInToken] &&
        [self compareObject:self.userProfileImage withObject:user.userProfileImage] &&
        [self compareObject:self.userProfileImageURL withObject:user.userProfileImageURL] &&
        [self compareObject:self.userCVURL withObject:user.userCVURL] &&
        [self compareObject:self.company withObject:user.company] &&
        [self comparePositionsToPositions:user.positions] &&
        [self compareEducationsToEducations:user.educations] &&
        [self compareSkillsToSkills:user.skills] &&
        [self compareLanguagesToLanguages:user.languages] &&
        [self compareRolesToRoles:user.userRoles])
    {
        return YES;
    }
    return NO;
}

- (BOOL)compareObject:(NSObject *)object1 withObject:(NSObject *)object2 {
    if (!object1 && !object2) {
        //DLog(@"COMPARING TWO FIELDS, BOTH ARE EMPTY, RESULT = YES");
        return YES;
    } else {
        if ([object1 isKindOfClass:[NSString class]] || [object2 isKindOfClass:[NSString class]]) {
            NSString *string1 = (NSString *)object1;
            NSString *string2 = (NSString *)object2;
            if (string1.length == 0 && string2.length == 0) {
                //DLog(@"COMPARING TWO STRINGS, BOTH LENGTH = 0, RESULT = YES");
                return YES;
            } else {
                //DLog(@"COMPARING TWO STRINGS, %@ %@, RESULT = %d", string1, string2, [string1 isEqualToString:string2]);
                return [string1 isEqualToString:string2];
            }
        } else if ([object1 isKindOfClass:[LinkedInToken class]] || [object2 isKindOfClass:[LinkedInToken class]]) {
            LinkedInToken *token1 = (LinkedInToken *)object1;
            LinkedInToken *token2 = (LinkedInToken *)object2;
            //DLog(@"COMPARING TWO TOKENS, %@ %@, RESULT = %d", token1, token2, [token1 isEqualToToken:token2]);
            return [token1 isEqualToToken:token2];
        } else {
            //DLog(@"COMPARING TWO OBJECTS, %@ %@, RESULT = %d", object1, object2, [object1 isEqual:object2]);
            return [object1 isEqual:object2];
        }
    }
}

- (BOOL)comparePositionsToPositions:(NSArray *)positions {
    if (self.positions.count == positions.count) {
        for (Position *firstPosition in self.positions) {
            BOOL found = NO;
            for (Position *secondPosition in positions) {
                if ([firstPosition isEqualToPosition:secondPosition]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                //DLog(@"COMPARING POSITIONS, RESULT = NO");
                return NO;
            }
        }
        //DLog(@"COMPARING POSITIONS, RESULT = YES");
        return YES;
    } else {
        //DLog(@"COMPARING POSITIONS, COUNT NOT EQUAL, RESULT = NO");
        return NO;
    }
}

- (BOOL)compareEducationsToEducations:(NSArray *)educations {
    if (self.educations.count == educations.count) {
        for (Education *firstEducation in self.educations) {
            BOOL found = NO;
            for (Education *secondEducation in educations) {
                if ([firstEducation isEqualToEducation:secondEducation]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                //DLog(@"COMPARING EDUCATIONS, RESULT = NO");
                return NO;
            }
        }
        //DLog(@"COMPARING EDUCATIONS, RESULT = YES");
        return YES;
    } else {
        //DLog(@"COMPARING EDUCATIONS, COUNT NOT EQUAL, RESULT = NO");
        return NO;
    }
}

- (BOOL)compareLanguagesToLanguages:(NSArray *)languages {
    if (self.languages.count == languages.count) {
        for (NSString *firstLanguage in self.languages) {
            BOOL found = NO;
            for (NSString *secondLanguage in languages) {
                if ([firstLanguage isEqualToString:secondLanguage]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                //DLog(@"COMPARING LANGUAGES, RESULT = NO");
                return NO;
            }
        }
        //DLog(@"COMPARING LANGUAGES, RESULT = YES");
        return YES;
    } else {
        //DLog(@"COMPARING LANGUAGES, COUNT NOT EQUAL, RESULT = NO");
        return NO;
    }
}

- (BOOL)compareRolesToRoles:(NSArray *)roles {
    if (self.userRoles.count == roles.count) {
        for (NSString *firstRole in self.userRoles) {
            BOOL found = NO;
            for (NSString *secondRole in roles) {
                if ([firstRole isEqualToString:secondRole]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                //DLog(@"COMPARING ROLES, RESULT = NO");
                return NO;
            }
        }
        //DLog(@"COMPARING ROLES, RESULT = YES");
        return YES;
    } else {
        //DLog(@"COMPARING ROLES, COUNT NOT EQUAL, RESULT = NO");
        return NO;
    }
}

- (BOOL)compareSkillsToSkills:(NSArray *)skills {
    if (self.skills.count == skills.count) {
        for (NSString *firstSkill in self.skills) {
            BOOL found = NO;
            for (NSString *secondSkill in skills) {
                if ([firstSkill isEqualToString:secondSkill]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                //DLog(@"COMPARING SKILLS, RESULT = NO");
                return NO;
            }
        }
        //DLog(@"COMPARING SKILLS, RESULT = YES");
        return YES;
    } else {
        //DLog(@"COMPARING SKILLS, COUNT NOT EQUAL, RESULT = NO");
        return NO;
    }
}

- (void)addPositionsFromArray:(NSArray *)positions {
    if (!self.positions) {
        self.positions = [NSMutableArray new];
    }
    NSMutableArray *itemsToAdd = [NSMutableArray new];
    for (Position *firstPosition in positions) {
        BOOL found = NO;
        for (Position *secondPosition in self.positions) {
            if ([firstPosition isEqualToPosition:secondPosition]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [itemsToAdd addObject:firstPosition];
        }
    }
    [self.positions addObjectsFromArray:itemsToAdd];
}
- (void)addEducationsFromArray:(NSArray *)educations {
    if (!self.educations) {
        self.educations = [NSMutableArray new];
    }
    NSMutableArray *itemsToAdd = [NSMutableArray new];
    for (Education *firstEducation in educations) {
        BOOL found = NO;
        for (Education *secondEducation in self.educations) {
            if ([firstEducation isEqualToEducation:secondEducation]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [itemsToAdd addObject:firstEducation];
        }
    }
    [self.educations addObjectsFromArray:itemsToAdd];
}

- (BOOL)isProfileFilled {
    if (self.userFirstName.length > 0 &&
        self.userLastName.length > 0 &&
        self.userProfileSummary.length > 0 &&
        self.userEmail.length > 0 &&
        self.userPhone.length > 0 &&
        self.positions.count > 0 &&
        self.educations.count > 0 &&
        self.skills.count > 0 &&
        self.languages.count > 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isProfilePartiallyFilled {
    if (self.userFirstName.length > 0 ||
        self.userLastName.length > 0 ||
        self.userProfileSummary.length > 0 ||
        self.userPhone.length > 0 ||
        self.positions.count > 0 ||
        self.educations.count > 0 ||
        self.skills.count > 0 ||
        self.languages.count > 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isProfileMinimumFilled {
    if (self.userFirstName.length > 0 &&
        self.userLastName.length > 0 &&
        self.userProfileSummary.length > 0 &&
        self.positions.count > 0)
    {
        return YES;
    }
    return NO;
}

@end
