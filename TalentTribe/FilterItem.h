//
//  FilterItem.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FilterTypeCategories,
    FilterTypeCompanies,
    FilterTypeIndustry,
    FilterTypeFundingStage,
    FilterTypeStage,
    filterTypesCount,
} FilterType;

@interface FilterItem : NSObject

@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic) FilterType itemType;

+ (NSString *)titleForFilterType:(FilterType)type;

@end
