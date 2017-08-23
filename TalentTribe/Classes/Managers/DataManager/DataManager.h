//
//  DataManager.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class User, Story, StoryCategory, Comment, Company, AsyncVideoDisplay, VideoControllersView;

typedef void (^SimpleCompletionBlock)(BOOL success, NSError *error);
typedef void (^SimpleResultBlock)(id result, NSError *error);

typedef enum {
    ActivityTypeStoryFeed,
    ActivityTypeAddStory,
    ActivityTypeExplore,
    ActivityTypeCompanyProfile,
    ActivityTypeCompanyStories,
    ActivityTypeUserStories,
    ActivityTypeFilter,
    ActivityTypeReferQuestion,
    ActivityTypeStoryDetails,
    ActivityTypeLogin,
    ActivityTypeLogout
} ActivityType;

typedef enum {
    QuickSearchCompany,
    QuickSearchCategory
} QuickSearchType;

@interface DataManager : NSObject

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSMutableArray *companySelectedArray;
@property (getter=isLikeOpen, assign) BOOL likeOpen;

@property NetworkStatus reachabilityStatus;

@property BOOL silentLogin;
@property (nonatomic) BOOL isAnonymous;
@property (nonatomic, getter=isHashDiffrent, setter=setHashDiffrent:) BOOL hashDiffrent;
@property (nonatomic, assign, getter=isScrolling, setter=setScrolling:) BOOL scrolling;
@property (nonatomic, assign, getter=isMuted, setter=setMuted:) BOOL mute;
@property (nonatomic, strong) NSMutableArray *trendingArray;
@property (nonatomic, strong) NSMutableArray *fixedArray;
@property (nonatomic, weak) VideoControllersView *videoController;

+ (instancetype)sharedManager;

#pragma mark Login handling

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(SimpleResultBlock)completion;
- (void)silentLoginWithCompletion:(SimpleResultBlock)completion;
- (void)logoutWithCompletionHandler:(SimpleCompletionBlock)completion;

- (void)registerWithEmail:(NSString *)email password:(NSString *)password completion:(SimpleResultBlock)completion;

- (void)requestLinkedInTokenWithAuthorizationHandler:(SimpleResultBlock)authorizationHandler completionHandler:(SimpleResultBlock)completion;
- (void)linkedInProfileWithCompletion:(SimpleResultBlock)completion;

- (void)updateUser:(User *)user completionHandler:(SimpleCompletionBlock)completion;

- (void)updatePassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completionHandler:(SimpleCompletionBlock)completion;

- (void)associatedCompaniesWithCompletionHandler:(SimpleResultBlock)completion;
- (void)unregisterUserCompany:(Company *)company completionHandler:(SimpleCompletionBlock)completion;
- (void)userNotificationsWithParams:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion;
#pragma mark Story handling

- (void)storyFeedWithCompletionHandler:(SimpleResultBlock)completion;
- (void)storyFeedForCategory:(StoryCategory *)category companyId:(NSString *)companyId completionHandler:(SimpleResultBlock)completion;
- (void)storyFeedForCategory:(StoryCategory *)category companyId:(NSString *)companyId page:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;

- (void)storyFeedIndexesWithParams:(NSDictionary *)params forceReload:(BOOL)reload completionHandler:(SimpleResultBlock)completion;
- (void)storyFeedIndexesForXAxis:(NSInteger)xIndex inRow:(NSInteger)yIndex maxCount:(NSInteger)count completionHandler:(SimpleResultBlock)completion;
- (void)storyFeedIndexesForYAxis:(NSInteger)yIndex maxCount:(NSInteger)count completionHandler:(SimpleResultBlock)completion;
- (void)storiesByIds:(NSDictionary *)params orderByIndexes:(NSArray *)indexes completionHandler:(SimpleResultBlock)completion;
- (void)sha1StringFromIdsArray:(NSArray *)idsArray completionHandler:(SimpleResultBlock)completion;
- (void)refreshIdIndexesWithEncryptedString:(NSString *)sha1String completionHandler:(SimpleResultBlock)completion;
- (void)clearFeedIndexes;

- (void)userFeedForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;

- (void)userLikedStoriesWithCompletionHandler:(SimpleResultBlock)completion;
- (void)userLikedCompaniesWithCompletionHandler:(SimpleResultBlock)completion;

- (void)performUploadCVRequestWithCompletionHandler:(SimpleCompletionBlock)completion;
- (void)performUploadCVWithoutSessionRequest:(NSDictionary *)body withCompletionHandler:(SimpleCompletionBlock)completion;
- (void)deleteCVWithCompletionHandler:(SimpleCompletionBlock)completion;

- (void)addStory:(Story *)story anonymously:(BOOL)anonymously completionHandler:(SimpleCompletionBlock)completion;
- (void)updateStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion;
- (void)removeStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion;

#pragma mark - TopMessageView

- (void)showTopMessage:(UIViewController *)viewController withText:(NSString *)text backgroundColor:(UIColor *)color;

#pragma mark - AsyncVideo Handle

- (void)commentsForStory:(Story *)story completionHandler:(SimpleResultBlock)completion;
- (void)commentsForStory:(Story *)story page:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;

- (void)addComment:(Comment *)comment forStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion;
- (void)removeComment:(Comment *)comment forStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion;
- (void)updateComment:(Comment *)comment forStory:(Story *)story completionHandler:(SimpleCompletionBlock)completion;
- (void)validateUserEmailToCompany:(NSString *)email completion:(SimpleCompletionBlock)completion;
- (void)validateUserCodeToCompany:(NSString *)code completion:(SimpleCompletionBlock)completion;
- (void)wannaWorkInCompany:(Company *)company wanna:(BOOL)wanna completionHandler:(SimpleCompletionBlock)completion;
- (void)likeStory:(Story *)story like:(BOOL)like completionHandler:(SimpleCompletionBlock)completion;
- (void)getCompanyById:(NSString *)companyId completionHandler:(SimpleResultBlock)completion;
- (void)getStoryWithParams:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion;

- (void)companyInfoForCompany:(Company *)company completionHandler:(SimpleResultBlock)completion;
- (void)companyFeedForCompany:(Company *)company page:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;

- (void)companyPositionsForCompany:(Company *)company completionHandler:(SimpleResultBlock)completion;

- (NSString *)shareHtmlWithImageUrl:(NSString *)imageUrl storyUrl:(NSString *)storyUrl titleText:(NSString *)title bodyString:(NSString *)body;

- (void)exploreCategoriesForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;

- (void)quickSearchWithText:(NSString *)text completion:(SimpleResultBlock)completion;
- (void)quickSearchForText:(NSString *)searchText withLimit:(NSInteger)limit andType:(QuickSearchType)type completionHandler:(SimpleResultBlock)completion;
- (void)uploadVideoWithParams :(NSMutableDictionary *)params completionHandler:(SimpleResultBlock)completion;
- (void)companiesForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;
- (void)categoriesForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;
- (void)industryForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;
- (void)fundingStageForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;
- (void)stageForPage:(NSInteger)page count:(NSInteger)count completionHandler:(SimpleResultBlock)completion;

- (void)followCompanyWithData:(NSDictionary *)body completion:(SimpleCompletionBlock)completion;

- (void)recoverPasswordWithEmail:(NSString *)email completionHandler:(SimpleCompletionBlock)completion;

- (void)cancelRequestsForActivityType:(ActivityType)type;
- (void)cancelAllRequests;

- (BOOL)isReachable;

//user
- (BOOL)isCredentialsSavedInKeychain;
- (NSString *)password;
- (NSString *)email;
- (void)setPassword:(NSString *)password;
- (void)setEmail:(NSString *)email;

- (void)clearCurrentUser;

+ (BOOL)validateEmail: (NSString *) candidate;
+ (BOOL)validatePassword: (NSString *) candidate;

- (void)uploadDataToGCS:(NSData *)data completion:(SimpleResultBlock)completion;

- (void)showLoginScreen;

- (NSString *)serverURL;
- (void)setServerURL:(NSString *)string;
+ (NSString *)deviceIPAddress;
@end
