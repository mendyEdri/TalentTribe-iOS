//
//  Snippets.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Snippets : NSObject

@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *content;

- (instancetype)initWithHeader:(NSString *)header content:(NSString *)content;

@end
