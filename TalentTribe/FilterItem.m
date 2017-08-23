//
//  FilterItem.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "FilterItem.h"

@implementation FilterItem

+ (NSString *)titleForFilterType:(FilterType)type {
    switch (type) {
        case FilterTypeCategories: {
            return @"Categories";
        } break;
        case FilterTypeCompanies: {
            return @"Companies";
        } break;
        case FilterTypeIndustry: {
            return @"Industry";
        } break;
        case FilterTypeFundingStage: {
            return @"Funding Stage";
        } break;
        case FilterTypeStage: {
            return @"Stage";
        } break;
            
        default: {
            return nil;
        } break;
    }
}

@end
