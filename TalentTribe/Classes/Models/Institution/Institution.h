//
//  Institution.h
//  TalentTribe
//
//  Created by Mendy on 15/12/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Institution : NSObject

@property (nonatomic, strong) NSString *institutionID;
@property (nonatomic, strong) NSString *institutionType;
@property (nonatomic, strong) NSString *institutionName;
@property (nonatomic, strong) NSString *institutionLogo;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;
@end
