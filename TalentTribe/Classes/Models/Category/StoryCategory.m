//
//  Category.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryCategory.h"


#define kCategoryName @"name"
#define kCategoryLogo @"logo"
#define kShowAlways @"showAlways"
#define kUserViewTimes @"userViewTimes"
#define kStoriesNum @"storiesNum"

@implementation StoryCategory

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.categoryName = [dict objectForKeyOrNil:kCategoryName];
            self.categoryLogo = [dict objectForKeyOrNil:kCategoryLogo];
            self.storiesNum = [[dict objectForKeyOrNil:kStoriesNum] integerValue];
            self.showAlways = [[dict objectForKeyOrNil:kShowAlways] boolValue];
            self.userViewTimes = [[dict objectForKeyOrNil:kUserViewTimes] integerValue];
        }
    }
    return self;
}

@end
