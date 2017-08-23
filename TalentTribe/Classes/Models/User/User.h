//
//  User.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"

@class Company, LinkedInToken;

@interface User : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userLastName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userContactEmail;
@property (nonatomic, strong) NSString *userPhone;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *userProfileImageURL;
@property (nonatomic, strong) UIImage *userProfileImage;
@property (nonatomic, strong) NSString *userProfileSummary;
@property (nonatomic, strong) NSString *userCountry;
@property (nonatomic, strong) NSString *userCity;
@property (nonatomic, strong) NSString *userAddress;
@property (nonatomic, strong) NSMutableArray *userRoles;
@property (nonatomic, strong) NSMutableArray *positions;
@property (nonatomic, strong) NSMutableArray *validatedCompanies;
@property (nonatomic, strong) NSMutableArray *educations;
@property (nonatomic, strong) NSMutableArray *skills;
@property (nonatomic, strong) NSMutableArray *languages;

@property (nonatomic, strong) NSString *userCVURL;

@property (nonatomic, strong) NSMutableArray *removedPositions;
@property (nonatomic, strong) NSMutableArray *removedEducations;

@property (nonatomic, strong) Company *company;
@property (nonatomic, strong) NSArray *jobs;
@property (nonatomic, strong) NSArray *wannaWork;

@property (nonatomic, strong) LinkedInToken *linkedInToken;

@property (nonatomic) NSInteger remainVibeCount;

- (id)initWithDictionary:(NSDictionary *)dict;
- (void)populateFromDict:(NSDictionary *)dict;

- (void)setPositionsFromDict:(NSDictionary *)dict;

- (NSDictionary *)dictionary;

- (BOOL)isEqualToUser:(User *)user;

- (void)addPositionsFromArray:(NSArray *)positions;
- (void)addEducationsFromArray:(NSArray *)educations;

- (BOOL)isProfileFilled;
- (BOOL)isProfilePartiallyFilled;
- (BOOL)isProfileMinimumFilled;

@end
