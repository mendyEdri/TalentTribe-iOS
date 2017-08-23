//
//  QuickSearch.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "QuickSearch.h"
#import "Company.h"

#define kQuickSearchId @"id"
#define kQuickSearchName @"name"
#define kQuickSearchImage @"image"
#define kQuickSearchPromotion @"promotion"
#define kquickSearchRelatedCompanyId @"relatedCompanyId"
#define kquickSearchType @"type"


@implementation QuickSearch


- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            
        
            self.quickSearchType = [dict objectForKeyOrNil:kquickSearchType];
            self.quickSearchId = [dict objectForKeyOrNil:kQuickSearchId];
            self.quickSearchName = [dict objectForKeyOrNil:kQuickSearchName];
            self.quickSearchImage = [dict objectForKeyOrNil:kQuickSearchImage];
            self.quickSearchPromotion = [dict objectForKeyOrNil:kQuickSearchPromotion];
            self.quickSearchRelatedCompanyId = [dict objectForKeyOrNil:kquickSearchRelatedCompanyId];


        }
    }
    
    return self;
}



@end
