//
//  SocialManager.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "SocialManager.h"
#import "Story.h"
#import "LinkedInToken.h"

#import <SDWebImage/SDWebImageManager.h>

#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

#import "GeneralMethods.h"
#import "AsyncVideoDisplay.h"
#import "StoryItemProvider.h"

@interface SocialManager () <FBSDKSharingDelegate /*,UIActivityItemSource*/> {
    LIALinkedInHttpClient *_linkedInClient;
}
@property (nonatomic, copy) SimpleCompletionBlock shareCompletion;
@property (nonatomic, strong) Story *currentStory;
@property (nonatomic, strong) UIImage *currentImage;
@end

static NSInteger const StorySnippetCharCount = 120;
static NSString *const StoryFeedId = @"story";

@implementation SocialManager

#pragma mark Initialization

+ (instancetype)sharedManager {
    static SocialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SocialManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        NSString *imageLink = self.currentStory.storyImages.firstObject[@"regular"];
        if (self.currentStory.videoLink) {
            // generate video 'play' image
            imageLink = @"https://storage.googleapis.com/tt-images/category/culture_vibe.jpg";
            if (self.currentStory.videoThumbnailLink) {
                imageLink = self.currentStory.videoThumbnailLink;
            }
        }
        return [[DataManager sharedManager] shareHtmlWithImageUrl:imageLink storyUrl:[self storyUrlWithStory:self.currentStory] titleText:self.currentStory.storyTitle bodyString:self.currentStory.storyContent];
        
    } else if ([activityType isEqualToString:UIActivityTypeMessage]) {
        return self.currentImage;
    } 
    return self;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return [NSString stringWithFormat:@"TalentTribe: %@", self.currentStory.storyTitle];
}

#pragma mark Sharing

- (void)shareStory:(Story *)story controller:(UIViewController *)controller completionHandler:(SimpleCompletionBlock)completion {
    void (^publishStory)(Story *story, UIImage *image) = ^(Story *story, UIImage *image){
        StoryItemProvider *storyShare = [[StoryItemProvider alloc] initWithPlaceholderItem:nil shareStory:story image:image];
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[storyShare] applicationActivities:nil];
        [activity setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            if (completion) {
                completion(completed, completed ? nil : [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
            }
        }];
        [controller presentViewController:activity animated:YES completion:nil];
    };
    
    if (story.storyImages.firstObject || story.storyScreenshotImage || story.videoLink) {
        if (story.storyScreenshotImage) {
            publishStory(story, story.storyScreenshotImage);
            return;
        }
        
        NSURL *imageURL = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
        if (story.videoThumbnailLink) {
            imageURL = [NSURL URLWithString:story.videoThumbnailLink];
        }
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:imageURL]) {
            publishStory(story, [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:[imageURL absoluteString]]);
        } else {
            [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                publishStory(story, image);
            }];
        }
    } else {
        publishStory(story, nil);
    }
}

#pragma mark - Story Redirect Url

- (NSString *)storyUrlWithStory:(Story *)story {
    return [NSString stringWithFormat:@"%@/redirect.html?pageId=%@&objectId=%@", SERVER_URL, StoryFeedId, story.storyId];
}

#pragma mark LinkedIn methods

- (void)requestLinkedInTokenWithAuthorizationHandler:(SimpleResultBlock)authorizationHandler completionHandler:(void (^)(LinkedInToken *token, NSError *error))completion {
    [self.linkedInClient getAuthorizationCode:^(NSString *code) {
        if (authorizationHandler) {
            authorizationHandler(code, nil);
        }
        [self.linkedInClient getAccessToken:code success:^(NSDictionary *accessTokenData) {
            LinkedInToken *token = [[LinkedInToken alloc] initWithDictionary:accessTokenData];
            completion(token, nil);
        } failure:^(NSError *error) {
            completion(nil, error);
        }];
    } cancel:^{
        completion(nil, nil);
    } failure:^(NSError *error) {
        completion(nil, error);
    }];
}

- (void)linkedInProfileWithToken:(LinkedInToken *)token completion:(SimpleResultBlock)completion {
    void (^failureWithError)(NSError *error) = ^(NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    };
    void (^loadLinkedInProfile)(NSString *accessToken) = ^(NSString *accessToken) {
        if (accessToken) {
            [self.linkedInClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,positions,summary)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
                DLog(@"Current Profile %@", result);
                if (completion) {
                    completion(result, nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DLog(@"failed to fetch current user %@", error);
                failureWithError(error);
            }];
        } else {
            failureWithError([NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    };
    
    if (token && token.isValid) {
        loadLinkedInProfile(token.accessToken);
    } else {
        [self requestLinkedInTokenWithAuthorizationHandler:nil completionHandler:^(LinkedInToken *token, NSError *error) {
            if (token && !error) {
                loadLinkedInProfile(token.accessToken);
            } else {
                failureWithError(error);
            }
        }];
    }
}

- (LIALinkedInHttpClient *)linkedInClient {
    if(!_linkedInClient) {
        NSArray *access = @[@"r_basicprofile",@"r_emailaddress"];
        LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://onoapps.com" clientId:@"77c55780hod3ys" clientSecret:@"kWCV0xxTQTpCx17A" state:@"DCEEFWF45453sdffef424"
                                                                                   grantedAccess:access];
        _linkedInClient = [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
    }
    return _linkedInClient;
}

- (void)cancelAllRequests {
    [[self.linkedInClient operationQueue] cancelAllOperations];
}

#pragma mark FBSDKSharing delegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if (self.shareCompletion) {
        self.shareCompletion(YES, nil);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    if (self.shareCompletion) {
        self.shareCompletion(NO, error);
    }
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    if (self.shareCompletion) {
        self.shareCompletion(NO, nil);
    }
}

@end
