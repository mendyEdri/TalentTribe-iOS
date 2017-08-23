//
//  Position.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/21/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Position.h"
#import "Company.h"

#define kSummary @"summary"
#define kJobDescription @"description"
#define kTitle @"title"
#define kJobTitle @"jobTitle"
#define kStartDate @"startDate"
#define kEndDate @"endDate"
#define kSince @"since"
#define kEnd @"end"
#define kCompany @"company"
#define kName @"name"
#define kCurrent @"isCurrent"
#define kYear @"year"
#define kMonth @"month"
#define kPositionId @"positionId"
#define kPositionNumber @"positionNumber"
#define kLocation @"location"
#define kAddress @"address"

@implementation Position

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.positionId = [dict objectForKeyOrNil:kPositionId];
        self.positionNumber = [dict objectForKey:kPositionNumber];
        self.positionSummary = [dict objectForKeyOrNil:kSummary] ?: [dict objectForKeyOrNil:kJobDescription];
        self.positionTitle = [dict objectForKeyOrNil:kTitle] ?: [dict objectForKeyOrNil:kJobTitle];
        if ([dict objectForKeyOrNil:kCompany]) {
            self.positionCompany = [[Company alloc] initWithDictionary:[dict objectForKeyOrNil:kCompany]];
        }
        
        if ([dict objectForKeyOrNil:kStartDate]) {
            NSInteger month = [[[dict objectForKeyOrNil:kStartDate] objectForKeyOrNil:kMonth] integerValue];
            NSInteger year = [[[dict objectForKeyOrNil:kStartDate] objectForKeyOrNil:kYear] integerValue];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = year;
            components.month = month;
            self.positionStartDate = [[NSCalendar currentCalendar] dateFromComponents:components];
        } else if ([dict objectForKeyOrNil:kSince]) {
            self.positionStartDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKeyOrNil:kSince] doubleValue]];
        }
        
        if ([dict objectForKeyOrNil:kLocation]) {
            self.positionLocation = [[dict objectForKeyOrNil:kLocation] objectForKeyOrNil:kAddress];
        }
        
        if ([dict objectForKeyOrNil:kEndDate]) {
            NSInteger month = [[[dict objectForKeyOrNil:kEndDate] objectForKeyOrNil:kMonth] integerValue];
            NSInteger year = [[[dict objectForKeyOrNil:kEndDate] objectForKeyOrNil:kYear] integerValue];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = year;
            components.month = month;
            self.positionEndDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            self.currentPosition = NO;
        } else if ([dict objectForKeyOrNil:kEnd]) {
            self.positionEndDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKeyOrNil:kEnd] doubleValue]];
            self.currentPosition = NO;
        } else {
            self.currentPosition = YES;
        }
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.positionId) {
        [dict setObject:self.positionId forKey:kPositionId];
    }
    if (self.positionCompany) {
        [dict setObject:[self.positionCompany dictionary] forKey:kCompany];
    }
    if (self.positionTitle) {
        [dict setObject:self.positionTitle forKey:kJobTitle];
    }
    if (self.positionSummary) {
        [dict setObject:self.positionSummary forKey:kJobDescription];
    }
    if (self.positionLocation) {
        [dict setObject:self.positionLocation forKey:@"location"];
    }
    if (self.positionStartDate) {
        [dict setObject:@((NSInteger)[self.positionStartDate timeIntervalSince1970]) forKey:kSince];
        [dict setObject:(self.currentPosition ? @YES : @NO) forKey:kCurrent];
    }
    if (self.positionEndDate) {
        [dict setObject:@((NSInteger)[self.positionEndDate timeIntervalSince1970]) forKey:kEnd];
    } else {
        [dict setObject:[NSNull null] forKey:kEnd];
    }
    return dict;
}

- (NSDictionary *)removeDictionary {
    if (self.positionId) {
        return @{kPositionId : self.positionId};
    }
    return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.positionId = [aDecoder decodeObjectForKey:kPositionId];
        self.positionStartDate = [aDecoder decodeObjectForKey:kStartDate];
        self.positionEndDate = [aDecoder decodeObjectForKey:kEndDate];
        self.positionCompany = [aDecoder decodeObjectForKey:kCompany];
        self.positionSummary = [aDecoder decodeObjectForKey:kSummary];
        self.positionTitle = [aDecoder decodeObjectForKey:kTitle];
        self.positionLocation = [aDecoder decodeObjectForKey:kLocation];
        self.currentPosition = [aDecoder decodeBoolForKey:kCurrent];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.positionId forKey:kPositionId];
    [aCoder encodeObject:self.positionTitle forKey:kTitle];
    [aCoder encodeObject:self.positionSummary forKey:kSummary];
    [aCoder encodeObject:self.positionStartDate forKey:kStartDate];
    [aCoder encodeObject:self.positionEndDate forKey:kEndDate];
    [aCoder encodeObject:self.positionCompany forKey:kCompany];
    [aCoder encodeObject:self.positionLocation forKey:kLocation];
    [aCoder encodeBool:self.currentPosition forKey:kCurrent];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    Position *instance = [[[self class] allocWithZone:zone] init];
    instance.positionId = [self.positionId copy];
    instance.positionTitle = [self.positionTitle copy];
    instance.positionSummary = [self.positionSummary copy];
    instance.positionStartDate = [self.positionStartDate copy];
    instance.positionEndDate = [self.positionEndDate copy];
    instance.positionCompany = [self.positionCompany copy];
    instance.positionLocation = self.positionLocation;
    instance.currentPosition = self.currentPosition;
    return instance;
}

- (BOOL)isEqualToPosition:(Position *)position {
    if ([self compareObject:self.positionId withObject:position.positionId] &&
        [self compareObject:self.positionTitle withObject:position.positionTitle] &&
        [self compareObject:self.positionSummary withObject:position.positionSummary] &&
        [self compareObject:self.positionStartDate withObject:position.positionStartDate] &&
        [self compareObject:self.positionEndDate withObject:position.positionEndDate] &&
        [self compareObject:self.positionCompany.companyName withObject:position.positionCompany.companyName] &&
        (self.currentPosition == position.currentPosition)) {
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
    if (self.positionCompany.companyName.length > 0 &&
        self.positionTitle.length > 0 &&
        /*self.positionSummary.length > 0 && */
        self.positionStartDate &&
        (self.positionEndDate || self.currentPosition)) {
        return YES;
    }
    return NO;
}

- (BOOL)isPartiallyFilled {
    if (self.positionCompany.companyName.length > 0 ||
        self.positionTitle.length > 0 ||
        self.positionSummary.length > 0 ||
        self.positionStartDate ||
        self.positionEndDate) {
        return YES;
    }
    return NO;
}

@end
