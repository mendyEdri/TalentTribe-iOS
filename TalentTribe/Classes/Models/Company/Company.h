//
//  Company.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Story, CompanyInfo;

@interface Company : NSObject <NSCopying>

@property (nonatomic, strong) NSString *companyId;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *companyLogo;

@property (nonatomic, strong) NSString *about;

@property (nonatomic, strong) NSString *employees;
@property (nonatomic, strong) NSString *founded;
@property (nonatomic, strong) NSString *funding;
@property (nonatomic, strong) NSString *stage;
@property (nonatomic, strong) NSString *headquarters;
@property (nonatomic, strong) NSString *industry;

@property (nonatomic, strong) NSString *webLink;

@property double latitude;
@property double longitude;

@property (nonatomic, strong) NSArray *jobs;
@property (nonatomic, strong) NSArray *stories;
@property (nonatomic, strong) NSMutableArray *storiesFeed;
@property NSInteger currentFeedPage;
@property NSInteger currentStoryShowIndex;

@property (nonatomic, strong) CompanyInfo *companyInfo;

@property BOOL vibeDisabled;
@property BOOL wannaWork;

- (id)initWithDictionary:(NSDictionary *)dict;

- (void)populateFromDict:(NSDictionary *)dict;

- (NSDictionary *)dictionary;

- (NSInteger)indexOfStoryByType:(Story *)story;

- (BOOL)userVibed;

@end
