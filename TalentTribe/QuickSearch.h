//
//  QuickSearch.h
//  TalentTribe
//
//  Created by Yagil Cohen on 6/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickSearch : NSObject

@property (nonatomic, strong) NSString *quickSearchId;
@property (nonatomic, strong) NSString *quickSearchName;
@property (nonatomic, strong) NSString *quickSearchImage;
@property (nonatomic, strong) NSString *quickSearchPromotion;
@property (nonatomic, strong) NSString *quickSearchRelatedCompanyId;
@property (nonatomic, strong) NSString *quickSearchType;
@property (nonatomic, assign) BOOL isSelected;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
