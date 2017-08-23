//
//  Comment.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Author;

@interface Comment : NSObject

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *commentContent;
@property (nonatomic, strong) UIImage *commentImage;
@property (nonatomic, strong) NSString *commentImageLink;
@property (nonatomic, strong) NSDate *commentDate;
@property (nonatomic, strong) Author *author;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
