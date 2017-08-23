//
//  Category.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFixedCategories @"fixedCategories"
#define kTrendingCategories @"trendCategories"

@interface StoryCategory : NSObject

@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryLogo;
@property NSInteger storiesNum;
@property NSInteger userViewTimes;
@property BOOL showAlways;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
