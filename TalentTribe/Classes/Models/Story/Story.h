//
//  Story.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Author;

typedef enum {
    StoryTypeStory,
    StoryTypeLink,
    StoryTypeQuestion,
    StoryTypeMultimedia,
    StoryTypeHardFacts,
    StoryTypeOfficePhotos,
    StoryTypeVibeSnip,
    StoryTypePrivacySnip,
    StoryTypeJoinCompanySnip
} StoryType;

#define kFullscreenImage @"fullscreen"
#define kRegularImage @"regular"

#define kStoryId @"storyId"
#define kTitle @"title"
#define kStoryType @"storyType"
#define kContent @"content"
#define kCategories @"categories"
#define kImages @"images"
#define kFullImages @"fullScreenImages"
#define kVideoLink @"videoLink"
#define kCompany @"company"
#define kCompanyId @"companyId"
#define kCompanyName @"companyName"
#define kCompanyLogo @"companyLogo"
#define kAuthor @"author"
#define kLikesNum @"likesNum"
#define kCommentsNum @"commentsNum"
#define kLastUpdateTime @"lastUpdateTime"
#define kUserLike @"userLike"
#define kUserInterested @"userInterested"
#define kAppStory @"appStory"
#define kVideoThumbnail @"videoThumbnail"
#define kHLSVideoLink @"hlsMasterLink"

@protocol StoryDelegate <NSObject>

//-(void)

@end

@interface Story : NSObject

@property (nonatomic, strong) NSString *storyId;
@property (nonatomic, strong) NSString *storyTitle;
@property (nonatomic, strong) NSString *storyContent;
@property (nonatomic, strong) NSMutableArray *storyImages;
@property (nonatomic, strong) NSString *videoLink;
@property (nonatomic, strong) NSDate *storyUpdateTime;
@property (nonatomic, strong) NSString *companyId;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *companyLogo;
@property (nonatomic, strong) NSString *storyCommentsNum;
@property (nonatomic, strong) UIImage *storyScreenshotImage;
@property (nonatomic, strong) UIImage *currentThumbnail;
@property (nonatomic, strong) NSString *videoThumbnailLink;
@property (nonatomic, strong) Author *author;

@property StoryType storyType;

@property NSInteger likesNum;
@property NSInteger commentsNum;
@property BOOL userLike;

@property (nonatomic, strong) NSArray *categories;

- (id)initWithDictionary:(NSDictionary *)dict;
+(void)publishStoryFromDict:(NSDictionary *)dict newStory:(BOOL)isNewStory completionHandler:(SimpleCompletionBlock)completion;
+ (NSDictionary *)companyDictFromStoryDict:(NSDictionary *)dict;

+ (StoryType)storyTypeForString:(NSString *)string;
+ (NSString *)stringForStoryType:(StoryType)type;
+ (BOOL)isStoryTypeSnip:(Story *)story;
+ (BOOL)isStoryTypeYSnip:(Story *)story;

@end
