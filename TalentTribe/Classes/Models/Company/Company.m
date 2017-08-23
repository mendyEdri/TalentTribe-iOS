//
//  Company.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Company.h"
#import "Story.h"
#import "CompanyInfo.h"

#define kUserCompany @"userCompany"
#define kCompanyDict @"company"
#define kCompanyId @"companyId"
#define kCompanyName @"companyName"
#define kName @"name"
#define kCompanyLogo @"companyLogo"
#define kEmployees @"employees"
#define kFounded @"founded"
#define kFunding @"funding"
#define kIndustry @"industry"
#define kLocation @"location"
#define kAddress @"address"
#define kLatitude @"latitude"
#define kLongitude @"longitude"
#define kCompanyStories @"storyListWrapper" //storyList
#define kCompanyAboutDict @"about"
#define kCompanyAboutString @"description"
#define kWannaWork @"userWannaWork"
#define kVibeDisabled @"vibeDisabled"
#define kAppStory @"appStory"
#define kWebLink @"webLink"

@interface Company ()

@end

@implementation Company

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            
            NSDictionary *companyDict = [dict objectForKeyOrNil:kCompanyDict];
            if (!companyDict)
            {
                companyDict = [dict objectForKeyOrNil:kUserCompany];
                if (!companyDict)
                {
                    companyDict = dict;
                }
            }
            
            if (dict) {
                self.companyId = [companyDict objectForKeyOrNil:kCompanyId];
                self.companyName = [companyDict objectForKeyOrNil:kCompanyName] ?: [companyDict objectForKeyOrNil:kName];
                
                if ([self.companyName isEqualToString:STORYFEED_DEFAULT_GENERAL_ID]) {
                    self.companyId = STORYFEED_DEFAULT_GENERAL_ID;
                    self.companyName = nil;
                }
                
                self.companyLogo = [companyDict objectForKeyOrNil:kCompanyLogo];
                
                self.wannaWork = [[companyDict objectForKeyOrNil:kWannaWork] boolValue];
                self.vibeDisabled = [[companyDict objectForKeyOrNil:kVibeDisabled] boolValue];
            }
            
            NSDictionary *companyAboutDict = [companyDict objectForKeyOrNil:kCompanyAboutDict];
            if (companyAboutDict) {
                [self populateFromAboutDict:companyAboutDict];
            }
            
            NSArray *storyList = [dict objectForKeyOrNil:kCompanyStories];
            if (storyList) {
                NSMutableArray *storiesContainer = [NSMutableArray new];
                for (NSDictionary *storyDict in storyList) {
                    Story *story = [[Story alloc] initWithDictionary:storyDict];
                    if (story) {
                        story.companyId = self.companyId;
                        [storiesContainer addObject:story];
                    }
                }
                self.stories = storiesContainer;
            }
            
            self.currentFeedPage = 0;
            self.storiesFeed = [NSMutableArray new];
            
        }
    }
    return self;
}

- (void)populateFromDict:(NSDictionary *)companyDict {
    
    self.wannaWork = [[companyDict objectForKeyOrNil:kWannaWork] boolValue];
    self.vibeDisabled = [[companyDict objectForKeyOrNil:kVibeDisabled] boolValue];
    
    self.companyInfo = [[CompanyInfo alloc] initWithDictionary:companyDict];
    
    NSDictionary *companyAboutDict = [companyDict objectForKeyOrNil:kCompanyAboutDict];
    if (companyAboutDict) {
        [self populateFromAboutDict:companyAboutDict];
    }
}

- (void)populateFromAboutDict:(NSDictionary *)companyAboutDict {
    if (companyAboutDict) {
        self.about = [companyAboutDict objectForKeyOrNil:kCompanyAboutString];
        
        NSNumber *employeesNumber = [companyAboutDict objectForKeyOrNil:kEmployees];
        if (employeesNumber) {
            NSString *employeesString;
            NSInteger employeesInt = employeesNumber.integerValue;
            if (employeesInt >= 1000) {
                if (employeesInt % 1000 == 0) {
                    employeesString = [NSString stringWithFormat:@"%ldk", employeesNumber.integerValue / 1000];
                } else {
                    employeesString = [NSString stringWithFormat:@"%0.1fk", employeesNumber.integerValue / 1000.0f];
                }
            } else {
                employeesString = [employeesNumber stringValue];
            }
            self.employees = employeesString;
        }
        self.founded = [companyAboutDict objectForKeyOrNil:kFounded];
        self.funding = [companyAboutDict objectForKeyOrNil:kFunding];
        self.industry = [companyAboutDict objectForKeyOrNil:kIndustry];
        
        self.webLink = [companyAboutDict objectForKeyOrNil:kWebLink];
        
        NSDictionary *location = [companyAboutDict objectForKeyOrNil:kLocation];
        if (location) {
            self.headquarters = [location objectForKeyOrNil:kAddress];
            self.latitude = [[location objectForKeyOrNil:kLatitude] doubleValue];
            self.longitude = [[location objectForKeyOrNil:kLongitude] doubleValue];
        }
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.companyId) {
        [dict setObject:self.companyId forKey:kCompanyId];
    }
    
    if (self.companyName) {
        [dict setObject:self.companyName forKey:kCompanyName];
    }
    return dict;
}

- (NSInteger)indexOfStoryByType:(Story *)currentStory {
    NSInteger index = 0;
    for (Story *story in self.stories) {
        if (story.storyType == currentStory.storyType) {
            if ([story.storyId isEqualToString:currentStory.storyId]) {
                return index;
            }
            index++;
        }
    }
    return index;
}

- (BOOL)userVibed {
    if (self.wannaWork) {
        return YES;
    } else {
        for (Story *story in self.stories) {
            if (story.userLike) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    Company *instance = [[[self class] allocWithZone:zone] init];
    instance.companyId = [self.companyId copy];
    instance.companyLogo = [self.companyLogo copy];
    instance.companyName = [self.companyName copy];
    
    instance.about = [self.about copy];
    instance.funding = [self.funding copy];
    instance.founded = [self.founded copy];
    instance.employees = [self.employees copy];
    instance.stage = [self.stage copy];
    instance.headquarters = [self.headquarters copy];
    instance.industry = [self.industry copy];
    instance.latitude = self.latitude;
    instance.longitude = self.longitude;
    instance.jobs = [self.jobs copy];
    instance.stories = [self.stories copy];
    instance.storiesFeed = [self.storiesFeed copy];
    instance.currentFeedPage = self.currentFeedPage;
    
    instance.vibeDisabled = self.vibeDisabled;
    instance.wannaWork = self.wannaWork;
    
    instance.webLink = [self.webLink copy];
    
    return instance;
}

@end
