//
//  Education.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/7/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Institution.h"

@interface Education : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *educationId;
@property (nonatomic, strong) NSDate *educationStartDate;
@property (nonatomic, strong) NSDate *educationEndDate;

@property (nonatomic, strong) NSString *educationDegree;
@property (nonatomic, strong) NSString *educationField;
@property (nonatomic, strong) NSString *educationSchool;
@property (nonatomic, strong) NSString *studyID;
@property (nonatomic, strong) Institution *institution;

- (id)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionary;
- (NSDictionary *)removeDictionary;

- (BOOL)isEqualToEducation:(Education *)education;

- (BOOL)isFilled;
- (BOOL)isPartiallyFilled;

@end
