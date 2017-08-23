//
//  DataManager.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "DataManager.h"
#import "CommManager.h"
#import "User.h"
#import "Story.h"
#import "Comment.h"
#import "Company.h"
#import "CompanyInfo.h"
#import "Position.h"
#import "StoryCategory.h"
#import "NSData+HexString.h"
#import "QuickSearch.h"
#import "SocialManager.h"
#import "FDKeychain.h"
#import "NSData+MD5Digest.h"
#import "GTLRStorage.h"
#import "GTMOAuth2SignIn.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "TalentTribe-Bridging-Header.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "UIImage+sizedImageNamed.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import "AsyncVideoDisplay.h"
#import "GeneralMethods.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "TopMessageView.h"
#import "UIView+Additions.h"

#define kAnonymousUser @"anonymousUser"
#define kStoryWrapper @"storyListWrapper"
#define kStory @"appStory"
#define kCompany @"company"
#define kCompanyId @"companyId"
#define kStoryId @"storyId"

@interface DataManager () <UIAlertViewDelegate>
{
    NSString *accessToken;
}

@property (nonatomic, strong) NSMutableDictionary *requestsContainer;
@property (nonatomic, strong) NSMutableArray *storyIdsArrayStruct;
@property (nonatomic, strong) TopMessageView *topMessageView;
@end

@implementation DataManager

@synthesize companySelectedArray;
@synthesize isAnonymous = _isAnonymous;
@synthesize currentUser = _currentUser;

static GTLRStorageService *storageService = nil;
static GTMOAuth2Authentication *_auth;

#pragma mark Initialization

+ (instancetype)sharedManager {
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestsContainer = [NSMutableDictionary new];
        self.companySelectedArray = [NSMutableArray new];
        self.silentLogin = NO;
        [self setMuted:YES];
        [self checkReachability];
    }
    return self;
}

#pragma mark Checking reachability

- (void)checkReachability {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    void (^reachabilityCheck)(Reachability *) = ^(Reachability *reachability){
        self.reachabilityStatus = reachability.currentReachabilityStatus;
        [self handleReachabilityAlertStatus];
    };
    
    reach.reachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            reachabilityCheck(reachability);
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            reachabilityCheck(reachability);
        });
    };
    reachabilityCheck(reach);
    [reach startNotifier];
}

- (void)handleReachabilityAlertStatus {
    static UIAlertView *reachabilityAlert;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reachabilityAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Internet connection appears to be offline" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    });
    
    if (self.reachabilityStatus == NotReachable) {
        [reachabilityAlert show];
    } else {
        if (reachabilityAlert.isVisible) {
            [reachabilityAlert dismissWithClickedButtonIndex:reachabilityAlert.cancelButtonIndex animated:YES];
        }
    }
}

- (BOOL)isReachable {
    return self.reachabilityStatus != NotReachable;
}

#pragma mark Error handling

- (NSError *)handleError:(NSError *)error {
    
    static UIAlertView *alertView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:nil delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    });

    void (^showAlertWithMessage)(NSString *message) = ^(NSString *message) {
        if (alertView.isVisible) {
            [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
        }
        [alertView setMessage:message ?: @"We encounter a problem, please try again later."];
        [alertView show];
    };
    
    void (^showUpdateWithMessage)(NSString *message) = ^(NSString *message) {
        if (message) {
            static UIAlertView *updateAlertView;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                updateAlertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"UPDATE", nil];
            });
            [updateAlertView setMessage:message];
            [updateAlertView show];
        }
    };

    switch (error.code) {
        case 400: {
            DLog(@"Error code 400 with custom message");
            NSDictionary *userInfo = error.userInfo;
            if ([[userInfo  objectForKeyOrNil:@"error"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *errorDict = [userInfo objectForKeyOrNil:@"error"];
                NSInteger errorCode = [[errorDict objectForKeyOrNil:@"code"] integerValue];
                NSString *errorReason = [errorDict objectForKeyOrNil:@"reason"];
                if (errorReason) {
                    if (errorCode == 5000) {
                        showUpdateWithMessage(errorReason);
                    } else {
                        showAlertWithMessage(errorReason);
                    }
                    return nil;
                }
            }
            showAlertWithMessage(nil);
            return nil;
        } break;
        /*case 403: {
            [self clearCredentials];
            [self clearCookies];
            DLog(@"Token expored, moving to login screen");
            [self showLoginScreenModal:NO];
        } break;*/
        case 500: {
            DLog(@"Error code 500 with default message");
            showAlertWithMessage(nil);
            return nil;
        } break;
        default: {
            [self handleReachabilityAlertStatus];
        } break;
    }
    return error;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        //open AppStore link
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"google.com"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"google.com"]];
        }
    }
}

#pragma mark Login handling

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(SimpleResultBlock)completion {
    [self loginWithUsername:username password:password loadProfile:YES completionHandler:completion];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password loadProfile:(BOOL)loadProfile completionHandler:(SimpleResultBlock)completion {
    if (username && password) {
        NSDictionary *loginDict = @{@"j_password" : password, @"j_username" : username};
        [[CommManager sharedManager] loginWithDictionary:loginDict completionHandler:^(id result, NSError *error) {
            void (^innerFailure)(NSError *error) = ^(NSError *error){
                if (completion) {
                    completion(nil, error);
                }
            };
            
            if (result && !error) {
                
                if (!self.currentUser) {
                    self.currentUser = [User new];
                }
                
                self.currentUser.userEmail = username;
                self.currentUser.remainVibeCount = 5;
                
                void (^innerCompletion)(void) = ^{
                    [self setEmail:username];
                    [self setPassword:password];
                    
                    [self registerToPushWithCompletionHandler:^(BOOL success, NSError *error) {
                        if (completion) {
                            completion(self.currentUser, nil);
                        }
                    }];
                };
                
                if (loadProfile) {
                    [[CommManager sharedManager] getUserIdWithCompletionHandler:^(NSDictionary *resultDict, NSError *error) {
                        if (resultDict && !error) {
                            if (!self.currentUser) {
                                self.currentUser = [[User alloc] initWithDictionary:resultDict];
                            } else {
                                [self.currentUser populateFromDict:resultDict];
                            }
                            innerCompletion();
                            /*[[CommManager sharedManager] userProfileWithUserId:self.currentUser.userID completionHandler:^(NSDictionary *userDict, NSError *error) {
                                if (userDict && !error) {
                                    [self.currentUser populateFromDict:userDict];
                                    innerCompletion();
                                } else {
                                    innerFailure(error);
                                }
                            }];*/
                        } else {
                            innerFailure(error);
                        }
                    }];
                } else {
                    [[CommManager sharedManager] getUserIdWithCompletionHandler:^(NSDictionary *resultDict, NSError *error) {
                        if (resultDict && !error) {
                            if (!self.currentUser) {
                                self.currentUser = [[User alloc] initWithDictionary:resultDict];
                            } else {
                                [self.currentUser populateFromDict:resultDict];
                            }
                            innerCompletion();
                        } else {
                            innerFailure(error);
                        }
                    }];
                }
            } else {
                innerFailure([self handleError:error]);
            }
        }];
    } else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)silentLoginWithCompletion:(SimpleResultBlock)completion {
    [self loginWithUsername:[self email] password:[self password] completionHandler:^(id result, NSError *error) {
        if (result && !error) {
            self.silentLogin = YES;
        }
        if (completion) {
            completion(result, error);
        }
    }];
}

- (void)logoutWithCompletionHandler:(SimpleCompletionBlock)completion {
    if (self.isCredentialsSavedInKeychain) {
        [self unregisterFromPushWithCompletionHandler:^(BOOL success, NSError *error) {
            if (completion) {
                completion(success, error);
            }
        }];
        [[CommManager sharedManager] logoutWithDictionary:nil completionHandler:^(BOOL success, NSError *error) {
            if (error) {
                [self clearCurrentUser];                
            }
            if (success && !error) {
                [self clearCurrentUser];
            }
        }];
    } else {
        if (completion) {
            completion(YES, nil);
        }
    }
}

- (void)registerWithEmail:(NSString *)email password:(NSString *)password completion:(SimpleResultBlock)completion {
    NSString *passwordMD5;
    if(email.length) {
        //if not register with linked in token, then it's regular register so PWD is MD5
        passwordMD5 = [NSData MD5HexDigest:[password dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSDictionary *params = @{@"email" : email, @"password" : passwordMD5};
    [[CommManager sharedManager] registerWithDictionary: params completionHandler:^(NSDictionary *result, NSError *error) {
        
        void (^innerFailure)(NSError *error) = ^(NSError *error){
            if (completion) {
                completion(nil, error);
            }
        };
        
        if (result && !error) {
            if (!self.currentUser) {
                self.currentUser = [User new];
            }
            self.currentUser.userID = [result objectForKeyOrNil:@"id"];
            
            [self loginWithUsername:email password:password loadProfile:NO completionHandler:^(id result, NSError *error) {
                if (result && !error) {
                    
                    void(^innerCompletion)(void) = ^{
                        if (completion) {
                            completion(self.currentUser, nil);
                        }
                    };
                    
                    if (self.currentUser.linkedInToken) {
                        [self updateUser:self.currentUser completionHandler:^(BOOL success, NSError *error) {
                            if (success && !error) {
                                innerCompletion();
                            } else {
                                innerFailure(error);
                            }
                        }];
                    } else {
                        innerCompletion();
                    }
                } else {
                    innerFailure(error);
                }
            }];
        } else {
            innerFailure([self handleError:error]);
        }
    }];
}

- (void)updateUser:(User *)user completionHandler:(SimpleCompletionBlock)completion {
    NSDictionary *userDict = [user dictionary];
    [[CommManager sharedManager] updateCurrentUserWithDictionary:userDict completionHandler:^(id result, NSError *error) {
        if (result && !error) {
            self.currentUser = [[User alloc] initWithDictionary:result];
//            [self setCurrentUser:user];
            if (completion) {
                completion(result, error);
            }
        } else {
            if (completion) {
                completion(NO, [self handleError:error]);
            }
        }
    }];
}

- (void)updatePassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completionHandler:(SimpleCompletionBlock)completion {
    NSMutableDictionary *passDict = [NSMutableDictionary new];
    if (currentPassword.length) {
        [passDict setObject:currentPassword forKey:@"oldPassword"];
    }
    if (newPassword.length) {
        [passDict setObject:newPassword forKey:@"newPassword"];
    }
    [[CommManager sharedManager] updatePasswordWithDictionary:passDict completionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(success, error);
        }
    }];
}

- (void)associatedCompaniesWithCompletionHandler:(SimpleResultBlock)completion {
    if (completion) {
        completion(self.currentUser.validatedCompanies, nil);
    }
}

- (void)unregisterUserCompany:(Company *)company completionHandler:(SimpleCompletionBlock)completion {
    if ([self.currentUser.validatedCompanies containsObject:company]) {
        [self.currentUser.validatedCompanies removeObject:company];
        if (completion) {
            completion(YES, nil);
        }
        return;
    }
    if (completion) {
        completion(NO, [NSError errorWithDomain:@"talenttribe.me" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Company not found"}]);
    }
}

#pragma mark Push handling

- (void)registerToPushWithCompletionHandler:(SimpleCompletionBlock)completion {
    NSData *deviceTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    if (deviceTokenData) {
        NSDictionary *pushDict = @{@"accessToken" : [deviceTokenData hexString]};
        [[CommManager sharedManager] registerToPushWithDictionary:pushDict completionHandler:^(BOOL success, NSError *error) {
            if (completion) {
                completion(success, error);
            }
        }];
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)unregisterFromPushWithCompletionHandler:(SimpleCompletionBlock)completion {
    NSData *deviceTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    if (deviceTokenData) {
        [[CommManager sharedManager] unregisterFromPushWithDictionary:nil completionHandler:^(BOOL success, NSError *error) {
            if (completion) {
                completion(success, error);
            }
        }];
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

#pragma mark - Notifications

- (void)userNotificationsWithParams:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion {
    [[CommManager sharedManager] userNotification:params completionHandler:^(id result, NSError *error) {
        completion(result, error);
    }];
}

#pragma mark LinkedIn handling

- (void)requestLinkedInTokenWithAuthorizationHandler:(SimpleResultBlock)authorizationHandler completionHandler:(SimpleResultBlock)completion {
    [[SocialManager sharedManager] requestLinkedInTokenWithAuthorizationHandler:authorizationHandler completionHandler:^(LinkedInToken *token, NSError *error) {
        if (token && !error) {
            if (!self.currentUser) {
                self.currentUser = [User new];
            }
            self.currentUser.linkedInToken = token;
            if (completion) {
                completion(token, nil);
            }
        } else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)linkedInProfileWithCompletion:(SimpleResultBlock)completion {
    void(^loadLinkedInProfile)(LinkedInToken *token) = ^(LinkedInToken *token) {
        [[SocialManager sharedManager] linkedInProfileWithToken:token completion:^(NSDictionary *result, NSError *error) {
            if (result && !error) {
                self.currentUser.userEmail = [result objectForKeyOrNil:@"emailAddress"];
                self.currentUser.userFirstName = [result objectForKeyOrNil:@"firstName"];
                self.currentUser.userLastName = [result objectForKeyOrNil:@"lastName"];
                self.currentUser.userProfileImageURL = [result objectForKeyOrNil:@"pictureUrl"];
                self.currentUser.userProfileSummary = [result objectForKeyOrNil:@"summary"];
                [self.currentUser setPositionsFromDict:[result objectForKeyOrNil:@"positions"]];
            
                if (completion) {
                    completion(self.currentUser, nil);
                }
            } else {
                if (completion) {
                    completion(nil, error);
                }
            }
        }];
    };
    if (self.currentUser.linkedInToken.isValid) {
        loadLinkedInProfile(self.currentUser.linkedInToken);
    } else {
        [[SocialManager sharedManager] requestLinkedInTokenWithAuthorizationHandler:nil completionHandler:^(LinkedInToken *token, NSError *error) {
            if (token && !error) {
                if (!self.currentUser) {
                    self.currentUser = [User new];
                }
                self.currentUser.linkedInToken = token;
                loadLinkedInProfile(token);
            } else {
                if (completion) {
                    completion(nil, error);
                }
            }
        }];
    }
}

#pragma mark Story handling
#pragma mark - Feed Implementation

- (void)storyFeedWithCompletionHandler:(SimpleResultBlock)completion {
    [self storyFeedForCategory:nil companyId:nil completionHandler:completion];
}

- (void)storyFeedForCategory:(StoryCategory *)category companyId:(NSString *)companyId completionHandler:(SimpleResultBlock)completion {
    if (category) {
        [self storyFeedForCategory:category withCompletion:^(id result, NSError *error) {
            if (result && !error) {
                NSArray *resultArray = result;
                NSMutableArray *stories = [NSMutableArray new];
                NSMutableArray *companies = [NSMutableArray new];
                for (NSDictionary *storyDictionary in resultArray) {
                    Story *story = [[Story alloc] initWithDictionary:storyDictionary];
                    Company *company = [[Company alloc] initWithDictionary:[Story companyDictFromStoryDict:storyDictionary]];
                    [companies addObject:company];
                    [stories addObject:story];
                }
                completion(@{@"Stories" : stories, @"Companies" : companies}, nil);
                return ;
            }
            completion(result, error);
        }];
        return;
    }
    [self storyFeedForCategory:category companyId:companyId page:0 count:STORYFEED_DEFAULT_PAGE_SIZE completionHandler:completion];
}

-(void)getStoryWithParams:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion
{
    [[CommManager sharedManager] getStoryWithParams:params completionHandler:^(id result, NSError *error)
    {
        if (result && !error)
        {
            if (completion)
            {
                completion(result, error);
            }
        }
        else
        {
            if (completion)
            {
                completion(nil, [self handleError:error]);
            }
        }

    }];
}

- (void)storyFeedForCategory:(StoryCategory *)category companyId:(NSString *)companyId page:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    NSMutableDictionary *storyFeedDict = [NSMutableDictionary new];
    __block NSMutableArray *rows = [NSMutableArray new];
    
    if (category) {
        [storyFeedDict setObject:category.categoryName forKey:@"categoryId"];
    }
    
    if (companyId) {
        [storyFeedDict setObject:companyId forKey:kCompanyId];
    }
    
    [storyFeedDict setObject:[self screenSizeDict] forKey:@"size"];
    
    [storyFeedDict setObject:@(page) forKey:@"page"];
    [storyFeedDict setObject:@(count) forKey:@"pageSize"];
    
    [[CommManager sharedManager] storyFeedWithDictionary:storyFeedDict completionHandler:^(NSArray *result, NSError *error) {
        if (result && !error) {
            NSDictionary *resultDict = (NSDictionary *)result;

            // save the ids in order
            NSMutableArray *indexes = [NSMutableArray new];
            for (NSDictionary *idsDictionary in resultDict[@"indexes"]) {
                DLog(@"idsDictionary %@", idsDictionary[@"row"]);
                [indexes addObject:[idsDictionary valueForKeyOrNil:@"row"]];
            }
            
            // save companies list
            NSArray *companiesObjects = [self companiesObjectsArrayFromJson:[[resultDict valueForKeyOrNil:@"entityWrapper"] valueForKeyOrNil:@"companyList"]];
            
            // save stories
            NSArray *storiesObjects = [self storiesObjectsArrayFromJson:[[resultDict valueForKeyOrNil:@"entityWrapper"] valueForKeyOrNil:@"storyList"] orderByIndexes:indexes];
            
            // fill story objects in companiesObjects with stories in order
            rows = [[NSMutableArray alloc] initWithArray:[self insertStoriesObjects:storiesObjects intoCompaniesObjects:companiesObjects]];
            
            if (page == 0) {
               // if (!self.isCredentialsSavedInKeychain || !self.currentUser.isProfileMinimumFilled) {
                    Company *createCompany = [Company new];
                    createCompany.companyName = @"TalentTribe";
                    createCompany.companyLogo = [[[NSBundle mainBundle] URLForResource:[UIImage scaledNameForName:@"story_logo"] withExtension:@"png"] absoluteString];
                    Story *createStory = [Story new];
                    createStory.storyType = StoryTypeVibeSnip; //StoryTypeCreateProfile;
                    createStory.storyTitle = @"";
                   // createStory.storyTitle = @"Welcome to the Tribe!\nCreate your profile now";
                    createStory.storyImages = [[NSMutableArray alloc] initWithArray:@[@{kRegularImage :[[[NSBundle mainBundle] URLForResource:[UIImage sizedNameForName:@"createProfileStory"] withExtension:@"png"] absoluteString]}]];
                    
                    createCompany.stories = @[createStory];
                    
                    if (rows.count > STORYFEED_VIBE_INDEX) {
                        [rows insertObject:createCompany atIndex:STORYFEED_VIBE_INDEX];
                    } else {
                        [rows addObject:createCompany];
                    }
                    
                    // Your-profile-saved-with-us snippet
                    createCompany = [Company new];
                    createCompany.companyName = @"TalentTribe";
                    createCompany.companyLogo = [[[NSBundle mainBundle] URLForResource:[UIImage scaledNameForName:@"story_logo"] withExtension:@"png"] absoluteString];
                    Story *privacySnip = [Story new];
                    privacySnip.storyType = StoryTypePrivacySnip;
                    privacySnip.storyTitle = @"";
                    privacySnip.storyImages = [[NSMutableArray alloc] initWithArray:@[@{kRegularImage :[[[NSBundle mainBundle] URLForResource:[UIImage sizedNameForName:@"createProfileStory"] withExtension:@"png"] absoluteString]}]];
                    createCompany.stories = @[privacySnip];
                    
                    if (rows.count > STORYFEED_PRIVACY_INDEX) {
                        [rows insertObject:createCompany atIndex:STORYFEED_PRIVACY_INDEX];
                    } else {
                        [rows addObject:createCompany];
                    }
           //     }
            }
            
            if (completion) {
                completion(rows, nil);
            }
            
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
        
    }];
}

- (void)storyFeedForCategory:(StoryCategory *)category withCompletion:(SimpleResultBlock)completion {
    [[CommManager sharedManager] storyFeedWithCategoryName:category.categoryName completionHandler:^(id result, NSError *error) {
        if (result && !error) {
            DLog(@"results %@", result);
        }
        completion(result, error);
    }];
}

- (void)storyFeedIndexesForXAxis:(NSInteger)xIndex inRow:(NSInteger)yIndex maxCount:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    NSMutableArray *idsArray = [NSMutableArray new];
    if (self.storyIdsArrayStruct.count <= yIndex) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:@{NSLocalizedDescriptionKey : @"array samller the requested index"}]);
        }
        return;
    }
    [self storyFeedIndexesWithParams:@{@"page" : @(0)} forceReload:NO completionHandler:^(id result, NSError *error) {
        NSInteger currentIndex = 0;
        for (NSString *storyId in self.storyIdsArrayStruct[yIndex]) {
            if (idsArray.count >= count) {
                break;
            }
            // skip to relvent index
            if (currentIndex < xIndex) {
                currentIndex++;
                continue;
            }
            [idsArray addObject:storyId];
            currentIndex++;
        }
        
        if (idsArray.count > 0) {
            if (completion) {
                completion(idsArray, nil);
            }
        } else {
            if (completion) {
                completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
            }
        }
    }];
}

- (void)storyFeedIndexesForYAxis:(NSInteger)yIndex maxCount:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    if (!self.storyIdsArrayStruct || self.storyIdsArrayStruct.count == 0) {
        completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:@{NSLocalizedDescriptionKey : @"Company indexes not fetched yet.."}]);
    }
    
    NSInteger counter = 0;
    NSMutableArray *ids = [NSMutableArray new];
    for (NSArray *row in self.storyIdsArrayStruct) {
        DLog(@"ids in dict %@", row);
        if (counter < yIndex) {
            counter++;
            continue;
        }
        
        if (ids.count == count) {
            break;
        }
        [ids addObject:row];
        counter++;
    }
    
    if (completion) {
        completion(ids, nil);
    }
}

- (NSArray *)parsedStoryIndexesArrayFromResult:(id)result {
    NSMutableArray *companyIndexesArray = [NSMutableArray new];
    for (NSDictionary *row in result) {
        [companyIndexesArray addObject:row[@"row"]];
    }
    return [companyIndexesArray copy];
}

- (NSArray *)storiesObjectsArrayFromJson:(id)obj orderByIndexes:(NSArray *)indexes {
    NSMutableArray *storyObjects = [NSMutableArray new];
    
    NSMutableDictionary *stories = [NSMutableDictionary new];
    for (NSDictionary *dictionary in obj) {
        [stories setValue:dictionary forKey:dictionary[kStoryId]];
    }
    
    for (NSArray *idsArray in indexes) {
        NSMutableArray *storyRow = [NSMutableArray new];
        for (NSString *idString in idsArray) {
            Story *story = [[Story alloc] initWithDictionary:stories[idString]];
            if (!story.storyId || [storyRow containsObject:story]) {
                continue;
            }
            [storyRow addObject:story];
        }
        if (storyRow.count == 0) {
            continue;
        }
        [storyObjects addObject:storyRow];
    }
    
    return [storyObjects copy];
}

- (NSArray *)companiesObjectsArrayFromJson:(id)obj {
    NSMutableArray *companyObjects = [NSMutableArray new];
    for (NSDictionary *companyDictionary in obj) {
        Company *company = [[Company alloc] initWithDictionary:companyDictionary];
        if (!company.companyId) {
            continue;
        }
        [companyObjects addObject:company];
    }
    return [companyObjects copy];
}

- (NSArray *)insertStoriesObjects:(NSArray *)stories intoCompaniesObjects:(NSArray *)companies {
    NSMutableArray *rows = [NSMutableArray new];
    // fill story objects in companiesObjects with stories in order
    for (NSArray *row in stories) {
        if (row.count == 0) {
            continue;
        }
        Company *company;
        NSMutableArray *storiesId = [NSMutableArray new];
        for (Story *story in row) {
            if (!story.storyId) {
                continue;
            }
            if (!company) {
                company = [self companyForId:story.companyId fromArray:companies];
            }
            [storiesId addObject:story];
        }
        company.stories = storiesId;
        [rows addObject:company];
    }
    
    return rows;
}

- (void)clearFeedIndexes {
    [self.storyIdsArrayStruct removeAllObjects];
    self.storyIdsArrayStruct = nil;
}

- (void)storyFeedIndexesWithParams:(NSDictionary *)params forceReload:(BOOL)reload completionHandler:(SimpleResultBlock)completion {
    if (!reload && self.storyIdsArrayStruct && self.storyIdsArrayStruct.count > 0) { // check what to do when the array exist but passed 30 minutes in background
        if (completion) {
            completion(self.storyIdsArrayStruct, nil);
            return;
        }
    }
    
    [[CommManager sharedManager] storyFeedIndexesWithDictionary:params completionHandler:^(id result, NSError *error) {
        self.storyIdsArrayStruct = [[NSMutableArray alloc] initWithArray:[self parsedStoryIndexesArrayFromResult:result]];
        if (completion) {
            completion(self.storyIdsArrayStruct, error);
        }
    }];
}

- (Company *)companyForId:(NSString *)companyId fromArray:(NSArray *)companies {
    for (Company *company in companies) {
        if (![company.companyId isEqualToString:companyId]) {
            continue;
        }
        return company;
    }
    return nil;
}

- (void)storiesByIds:(NSDictionary *)params orderByIndexes:(NSArray *)indexes completionHandler:(SimpleResultBlock)completion {
    [[CommManager sharedManager] storyFeedStoriesById:params completionHandler:^(id result, NSError *error) {
        NSLog(@"stories by id results %@", result);
        if (result && !error) {
            NSArray *companies = [self companiesObjectsArrayFromJson:result[@"companyList"]];
            NSArray *stories = [self storiesObjectsArrayFromJson:result[@"storyList"] orderByIndexes:indexes];
            NSArray *rows = [[NSMutableArray alloc] initWithArray:[self insertStoriesObjects:stories intoCompaniesObjects:companies]];
            if (completion) {
                completion(rows, nil);
            }
            
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}


- (void)uploadVideoWithParams :(NSMutableDictionary *)params completionHandler:(SimpleResultBlock)completion
{
    [[CommManager sharedManager] uploadVideoWithParams:params completionHandler:^(id result, NSError *error)
    {
        if (result && !error)
        {
            if (completion)
            {
                completion(result, nil);
            }
        }
        else
        {
            if (completion)
            {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}


- (void)refreshIdIndexesWithEncryptedString:(NSString *)sha1String completionHandler:(SimpleResultBlock)completion {
    [[CommManager sharedManager] refreshIndexesWithEncrypedIds:sha1String completionHandler:^(id result, NSError *error) {
        if (result && !error) {
            DLog(@"result refresh %@", result);
        }
        if (completion) {
            completion(result, error);
        }
    }];
}

- (void)sha1StringFromIdsArray:(NSArray *)idsArray completionHandler:(SimpleResultBlock)completion {
    NSMutableString *lastDigitsString = [NSMutableString new];
    for (NSString *idString in idsArray) {
        if (idString.length <= 7) {
            continue;
        }
        NSInteger lenght = idString.length-7;
        [lastDigitsString appendString:[idString substringFromIndex:lenght]];
    }
    
    if (completion) {
        completion([GeneralMethods sha1FromString:[lastDigitsString copy]], nil);
    }
}

- (void)userFeedForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    if (self.currentUser.userEmail.length) {
        [userDict setObject:self.currentUser.userEmail forKey:@"userName"];
    }
    [userDict setObject:@(page) forKey:@"page"];
    [userDict setObject:@(5) forKey:@"pageSize"];
    [[CommManager sharedManager] userFeedFromDictionary:userDict completionHandler:^(NSArray *result, NSError *error) {
        if (result && !error) {
            NSMutableArray *userStoriesContainer = [NSMutableArray new];
            for (NSDictionary *userStoryDict in result) {
                Story *story = [[Story alloc] initWithDictionary:userStoryDict];
                [userStoriesContainer addObject:story];
            }
            if (completion) {
                completion(userStoriesContainer, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)userLikedStoriesWithCompletionHandler:(SimpleResultBlock)completion {
    [[CommManager sharedManager] likedStoriesFromDictionary:nil completionHandler:^(NSArray *result, NSError *error) {
        if (result && !error) {
            NSMutableArray *userStoriesContainer = [NSMutableArray new];
            for (NSDictionary *userStoryDict in result) {
                Story *story = [[Story alloc] initWithDictionary:userStoryDict];
                [userStoriesContainer addObject:story];
            }
            if (completion) {
                completion(userStoriesContainer, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)userLikedCompaniesWithCompletionHandler:(SimpleResultBlock)completion {
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    if (self.currentUser.userEmail.length) {
        [userDict setObject:self.currentUser.userEmail forKey:@"userName"];
    }
    [[CommManager sharedManager] likedCompaniesFromDictionary:userDict completionHandler:^(NSArray *result, NSError *error) {
        if (result && !error) {
            NSMutableArray *validatedCompaniesContainer = [NSMutableArray new];
            for (NSDictionary *userCompanyDict in result) {
                Company *company = [[Company alloc] initWithDictionary:@{kCompany : userCompanyDict}];
                [validatedCompaniesContainer addObject:company];
            }
            if (completion) {
                completion(validatedCompaniesContainer, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)performUploadCVRequestWithCompletionHandler:(SimpleCompletionBlock)completion {
    [[CommManager sharedManager] uploadCVRequestFromDictionary:nil completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            if (completion) {
                completion(success, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)performUploadCVWithoutSessionRequest:(NSDictionary *)body withCompletionHandler:(SimpleCompletionBlock)completion {
    [[CommManager sharedManager] uploadWitoutUserSessionCVRequestFromDictionary:body completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            if (completion) {
                completion(success, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)deleteCVWithCompletionHandler:(SimpleCompletionBlock)completion {
    [[CommManager sharedManager] deleteCVRequestFromDictionary:nil completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            if (completion) {
                completion(success, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)followCompanyWithData:(NSDictionary *)body completion:(SimpleCompletionBlock)completion {
    [[CommManager sharedManager] followCompanyWithData:body completion:^(BOOL success, NSError *error) {
        if (completion) {
            completion(success, error);
        }
    }];
}

-(NSMutableDictionary *)packStoryToDictionary:(Story *)story storyIsNew:(BOOL)storyIsNew
{
    NSMutableDictionary *storyDict = [NSMutableDictionary new];
    
    if (storyIsNew == NO)
    {
        [storyDict setObject:story.storyId forKey:@"storyId"];
    }
    if (story.companyId)
    {
        [storyDict setObject:@{@"companyId" : story.companyId} forKey:kCompany];
    }
    
    if (story.storyImages)
    {
        if (storyIsNew)
        {
            NSMutableArray *scaledImages = [NSMutableArray new];
            for (UIImage *originalImage in story.storyImages)
            {
                [scaledImages addObject:[GeneralMethods converImageToBase64String:originalImage]];
            }
            [storyDict setObject:scaledImages forKey:@"images"];
        }
        else
        {
            [storyDict setObject:story.storyImages forKey:@"images"];
        }
    }
    
    NSMutableArray *categories = [NSMutableArray new];
    for (NSString *categoryName in story.categories)
    {
        [categories addObject:@{@"name": categoryName}];
    }
    storyDict[@"categories"] = categories;
    
    if (story.storyTitle) {
        storyDict[@"title"] = story.storyTitle;
    }
    storyDict[@"content"] = story.storyContent;
    if (story.videoLink) {
        storyDict[kVideoLink] = story.videoLink;
    }
    if (story.videoThumbnailLink) {
        storyDict[kVideoThumbnail] = story.videoThumbnailLink;
    }
    
    storyDict[@"storyType"] = [Story stringForStoryType:story.storyType];
    return storyDict;
}

- (void)addStory:(Story *)story anonymously:(BOOL)anonymously completionHandler:(SimpleCompletionBlock)completion {
    //prepare story dict
    NSMutableDictionary *storyDict = [self packStoryToDictionary:story storyIsNew:YES];
    [[CommManager sharedManager] addStoryFromDictionary:storyDict anonymously:anonymously completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            if (completion) {
                completion(success, error);
            }
        } else {
            if (completion) {
                completion(success, [self handleError:error]);
            }
        }
        
    }];
    
}

- (void)updateStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion
{
    NSMutableDictionary *storyDict = [self packStoryToDictionary:story storyIsNew:NO];
    
    [[CommManager sharedManager] updateStoryFromDictionary:storyDict completionHandler:^(BOOL success, NSError *error)
    {
        if (success && !error)
        {
            if (completion)
            {
                completion(success, error);
            }
        }
        else
        {
            if (completion)
            {
                completion(success, [self handleError:error]);
            }
        }
    }];
}

- (void)removeStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion {
    //prepare story dict
    [[CommManager sharedManager] removeStoryFromDictionary:nil storyId:story.storyId completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            if (completion) {
                completion(success, error);
            }
        } else {
            if (completion) {
                completion(success, [self handleError:error]);
            }
        }
        
    }];
}

#pragma mark Comments handling

- (void)commentsForStory:(Story *)story completionHandler:(SimpleResultBlock)completion {
    [self commentsForStory:story page:0 count:STORYCOMMENTS_DEFAULT_PAGE_SIZE completionHandler:completion];
}

- (void)commentsForStory:(Story *)story page:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    if (story) {
        
        NSMutableDictionary *commentsDict = [NSMutableDictionary new];
        [commentsDict setObject:@(page) forKey:@"page"];
        [commentsDict setObject:@(count) forKey:@"pageSize"];
        [commentsDict setObject:story.storyId forKey:@"storyId"];
        
        [[CommManager sharedManager] commentsFromDictionary:commentsDict completionHandler:^(NSArray *result, NSError *error) {
            if (result && !error) {
                
                NSMutableArray *commentsContainer = [NSMutableArray new];
                
                for (NSDictionary *commentDict in result) {
                    Comment *comment = [[Comment alloc] initWithDictionary:commentDict];
                    [commentsContainer addObject:comment];
                }
                
                [commentsContainer sortUsingComparator:^NSComparisonResult(Comment *obj1, Comment *obj2) {
                    return [obj2.commentDate compare:obj1.commentDate];
                }];
                
                if (completion) {
                    completion(commentsContainer, error);
                }
            } else {
                if (completion) {
                    completion(result, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)addComment:(Comment *)comment forStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion {
    if (comment && story) {
        
        NSMutableDictionary *commentDict = [NSMutableDictionary new];
        
        if (comment.commentContent) {
            [commentDict setObject:comment.commentContent forKey:@"content"];
        }
        
        if (comment.commentImage) {
            NSString *base64String = [UIImagePNGRepresentation(comment.commentImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            if (base64String) {
                [commentDict setObject:base64String forKey:@"image"];
            }
        }
        
        [[CommManager sharedManager] addCommentFromDictionary:commentDict storyId:story.storyId completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                comment.commentId = result;
                if (completion) {
                    completion(YES, nil);
                }
            } else {
                if (completion) {
                    completion(NO, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)removeComment:(Comment *)comment forStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion {
    if (comment && story) {
        [[CommManager sharedManager] removeCommentFromDictionary:nil commentId:comment.commentId completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                if (completion) {
                    completion(YES, nil);
                }
            } else {
                if (completion) {
                    completion(NO, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)updateComment:(Comment *)comment forStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion {
    if (comment.commentId && story) {
        
        NSMutableDictionary *commentDict = [NSMutableDictionary new];
        
        [commentDict setObject:comment.commentId forKey:@"commentId"];
        
        if (comment.commentContent) {
            [commentDict setObject:comment.commentContent forKey:@"content"];
        }
        
        if (comment.commentImage) {
            NSString *base64String = [UIImagePNGRepresentation(comment.commentImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            if (base64String) {
                [commentDict setObject:base64String forKey:@"image"];
            }
        }
        
        [[CommManager sharedManager] updateCommentFromDictionary:commentDict completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                if (completion) {
                    completion(YES, nil);
                }
            } else {
                if (completion) {
                    completion(NO, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)wannaWorkInCompany:(Company *)company wanna:(BOOL)wanna completionHandler:(SimpleCompletionBlock)completion {
    if (company.companyId) {
        NSMutableDictionary *companyDict = [NSMutableDictionary new];
        [companyDict setObject:company.companyId forKey:@"companyId"];
        [companyDict setObject:wanna ? @YES : @NO forKey:@"want"];
        [[CommManager sharedManager] wannaWorkWithDictionary:companyDict completionHandler:^(NSDictionary *result, NSError *error) {
            /*if (result && !error) {
                NSInteger remainCount = [[result objectForKeyOrNil:@"remainCount"] integerValue];
                self.currentUser.remainVibeCount = remainCount;
                if (completion) {
                    completion(YES, error);
                }
            } else {
                [self handleError:error];
                if (completion) {
                    completion(NO, error);
                }
            }*/
            if (result && !error) {
                if (completion) {
                    completion(YES, nil);
                }
            } else {
                if (completion) {
                    completion(nil, [self handleError:error]);
                }
            }
        }];
        
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)likeStory:(Story *)story like:(BOOL)like completionHandler:(SimpleCompletionBlock)completion {
    if (story.storyId) {
        NSMutableDictionary *storyDict = [NSMutableDictionary new];
        [storyDict setObject:story.storyId forKey:@"storyId"];
        if (like) [storyDict setObject:@YES forKey:@"like"];
        else [storyDict setObject:@NO forKey:@"like"];
        [[CommManager sharedManager] likeStoryWithDictionary:storyDict completionHandler:^(NSDictionary *result, NSError *error) {
            if (result && !error) {
                if (completion) {
                    completion(YES, nil);
                }
            } else {
                if (completion) {
                    completion(nil, [self handleError:error]);
                }
            }
        }];
        
    } else {
        if (completion) {
            completion(NO, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

#pragma mark Company info & handling


- (void)validateUserEmailToCompany:(NSString *)email completion:(SimpleCompletionBlock)completion {
    [[CommManager sharedManager] validateUserEmailToCompany:email completion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(success,error);
        }
    }];
}

- (void)validateUserCodeToCompany:(NSString *)code completion:(SimpleCompletionBlock)completion
{
    [[CommManager sharedManager] validateUserCodeToCompany:code completion:^(id result, NSError *error)
    {
        if (!completion)
        {
            return;
        }
        
        if(result)
        {
            NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:result];
            
            if ([[dict objectForKey:@"id"] isEqualToString:@"true"])
            {
                __weak DataManager *weakSelf = self;
                [[CommManager sharedManager] getUserIdWithCompletionHandler:^(NSDictionary *resultDict, NSError *error)
                 {
                     __strong DataManager *strongSelf = weakSelf;
                     if (resultDict && !error)
                     {
                         strongSelf.currentUser = [[User alloc] initWithDictionary:resultDict];
                         completion(YES,nil);
                     }
                     else
                     {
                         completion(nil,error);
                     }
                 }];
            }
            else
            {
                completion(NO,error);
            }
        }
        else if (error)
        {
            completion(nil,error);
        }
    }];
}

-(void)getCompanyById:(NSString *)companyId completionHandler:(SimpleResultBlock)completion
{
    [[CommManager sharedManager] companyById:companyId completionHandler:^(id result, NSError *error)
    {
        if (!completion)
        {
            return ;
        }
        else
        {
            completion(result,error);
        }
    }];
}

- (void)companyInfoForCompany:(Company *)company completionHandler:(SimpleResultBlock)completion {
    if (company.companyId) {
        [[CommManager sharedManager] companyInfoFromDictionary:@{@"size" : [self screenSizeDict]} companyId:company.companyId completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                [company populateFromDict:result];
                if (completion) {
                    completion(company, error);
                }
            } else {
                if (completion) {
                    completion(result, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)companyFeedForCompany:(Company *)company page:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    if (company.companyId) {
        NSMutableDictionary *companyDict = [NSMutableDictionary new];
        [companyDict setObject:company.companyId forKey:@"companyId"];
        [companyDict setObject:@(page) forKey:@"page"];
        [companyDict setObject:@(count) forKey:@"pageSize"];
        [companyDict setObject:[self screenSizeDict] forKey:@"size"];
        
        [[CommManager sharedManager] companyFeedFromDictionary:companyDict completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                NSDictionary *companyFeedDict = [result firstObject];
                NSArray *companyStories = [companyFeedDict objectForKeyOrNil:@"storyList"];
                NSMutableArray *companyStoriesContainer = [NSMutableArray new];
                for (NSDictionary *companyStoryDict in companyStories) {
                    Story *story = [[Story alloc] initWithDictionary:companyStoryDict];
                    [companyStoriesContainer addObject:story];
                }
                if (completion) {
                    completion(companyStoriesContainer, error);
                }
            } else {
                if (completion) {
                    completion(result, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (void)companyPositionsForCompany:(Company *)company completionHandler:(SimpleResultBlock)completion {
    if (company.companyId) {
        [[CommManager sharedManager] companyPositionsFromDictionary:nil companyId:company.companyId completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                NSMutableArray *positionsContainer = [NSMutableArray new];
                for (NSDictionary *positionDict in result) {
                    Position *position = [[Position alloc] initWithDictionary:positionDict];
                    [positionsContainer addObject:position];
                }
                if (completion) {
                    completion(positionsContainer, nil);
                }
            } else {
                if (completion) {
                    completion(result, [self handleError:error]);
                }
            }
            
        }];
        
    } else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
        }
    }
}

- (NSString *)shareHtmlWithImageUrl:(NSString *)imageUrl storyUrl:(NSString *)storyUrl titleText:(NSString *)title bodyString:(NSString *)body {    
    NSString *htmlString = @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"><html><head><title>TalentTribe</title><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width\"><style type=\"text/css\">/* CLIENT-SPECIFIC STYLES */#outlook a{padding:0;} /* Force Outlook to provide a \"view in browser\" message */.ReadMsgBody{width:100%;} .ExternalClass{width:100%;} /* Force Hotmail to display emails at full width */.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {line-height: 100%;} /* Force Hotmail to display normal line spacing */body, table, td, a{-webkit-text-size-adjust:100%; -ms-text-size-adjust:100%;} /* Prevent WebKit and Windows mobile changing default text sizes */table, td{mso-table-lspace:0pt; mso-table-rspace:0pt;} /* Remove spacing between tables in Outlook 2007 and up */img{-ms-interpolation-mode:bicubic;} /* Allow smoother rendering of resized image in Internet Explorer *//* RESET STYLES */body{margin:0; padding:0;}img{border:0; height:auto; line-height:100%; outline:none; text-decoration:none;}table{border-collapse:collapse !important;}body{height:100% !important; margin:0; padding:0; width:100% !important;}/* iOS BLUE LINKS */.appleBody a {color:#68440a; text-decoration: none;}.appleFooter a {color:#999999; text-decoration: none;}/* MOBILE STYLES */@media screen and (max-width: 480px) {.table_shrink  {width:95% !important;}.right_table, .left_table{width:100% !important;}.hero {width: 95% !important;}}</style></head><body><style type=\"text/css\">div.preheader{ display: none !important; }</style><div class=\"preheader\" style=\"font-size: 1px; display: none !important;\">Get started with TalentTribe</div><table align=\"center\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"table_shrink\" width=\"100%\"><tbody><tr><td style=\"\"><!-- start body module --><table align=\"center\" bgcolor=\"#FFFFFF\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"table_shrink\" width=\"520\"><!-- start logo --><tbody><tr valign=\"top\"><td align=\"center\" style=\"padding-top:30px;\"><a href=\"http://talenttribe.me\"><span class=\"sg-image\" style=\"float: none; display: block; text-align: center;\"><img height=\"60\" src=\"http://storage.googleapis.com/tt-images/TT-logo.png\" style=\"width: 60px; height: 60px;\" width=\"60\" /></span></a></td></tr><tr valign=\"top\"><td align=\"center\" style=\"padding-top:30px;\"><img src=\"TT_SHARE_IMAGE_URL\" style=\"width:100%;\" width=\"100%\" /></td></tr><tr><td align=\"left\" style=\"padding-top: 30px; font-family:Helvetica neue, Helvetica, Arial, Verdana, sans-serif; color: #1face4; font-size: 24px; line-height: 30px; text-align:left; font-weight:bold;\" valign=\"top\"><a href=\"TT_SHARE_STORY_URL\" style=\"text-decoration: none; color: #1face4\">TT_SHARE_TITLE_TEXT</a></td></tr><!-- end headline --><!-- Hero Image Start--><tr valign=\"top\"><td align=\"left\" style=\"padding-top: 30px; font-family:Helvetica neue, Helvetica, Arial, Verdana, sans-serif; color: #707070; font-size: 16px; line-height: 24px; text-align:left; font-weight:none;\" valign=\"top\"><div>TT_SHARE_BODY_TEXT</div></td></tr><!-- end subheadline --><!-- start button 1 --><tr><td align=\"left\" style=\"padding-top: 10px; padding-bottom:30px\" valign=\"top\"><table align=\"center\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tbody><tr><td align=\"center\" style=\"padding-bottom:0px; padding-top:20px;\"><a class=\"mobile-button\" href=\"TT_SHARE_STORY_URL\" style=\"font-size: 16px; font-family: Helvetica, Helvetica neue, Arial, Verdana, sans-serif; font-weight: none; color: #ffffff; text-decoration: none; background-color: #1face4; border-top: 11px solid #1face4; border-bottom: 11px solid #1face4; border-left: 20px solid #1face4; border-right: 20px solid #1face4; border-radius: 5px; -webkit-border-radius: 5px; -moz-border-radius: 5px; display: inline-block;\" target=\"_blank\">Read it on TalentTribe</a></td></tr></tbody></table></td></tr><!-- end button 1 --><!-- start footer module --></tbody></table><table align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"table_shrink\" width=\"520px\"><tbody><tr><td style=\"color:#cccccc;\" valign=\"top\"><hr color=\"cccccc\" size=\"1\" /></td></tr><tr><td align=\"center\" style=\"padding-top: 30px; font-family: Helvetica, Helvetica neue, Arial, Verdana, sans-serif; color: #707070; font-size: 12px; line-height: 18px; text-align:center; font-weight:none;\" valign=\"top\">Copyright 2015 TalentTribe Ltd. All rights reserved.&nbsp;</td></tr><tr><td align=\"center\" style=\"padding-top: 30px; font-family: Helvetica, Helvetica neue, Arial, Verdana, sans-serif; color: #707070; font-size: 12px; line-height: 18px; text-align:center; font-weight:none;\" valign=\"top\">&nbsp;</td></tr></tbody></table><!-- end footer module --></td></tr></tbody></table><!-- end body module --><p><span style=\"font-family:arial,helvetica,sans-serif; visibility:hidden; display: none !important;\">&lt;%body%&gt;</span></p></body></html>";
    
    NSString *newHtml = [htmlString stringByReplacingOccurrencesOfString:kShareImageUrl withString:imageUrl ? imageUrl : @""];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:kShareStoryUrl withString:storyUrl ? storyUrl : @""];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:kShareTitle withString:title ? title : @""];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:kShareBody withString:body ? body : @""];
    return newHtml;
}

#pragma mark Explore categories

- (void)exploreCategoriesForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    NSMutableDictionary *trendingDict = [NSMutableDictionary new];
    [trendingDict setObject:@(page) forKey:@"page"];
    [trendingDict setObject:@(count) forKey:@"pageSize"];
    [trendingDict setObject:[self screenSizeDict] forKey:@"size"];
    
    [[CommManager sharedManager] exploreCategoriesFromDictionary:trendingDict completionHandler:^(id result, NSError *error) {
        if (result && !error) {
            NSDictionary *resultDict = (NSDictionary *)result;
            
            NSArray *fixedArray = [resultDict objectForKeyOrNil:kFixedCategories];
            NSMutableArray *fixedContainer = [NSMutableArray new];
            
            if (fixedArray) {
                for (NSDictionary *categoryDict in fixedArray) {
                    StoryCategory *category = [[StoryCategory alloc] initWithDictionary:categoryDict];
                    [fixedContainer addObject:category];
                }
            }
            
            NSArray *trendingArray = [resultDict objectForKeyOrNil:kTrendingCategories];
            NSMutableArray *trendingContainer = [NSMutableArray new];
            
            if (trendingArray) {
                for (NSDictionary *categoryDict in trendingArray) {
                    StoryCategory *category = [[StoryCategory alloc] initWithDictionary:categoryDict];
                    [trendingContainer addObject:category];
                }
            }
            
            if (completion) {
                completion(@{kFixedCategories : fixedContainer, kTrendingCategories : trendingContainer}, error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

#pragma mark - TopMessageView

- (void)showTopMessage:(UIViewController *)viewController withText:(NSString *)text backgroundColor:(UIColor *)color {
    if (!self.topMessageView) {
        self.topMessageView = [TopMessageView loadFromXib];
        [viewController.view.window addSubview:self.topMessageView];
    }
    [self.topMessageView setText:text backgroundColor:color];
    [self.topMessageView animate];
}

#pragma mark Filters

- (void)companiesForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    NSMutableDictionary *companiesDict = [NSMutableDictionary new];
    [companiesDict setObject:@(page) forKey:@"page"];
    [companiesDict setObject:@(count) forKey:@"pageSize"];
    [companiesDict setObject:[NSNull null] forKey:@"search"];
    [companiesDict setObject:[self screenSizeDict] forKey:@"size"];
    
    [[CommManager sharedManager] companiesFromDictionary:companiesDict completionHandler:^(NSArray *result, NSError *error) {
        if (result && !error) {
            NSMutableArray *companiesArray = [NSMutableArray new];
            for (NSDictionary *companyDict in result) {
                Company *company = [[Company alloc] initWithDictionary:@{@"company" : companyDict}];
                [companiesArray addObject:company];
            }
            if (completion) {
                completion(companiesArray, nil);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
        
    }];
    
}

- (void)categoriesForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    [self exploreCategoriesForPage:page count:count completionHandler:^(NSDictionary *result, NSError *error) {
        if (result && !error) {
            if (completion) {
                completion([result[kFixedCategories] arrayByAddingObjectsFromArray:result[kTrendingCategories]], error);
            }
        } else {
            if (completion) {
                completion(nil, [self handleError:error]);
            }
        }
    }];
}

- (void)industryForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    /*NSMutableDictionary *industryDict = [NSMutableDictionary new];
     [industryDict setObject:@(page) forKey:@"page"];
     [industryDict setObject:@(count) forKey:@"pageSize"];
     [[CommManager sharedManager] industryFromDictionary:industryDict completionHandler:^(id result, NSError *error) {
     if (result && !error) {
     
     }
     
     }];
     [self addRequest:request];
     */
    if (completion) {
        completion(@[@"Internet", @"Software", @"Technology", @"Mining", @"Tech Support"], nil);
    }
}

- (void)fundingStageForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    /*NSMutableDictionary *fundingStage = [NSMutableDictionary new];
     [fundingStage setObject:@(page) forKey:@"page"];
     [fundingStage setObject:@(count) forKey:@"pageSize"];
     [[CommManager sharedManager] fundingStageFromDictionary:fundingStage completionHandler:^(id result, NSError *error) {
     if (result && !error) {
     
     }
     
     }];
     [self addRequest:request];
     */
    
    if (completion) {
        completion(@[@"funding A", @"funding B", @"funding C", @"funding C+", @"funding C++"], nil);
    }
}

- (void)stageForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion {
    /*NSMutableDictionary *stageDict = [NSMutableDictionary new];
     [stageDict setObject:@(page) forKey:@"page"];
     [stageDict setObject:@(count) forKey:@"pageSize"];
     [[CommManager sharedManager] stageFromDictionary:stageDict completionHandler:^(id result, NSError *error) {
     if (result && !error) {
     
     }
     
     }];
     [self addRequest:request];
     */
    if (completion) {
        completion(@[@"stage A", @"stage B", @"stage C", @"stage C+", @"stage C++"], nil);
    }
}

- (void)quickSearchForText:(NSString *)searchText withLimit:(NSInteger)limit andType:(QuickSearchType)type completionHandler:(SimpleResultBlock)completion {
    NSMutableDictionary *searchDict = [NSMutableDictionary new];
    [searchDict setObject:searchText forKey:@"search"];
    [searchDict setObject:@(limit) forKey:@"limit"];
    [searchDict setObject:[self stringForQuickSearchType:type] forKey:@"type"];
    
    NSMutableArray *companiesArray = [NSMutableArray new];
    
    [[CommManager sharedManager] quickSearchWithDictionary:searchDict completionHandler:^(id result, NSError *error) {
        
        if (result && !error) {
            
            NSArray *companiesArr = (NSArray *) result;
            QuickSearch *quickSearchItem = nil;
            
            
            for (NSDictionary *currentCompany in companiesArr) {
                
                quickSearchItem = [[QuickSearch alloc] initWithDictionary:currentCompany];
                [companiesArray addObject:quickSearchItem];
                
            }
            if (completion) {
                
                completion(companiesArray, error);
            }
        } else {
            if (completion) {
                completion(result, [self handleError:error]);
            }
        }
        
    }];
    
}

- (NSString *)stringForQuickSearchType:(QuickSearchType)type {
    switch (type) {
        case QuickSearchCategory: {
            return @"CATEGORY";
        } break;
        case QuickSearchCompany: {
            return @"COMPANY";
        } break;
        default: {
            return nil;
        } break;
    }
}

- (void)quickSearchWithText:(NSString *)text completion:(SimpleResultBlock)completion {
    NSString *encodedUrl = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[CommManager sharedManager] quickSearchWithString:encodedUrl completion:^(id result, NSError *error) {
        DLog(@"Quick Search Results %@", result);
        
        NSMutableArray *companyObjects = [[NSMutableArray alloc] init];
        NSMutableArray *storyObjects = [[NSMutableArray alloc] init];
        NSMutableArray *categoriesObjects = [[NSMutableArray alloc] init];
        if (!error && result) {
            NSArray *companies = result[@"companyList"];
            NSArray *stories = result[@"storyList"];
            NSArray *categories = result[@"categoryList"];
            
            for (NSDictionary *companyDictionary in companies) {
                Company *company = [[Company alloc] initWithDictionary:companyDictionary];
                [companyObjects addObject:company];
            }
            
            for (NSDictionary *storyDictionary in stories) {
                Story *story = [[Story alloc] initWithDictionary:storyDictionary];
                [storyObjects addObject:story];
            }
            
            for (NSDictionary *categoryDictionary in categories) {
                StoryCategory *category = [[StoryCategory alloc] initWithDictionary:categoryDictionary];
                [categoriesObjects addObject:category];
            }
        }
        
        if (completion) {
            completion(@{@"Companies" : companyObjects,
                         @"Stories": storyObjects,
                         @"Categories" : categoriesObjects }, error);
        }
    }];
}

- (void)recoverPasswordWithEmail:(NSString *)email completionHandler:(SimpleCompletionBlock)completion {
    NSMutableDictionary *passwordDict = [NSMutableDictionary new];
    [passwordDict setObject:email forKey:@"email"];
    [[CommManager sharedManager] recoverPasswordWithDict:passwordDict completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            if (completion) {
                completion(YES, nil);
            }
        } else {
            if (completion) {
                completion(NO, [self handleError:error]);
            }
        }
    }];
}

#pragma mark Requests handling

- (void)cancelAllRequests {
    [[CommManager sharedManager] cancelAllRequests];
}

- (void)cancelRequestsForActivityType:(ActivityType)type {
    //[[CommManager sharedManager] cancelRequestsForTypes:[self requestTypesForActivityType:type]];
}

- (NSArray *)requestTypesForActivityType:(ActivityType)type {
    switch (type) {
        case ActivityTypeStoryFeed: {
            return @[@(RequestTypeStoryFeedForCategory), @(RequestTypeWannaWork)];
        } break;
        case ActivityTypeAddStory: {
            return @[@(RequestTypeAddStory)];
        } break;
        case ActivityTypeExplore: {
            return @[@(RequestTypeExploreCategories), @(RequestTypeQuickSearch)];
        } break;
        case ActivityTypeCompanyProfile: {
            return @[@(RequestTypeCompanyInfo), @(RequestTypeWannaWork)];
        } break;
        case ActivityTypeCompanyStories: {
            return @[@(RequestTypeCompanyStories)];
        } break;
        case ActivityTypeFilter: {
            return @[@(RequestTypeExploreCategories), @(RequestTypeCompaniesForPage), @(RequestTypeIndustryForPage), @(RequestTypeFundingStageForPage), @(RequestTypeStageForPage)];
        } break;
        case ActivityTypeReferQuestion: {
            return @[@(RequestTypeQuickSearch)];
        } break;
        case ActivityTypeStoryDetails: {
            return @[@(RequestTypeWannaWork), @(RequestTypeCommentsForPage), @(RequestTypeAddComment), @(RequestTypeUpdateComment)];
        } break;
        case ActivityTypeLogin: {
            return @[@(RequestTypeLogin)];
        } break;
        case ActivityTypeLogout: {
            return @[@(RequestTypeLogout)];
        } break;
        default: {
            return nil;
        } break;
    }
}

- (NSDictionary *)screenSizeDict {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGSize screenSize = CGSizeMake(size.width * scale, size.height * scale);
    return @{@"width" : @((int)screenSize.width), @"height" : @((int)screenSize.height)};
}

- (void)clearCurrentUser {
    self.silentLogin = NO;
    self.currentUser = nil;
    [self clearCredentials];
    [[CommManager sharedManager] clearCookies];
}

- (NSString *)profileStoragePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"profile"];
}

#pragma mark Credentials handling

- (BOOL)isCredentialsSavedInKeychain {
    return ([self password] && [self email]);
}

- (NSString *)email {
    NSString *email = [FDKeychain itemForKey:kEmailKey forService:[[NSBundle mainBundle] bundleIdentifier] error:nil];
    return email;
}

- (NSString *)password {
    NSString *password = [FDKeychain itemForKey:kPasswordKey forService:[[NSBundle mainBundle] bundleIdentifier] error:nil];
    return password;
}

- (void)setPassword:(NSString *)password {
    NSError *error = NULL;
    [FDKeychain saveItem:password forKey:kPasswordKey forService:[[NSBundle mainBundle] bundleIdentifier] error:&error];
    if (error) {
        DLog(@"****** error save password Keychain %@", error);
    }
}

- (void)setEmail:(NSString *)email {
    NSError *error = NULL;
    [FDKeychain saveItem:email forKey:kEmailKey forService:[[NSBundle mainBundle] bundleIdentifier] error:&error];
    if (error) {
        DLog(@"****** error save email Keychain %@", error);
    }
}

- (BOOL)isAnonymous {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:kAnonymousUser] boolValue];
}

- (void)setIsAnonymous:(BOOL)anonymous {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!anonymous) {
        [defaults removeObjectForKey:kAnonymousUser];
    } else {
        [defaults setObject:@(YES) forKey:kAnonymousUser];
    }
    [defaults synchronize];
}

- (void)clearCredentials {
    self.silentLogin = NO;
    [self setIsAnonymous:NO];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [FDKeychain deleteItemForKey:kPasswordKey forService:[NSBundle mainBundle].bundleIdentifier error:nil];
    [FDKeychain deleteItemForKey:kEmailKey forService:[NSBundle mainBundle].bundleIdentifier error:nil];
}

+ (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL res = [emailTest evaluateWithObject:candidate];
    return res;
}

+ (BOOL) validatePassword: (NSString *) candidate {
    BOOL res = candidate.length > 4;
    return res;
}


- (void)uploadDataToGCS:(NSData *)data completion:(SimpleResultBlock)completion {
    storageService = [[GTLRStorageService alloc] init];
    
    NSDictionary *headers = @{@"x-goog-project-id": @"874300976889",
                              @"Content-Type": @"application/json-rpc",
                              @"Accept": @"application/json-rpc"};
    storageService.additionalHTTPHeaders = headers;
    storageService.APIKey = @"AIzaSyAMixmDLhNQpVuJ-qxK3LQinNZZPEulS1I";
    storageService.authorizer = _auth;
    storageService.retryEnabled = YES;
    
    GTLRUploadParameters *uploadParam = [GTLRUploadParameters uploadParametersWithData:data MIMEType:@"video/quicktime"];
    GTLRStorage_Object *storageObj = [GTLRStorage_Object object];
    storageObj.name = [NSString stringWithFormat:@"%f.mov", [[NSDate date]timeIntervalSince1970]];
    
//    GTLRStorageQuery_ObjectsGet *query = [GTLRStorageQuery_ObjectsGet queryForObjectsInsertWithObject:storageObj bucket:@"tt-videos" uploadParameters:uploadParam];
    
    GTLRStorageQuery_ObjectsGet *query = [GTLRStorageQuery_ObjectsGet queryForMediaWithBucket:@"tt-videos"
                                                  object:storageObj.name];
    
    
//    [storageService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStorageObject *object, NSError *error) {
//        if(object && !error)
//        {
//            completion(object.mediaLink, nil);
//        }
//    }];
}

- (void)showLoginScreen {
    [self showLoginScreenModal:YES];
}

- (void)showLoginScreenModal:(BOOL)modal {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginScreenNotification object:@(modal)];
}

- (NSString *)serverURL {
    return [CommManager sharedManager].baseURLString.length ? [CommManager sharedManager].baseURLString : SERVER_URL;
}
- (void)setServerURL:(NSString *)string {
    [[CommManager sharedManager] setBaseURLString:string];
}

+ (NSString *)deviceIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
