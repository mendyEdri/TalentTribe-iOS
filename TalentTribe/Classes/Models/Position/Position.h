//
//  Position.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/21/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Company;

@interface Position : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *positionId;
@property (nonatomic, strong) NSString *positionNumber;
@property (nonatomic, strong) Company *positionCompany;
@property (nonatomic, strong) NSString *positionSummary;
@property (nonatomic, strong) NSString *positionTitle;
@property (nonatomic, strong) NSString *positionLocation;

@property (nonatomic, strong) NSDate *positionStartDate;
@property (nonatomic, strong) NSDate *positionEndDate;

@property (nonatomic) BOOL currentPosition;

- (id)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionary;
- (NSDictionary *)removeDictionary;

- (BOOL)isEqualToPosition:(Position *)position;

- (BOOL)isFilled;
- (BOOL)isPartiallyFilled;

@end
