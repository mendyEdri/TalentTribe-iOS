//
//  Author.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Author : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *profileImageLink;
@property (nonatomic, strong) NSString *email;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
