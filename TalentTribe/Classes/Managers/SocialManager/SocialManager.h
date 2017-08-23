//
//  SocialManager.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Story.h"
#import "LinkedInToken.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import <AVFoundation/AVFoundation.h>

@interface SocialManager : NSObject

/*@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *pictureURLString;

@property (nonatomic, strong) NSString *accessToken;
*/

+ (instancetype)sharedManager;

- (void)shareStory:(Story *)story controller:(UIViewController *)controller completionHandler:(SimpleCompletionBlock)completion;

//LinkedIn
- (LIALinkedInHttpClient *)linkedInClient;

- (void)requestLinkedInTokenWithAuthorizationHandler:(SimpleResultBlock)authorizationHandler completionHandler:(void (^)(LinkedInToken *token, NSError *error))completion;
- (void)linkedInProfileWithToken:(LinkedInToken *)token completion:(SimpleResultBlock)completion;

- (void)cancelAllRequests;

@end
