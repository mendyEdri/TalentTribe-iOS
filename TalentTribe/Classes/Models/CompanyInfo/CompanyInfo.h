//
//  CompanyInfo.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyInfo : NSObject

@property (nonatomic, strong) NSArray *snippets;
@property (nonatomic, strong) NSArray *teamMembers;
@property (nonatomic, strong) NSArray *officePhotos;

@property NSInteger userViewTimes;

@property BOOL promotion;
@property BOOL userWannaWork;
@property BOOL vibeDisabled;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
