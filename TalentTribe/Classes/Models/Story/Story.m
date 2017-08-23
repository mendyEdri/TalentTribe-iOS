//
//  Story.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Story.h"
#import "StoryCategory.h"
#import "Author.h"
#import "Company.h"
#import "GeneralMethods.h"

#define kAppStory @"appStory"

@implementation Story

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.storyId = [dict objectForKeyOrNil:kStoryId] ?: [[NSProcessInfo processInfo] globallyUniqueString];
            if (self.storyId) {
                NSDictionary *tempDict = [dict objectForKeyOrNil:kAppStory];
                if (tempDict) {
                    dict = tempDict;
                }
                self.storyTitle = [dict objectForKeyOrNil:kTitle];

                self.videoThumbnailLink = [dict objectForKeyOrNil:kVideoThumbnail];
                self.storyType = [Story storyTypeForString:[dict objectForKeyOrNil:kStoryType]];
                self.storyContent = [dict objectForKeyOrNil:kContent];
                self.storyCommentsNum = [dict objectForKeyOrNil:kCommentsNum];
                NSArray *categoriesDict = [dict objectForKeyOrNil:kCategories];
                NSMutableArray *categoriesContainer = [NSMutableArray new];
                
                if (categoriesDict) {
                    for (id object in categoriesDict) {
                        if ([object isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *categoryDict = (NSDictionary *)object;
                            [categoriesContainer addObject:[[StoryCategory alloc] initWithDictionary:categoryDict]];
                        }
                    }
                }
                
                self.categories = categoriesContainer.count ? categoriesContainer : nil;
                
                NSMutableArray *imagesContainer = [NSMutableArray new];
                
                NSArray *imagesArray = [dict objectForKeyOrNil:kImages];
                NSArray *fullImagesArray = [dict objectForKeyOrNil:kFullImages];
                
                if (imagesArray || fullImagesArray) {
//                    if (imagesArray.count == fullImagesArray.count) {
                        for (NSInteger i = 0; i < imagesArray.count; i++) {
                            id imageObject = [imagesArray objectAtIndex:i];
                            
                            id fullImageObject;
                            if (fullImagesArray && fullImagesArray.count <= i && fullImagesArray.count > 0) {
                                fullImageObject = [fullImagesArray objectAtIndex:i];
                            }
                            if ([imageObject isKindOfClass:[NSString class]] || [fullImageObject isKindOfClass:[NSString class]]) {
                                NSString *imageString = (NSString *)imageObject;
                                NSString *fullImageString = (NSString *)fullImageObject;
                                NSURL *imageUrl = [NSURL URLWithString:imageString];
                                NSURL *fullImageUrl = [NSURL URLWithString:fullImageString];
                                if ((imageUrl && imageUrl.scheme && imageUrl.host) || (fullImageUrl && fullImageUrl.scheme && fullImageUrl.host)) {
                                    if (fullImageString && imageString) {
                                        [imagesContainer addObject:@{kRegularImage : imageString, kFullscreenImage: fullImageString}];
                                    } else if (imageString) {
                                        [imagesContainer addObject:@{kRegularImage : imageString}];
                                    }
                                }
                            }
                  //      }
                    }
                }
                
                self.storyImages = imagesContainer.count ? imagesContainer : nil;
                
                /*NSArray *imagesDict = [dict objectForKeyOrNil:kImages];
                NSMutableArray *imagesContainer = [NSMutableArray new];
                
                if (imagesDict) {\
                    for (id object in imagesDict) {
                        if ([object isKindOfClass:[NSString class]]) {
                            NSString *imageString = (NSString *)object;
                            NSURL *url = [NSURL URLWithString:imageString];
                            if (url && url.scheme && url.host) {
                                [imagesContainer addObject:@{kRegularImage : imageString}];
                            }
                        } else if ([object isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *imagesDict = (NSDictionary *)object;
                            if ([imagesDict objectForKeyOrNil:kRegularImage] && [imagesDict objectForKeyOrNil:kFullscreenImage]) {
                                [imagesContainer addObject:imagesDict];
                            }
                        }
                    }
                }*/
                
                if ([dict objectForKeyOrNil:kAuthor]) {
                    self.author = [[Author alloc] initWithDictionary:[dict objectForKeyOrNil:kAuthor]];
                }
                
                if ([dict objectForKeyOrNil:kLastUpdateTime]) {
                    self.storyUpdateTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKeyOrNil:kLastUpdateTime] integerValue] / 1000.0f];
                }
                
                self.videoLink = [dict objectForKeyOrNil:kHLSVideoLink] ? [dict objectForKeyOrNil:kHLSVideoLink] : [dict objectForKeyOrNil:kVideoLink];
                self.likesNum = [[dict objectForKeyOrNil:kLikesNum] integerValue];
                self.commentsNum = [[dict objectForKeyOrNil:kCommentsNum] integerValue];
                self.userLike = [[dict objectForKeyOrNil:kUserLike] boolValue];
                
                if ([dict objectForKeyOrNil:kCompany]) {
                    NSDictionary *companyDict = [dict objectForKeyOrNil:kCompany];
                    self.companyId =  [companyDict objectForKeyOrNil:kCompanyId];
                    self.companyName =  [companyDict objectForKeyOrNil:kCompanyName];
                    self.companyLogo =  [companyDict objectForKeyOrNil:kCompanyLogo];
                }
            } else {
                return nil;
            }
        }
    }
    return self;
}

+(void)publishStoryFromDict:(NSDictionary *)dict newStory:(BOOL)isNewStory completionHandler:(SimpleCompletionBlock)completion
{
    if (!dict)
    {
        return;
    }
    
    Story *storyToPublish = [[Story alloc]init];
    storyToPublish.storyId = [[NSProcessInfo processInfo] globallyUniqueString];
    
    if ([dict objectForKeyOrNil:kTitle])
    {
        storyToPublish.storyTitle = [dict objectForKeyOrNil:kTitle];
    }
    if ([dict objectForKeyOrNil:kContent])
    {
        storyToPublish.storyContent = [dict objectForKeyOrNil:kContent];
    }
    if ([dict objectForKeyOrNil:kCategories])
    {
        storyToPublish.categories = [dict objectForKeyOrNil:kCategories];
    }
    if ([dict objectForKeyOrNil:kStoryType])
    {
        storyToPublish.storyType = [[dict objectForKeyOrNil:kStoryType] intValue];
    }
    if ([dict objectForKeyOrNil:kImages])
    {
        if (isNewStory)
        {
            storyToPublish.storyImages = [dict objectForKeyOrNil:kImages];
        }
        else
        {
            NSArray *arr = [[NSArray alloc]initWithArray:[dict objectForKeyOrNil:kImages]];
            storyToPublish.storyImages = [NSMutableArray new];
            
            for (id obj in arr)
            {
                if ([obj isMemberOfClass:[UIImage class]])
                {
                    [storyToPublish.storyImages addObject:[GeneralMethods converImageToBase64String:obj]];
                }
                else if ([obj isMemberOfClass:[NSURL class]])
                {
                    [storyToPublish.storyImages addObject:[obj absoluteString]];
                }
            }
        }
    }
    if ([dict objectForKey:kVideoLink])
    {
        storyToPublish.videoLink = [dict objectForKey:kVideoLink];
    }
    
    if ([dict objectForKey:kVideoThumbnail]) {
        storyToPublish.videoThumbnailLink = [dict objectForKey:kVideoThumbnail];
    }
    
    // Handle company
    if ([dict objectForKeyOrNil:kCompany])
    {
        Company *company = [dict objectForKeyOrNil:kCompany];
        if (company.companyId.length > 0)
        {
            storyToPublish.companyId = company.companyId;
        }
        
        if (company.companyLogo.length > 0)
        {
           storyToPublish.companyLogo = company.companyLogo;
        }
        
        if (company.companyName.length > 0)
        {
            storyToPublish.companyName = company.companyName;
        }
    }
    
    if (isNewStory)
    {
        [[DataManager sharedManager] addStory:storyToPublish anonymously:NO completionHandler:^(BOOL success, NSError *error)
         {
             if (!completion)
             {
                 [TTActivityIndicator dismiss];
                 return;
             }
             completion(success,error);
         }];
    }
    else
    {
        [[DataManager sharedManager] updateStory:storyToPublish completionHandler:^(BOOL success, NSError *error) {
            if (!error && success) {
                
            } else {
                if (!completion) {
                    [TTActivityIndicator dismiss];
                }
                
                completion(success, error);
            }
        }];
    }
}


+ (StoryType)storyTypeForString:(NSString *)string {
    if ([string isEqualToString:[Story stringForStoryType:StoryTypeStory]]) {
        return StoryTypeStory;
    } else if ([string isEqualToString:[Story stringForStoryType:StoryTypeLink]]) {
        return StoryTypeLink;
    } else if ([string isEqualToString:[Story stringForStoryType:StoryTypeQuestion]]) {
        return StoryTypeQuestion;
    } else if ([string isEqualToString:[Story stringForStoryType:StoryTypeMultimedia]]) {
        return StoryTypeMultimedia;
    } else if ([string isEqualToString:[Story stringForStoryType:StoryTypeHardFacts]]) {
        return StoryTypeHardFacts;
    } else if ([string isEqualToString:[Story stringForStoryType:StoryTypeOfficePhotos]]) {
        return StoryTypeOfficePhotos;
    }
    return StoryTypeStory;
}

+ (NSString *)stringForStoryType:(StoryType)type {
    switch (type) {
        case StoryTypeStory: {
          return @"STORY";
        } break;
        case StoryTypeLink: {
            return @"LINK";
        } break;
        case StoryTypeQuestion: {
            return @"QUESTION";
        } break;
        case StoryTypeMultimedia: {
            return @"MULTIMEDIA";
        } break;
        case StoryTypeHardFacts: {
            return @"HARD_FACTS";
        } break;
        case StoryTypeOfficePhotos: {
            return @"OFFICE_PHOTOS";
        } break;
        default: {
            return nil;
        } break;
    }
}

+ (NSDictionary *)companyDictFromStoryDict:(NSDictionary *)dict {
    return [dict objectForKeyOrNil:kCompany];
}

+ (BOOL)isStoryTypeSnip:(Story *)story {
    switch (story.storyType) {
        case StoryTypeVibeSnip:
            return YES;
        break;
        case StoryTypePrivacySnip:
            return YES;
        break;
        case StoryTypeJoinCompanySnip:
            return YES;
        break;
        case StoryTypeHardFacts:
            return YES;
            break;
        default:
            return NO;
        break;
    }
    return NO;
}

+ (BOOL)isStoryTypeYSnip:(Story *)story {
    switch (story.storyType) {
        case StoryTypeVibeSnip:
            return YES;
            break;
        case StoryTypePrivacySnip:
            return YES;
            break;
        case StoryTypeJoinCompanySnip:
            return YES;
            break;
        default:
            return NO;
            break;
    }
    return NO;
}

@end
