//
//  Comment.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Comment.h"
#import "Author.h"

#define kCommmentId @"commentId"
#define kContent @"content"
#define kUser @"user"
#define kImage @"image"
#define kTimePosted @"timePosted"

@implementation Comment

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.commentId = [dict objectForKeyOrNil:kCommmentId];
            self.commentContent = [dict objectForKeyOrNil:kContent];
            
            id imageString = [dict objectForKeyOrNil:kImage];
            if (imageString && [imageString isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:imageString];
                if (url && url.scheme && url.host) {
                    self.commentImageLink = imageString;
                }
            }
            
            if ([dict objectForKeyOrNil:kUser] && ![[dict objectForKeyOrNil:kUser] isEqual:[NSNull null]]) {
                self.author = [[Author alloc] initWithDictionary:[dict objectForKeyOrNil:kUser]];
            }
            
            if ([dict objectForKeyOrNil:kTimePosted] && ![[dict objectForKeyOrNil:kTimePosted] isEqual:[NSNull null]]) {
                self.commentDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKeyOrNil:kTimePosted] integerValue] / 1000.0f];
            }
            
        }
    }
    return self;
}

@end
