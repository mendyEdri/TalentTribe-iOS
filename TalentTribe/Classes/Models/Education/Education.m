//
//  Education.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/7/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Education.h"

#define kEducationId @"educationId"
#define kStartYear @"studyStart"
#define kEndYear @"studyEnd"
#define kDegree @"degree"
#define kField @"fieldOfStudy"
#define kStudyId @"studyId"
#define kInstitution @"institution"

@implementation Education

- (instancetype)init {
    self = [super init];
    if (self) {
        self.institution = [Institution new];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict objectForKeyOrNil:kStartYear]) {
            NSInteger year = [[dict objectForKeyOrNil:kStartYear] integerValue];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = year;
            self.educationStartDate = [[NSCalendar currentCalendar] dateFromComponents:components];
        }
        if ([dict objectForKeyOrNil:kEndYear]) {
            NSInteger year = [[dict objectForKeyOrNil:kEndYear] integerValue];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = year;
            self.educationEndDate = [[NSCalendar currentCalendar] dateFromComponents:components];
        }
        self.educationField = [dict objectForKeyOrNil:kField];
        self.educationDegree = [dict objectForKeyOrNil:kDegree];
        self.studyID = [dict objectForKeyOrNil:kStudyId];
        self.institution = [[Institution alloc] initWithDictionary:dict[kInstitution]];
        
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[self.institution dictionary] forKey:kInstitution];
    if (self.educationId) {
        [dict setObject:self.educationId forKey:kEducationId];
    }
    if (self.educationStartDate) {
        [dict setObject:[NSString stringWithFormat:@"%ld",(long)[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self.educationStartDate].year] forKey:kStartYear];
    }
    if (self.educationEndDate) {
        [dict setObject:[NSString stringWithFormat:@"%ld",(long)[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self.educationEndDate].year] forKey:kEndYear];
    }
    if (self.educationField) {
        [dict setObject:self.educationField forKey:kField];
    }
    if (self.educationDegree) {
        [dict setObject:self.educationDegree forKey:kDegree];
    }
    if (self.studyID) {
        [dict setObject:self.studyID forKey:kStudyId];
    }
    return dict;
}

- (NSDictionary *)removeDictionary {
    if (self.educationId) {
        return @{kEducationId : self.educationId};
    }
    return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.educationId = [aDecoder decodeObjectForKey:kEducationId];
        self.educationStartDate = [aDecoder decodeObjectForKey:kStartYear];
        self.educationEndDate = [aDecoder decodeObjectForKey:kEndYear];
        self.educationDegree = [aDecoder decodeObjectForKey:kDegree];
        self.educationField = [aDecoder decodeObjectForKey:kField];
        self.institution = [Institution new];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.educationId forKey:kEducationId];
    [aCoder encodeObject:self.educationStartDate forKey:kStartYear];
    [aCoder encodeObject:self.educationEndDate forKey:kEndYear];
    [aCoder encodeObject:self.educationDegree forKey:kDegree];
    [aCoder encodeObject:self.educationField forKey:kField];
    self.institution = [Institution new];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    Education *instance = [[[self class] allocWithZone:zone] init];
    instance.educationId = self.educationId;
    instance.educationStartDate = self.educationStartDate;
    instance.educationEndDate = self.educationEndDate;
    instance.educationDegree = self.educationDegree;
    instance.educationField = self.educationField;
    instance.educationSchool = self.educationSchool;
    instance.institution = self.institution;
    instance.institution.institutionName = self.educationSchool;
    return instance;
}

- (BOOL)isEqualToEducation:(Education *)education {
    if ([self compareObject:self.educationId withObject:education.educationId] &&
        [self compareObject:self.educationField withObject:education.educationField] &&
        [self compareObject:self.educationSchool withObject:education.educationSchool] &&
        [self compareObject:self.educationDegree withObject:education.educationDegree] &&
        [self compareObject:self.educationStartDate withObject:education.educationStartDate] &&
        [self compareObject:self.educationEndDate withObject:education.educationEndDate]) {
        return YES;
    }
    return NO;
}


- (BOOL)compareObject:(NSObject *)object1 withObject:(NSObject *)object2 {
    if (!object1 && !object2) {
        return YES;
    } else {
        if ([object1 isKindOfClass:[NSString class]] || [object2 isKindOfClass:[NSString class]]) {
            NSString *string1 = (NSString *)object1;
            NSString *string2 = (NSString *)object2;
            if (string1.length == 0 && string2.length == 0) {
                return YES;
            } else {
                return [string1 isEqualToString:string2];
            }
        } else {
            return [object1 isEqual:object2];
        }
    }
}

- (BOOL)isFilled {
    if (self.educationDegree.length > 0 &&
        self.educationField.length > 0 &&
        self.educationSchool.length > 0 &&
        self.educationStartDate &&
        self.educationEndDate) {
        return YES;
    }
    return NO;
}

- (BOOL)isPartiallyFilled {
    if (self.educationDegree.length > 0 ||
        self.educationField.length > 0 ||
        self.educationSchool.length > 0 ||
        self.educationStartDate ||
        self.educationEndDate) {
        return YES;
    }
    return NO;
}

@end
