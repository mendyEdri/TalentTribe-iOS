//
//  CommManager.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RequestTypeStoryFeedForCategory,
    RequestTypeAddStory,
    RequestTypeUpdateStory,
    RequestTypeRemoveStory,
    RequestTypeGetStory,
    RequestTypeCompanyInfo,
    RequestTypeCompanyStories,
    RequestTypeCompanyPositions,
    RequestTypeWannaWork,
    RequestTypeLikeStory,
    RequestTypeExploreCategories,
    RequestTypeQuickSearchOLD,
    RequestTypeCompaniesForPage,
    RequestTypeIndustryForPage,
    RequestTypeFundingStageForPage,
    RequestTypeStageForPage,
    RequestTypeCommentsForPage,
    RequestTypeAddComment,
    RequestTypeUpdateComment,
    RequestTypeRemoveComment,
    RequestTypeLogin,
    RequestTypeLogout,
    RequestTypeRecoverPassword,
    RequestTypeUpdateUser,
    RequestTypeGetProfile,
    RequestTypeUserStories,
    RequestTypeUserLikedStories,
    RequestTypeUserLikedCompanies,
    RequestTypeUploadCV,
    RequestTypeUploadCVWithoutSession,
    RequestTypeDeleteCV,
    RequestTypeUpdatePassword,
    RequestTypeGetFeedIndexes,
    RequestTypeGetFeedStoriesById,
    RequestTypeRefreshIndexes,
    RequestTypeValidateUserEmailToCompany,
    RequestTypeValidateUserCodeToCompany,
    RequestTypeUploadVideo,
    RequestTypeQuickSearch,
    RequestTypeFeedByCategory,
    RequestTypeFollowCompany
} RequestType;

typedef NS_ENUM(NSUInteger, ContentType) // (the var type, the enum name)
{
    Json,
    Octet_Stream
};

@class CommManager;

@protocol CommManagerDelegate <NSObject>

@optional

-(void)commManager:(CommManager *)manager uploadProcessDidUpdatedWithPercent:(CGFloat)percent;

@end


@interface CommManager : NSObject

@property (nonatomic, strong) NSString *baseURLString;

+ (instancetype)sharedManager;

#pragma mark Login handling

- (void)loginWithDictionary:(NSDictionary *)loginDict completionHandler:(SimpleResultBlock)completion;
- (void)logoutWithDictionary:(NSDictionary *)loginDict completionHandler:(SimpleCompletionBlock)completion;

#pragma mark User Profile

- (void)updateCurrentUserWithDictionary:(NSDictionary *)userDict completionHandler:(SimpleResultBlock)completion;
- (void)userProfileWithUserId:(NSString *)userId completionHandler:(SimpleResultBlock)completion;
- (void)getUserIdWithCompletionHandler:(SimpleResultBlock)completion;

- (void)updatePasswordWithDictionary:(NSDictionary *)passDict completionHandler:(SimpleCompletionBlock)completion;

#pragma mark Story handling

- (void)storyFeedWithDictionary:(NSDictionary *)storyFeedDict completionHandler:(SimpleResultBlock)completion;
- (void)storyFeedIndexesWithDictionary:(NSDictionary *)paramsDictionary completionHandler:(SimpleResultBlock)completion;
- (void)storyFeedStoriesById:(NSDictionary *)paramsDictionary completionHandler:(SimpleResultBlock)completion;
- (void)userFeedFromDictionary:(NSDictionary *)userFeedDict completionHandler:(SimpleResultBlock)completion;
- (void)userNotification:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion;
- (void)refreshIndexesWithEncrypedIds:(NSString *)sha1String completionHandler:(SimpleResultBlock)completion;
- (void)storyFeedWithCategoryName:(NSString *)categoryName completionHandler:(SimpleResultBlock)completion;

- (void)getStoryWithParams:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion;

- (void)addStoryFromDictionary:(NSDictionary *)storyDict anonymously:(BOOL)anonymously completionHandler:(SimpleCompletionBlock)completion;
- (void)updateStoryFromDictionary:(NSDictionary *)storyDict completionHandler:(SimpleCompletionBlock)completion;
- (void)removeStoryFromDictionary:(NSDictionary *)storyDict storyId:(NSString *)storyId completionHandler:(SimpleCompletionBlock)completion;

- (void)commentsFromDictionary:(NSDictionary *)commentDict completionHandler:(SimpleResultBlock)completion;

- (void)addCommentFromDictionary:(NSDictionary *)commentDict storyId:(NSString *)storyId completionHandler:(SimpleResultBlock)completion;
- (void)removeCommentFromDictionary:(NSDictionary *)commentDict commentId:(NSString *)commentId completionHandler:(SimpleResultBlock)completion;
- (void)updateCommentFromDictionary:(NSDictionary *)commentDict completionHandler:(SimpleResultBlock)completion;

- (void)wannaWorkWithDictionary:(NSDictionary *)companyDict completionHandler:(SimpleResultBlock)completion;
- (void)likeStoryWithDictionary:(NSDictionary *)storyDict completionHandler:(SimpleResultBlock)completion;

- (void)likedCompaniesFromDictionary:(NSDictionary *)likedDict completionHandler:(SimpleResultBlock)completion;
- (void)likedStoriesFromDictionary:(NSDictionary *)likedDict completionHandler:(SimpleResultBlock)completion;
- (void)uploadVideoWithParams:(NSMutableDictionary *)params completionHandler:(SimpleResultBlock)completion;
- (void)uploadCVRequestFromDictionary:(NSDictionary *)cvDict completionHandler:(SimpleCompletionBlock)completion;
- (void)uploadWitoutUserSessionCVRequestFromDictionary:(NSDictionary *)cvDict completionHandler:(SimpleCompletionBlock)completion;
- (void)deleteCVRequestFromDictionary:(NSDictionary *)cvDict completionHandler:(SimpleCompletionBlock)completion;

- (void)validateUserEmailToCompany:(NSString *)email completion:(SimpleCompletionBlock)completion;
- (void)validateUserCodeToCompany:(NSString *)code completion:(SimpleResultBlock)completion;
- (void)companyInfoFromDictionary:(NSDictionary *)companyInfoDict companyId:(NSString *)companyId completionHandler:(SimpleResultBlock)completion;
- (void)companyById:(NSString *)companyId completionHandler:(SimpleResultBlock)completion;
- (void)companyFeedFromDictionary:(NSDictionary *)companyFeedDict completionHandler:(SimpleResultBlock)completion;

- (void)companyPositionsFromDictionary:(NSDictionary *)companyDict companyId:(NSString *)companyId completionHandler:(SimpleResultBlock)completion;

- (void)exploreCategoriesFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion;

- (void)categoriesFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion;
- (void)companiesFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion;
- (void)industryFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion;
- (void)fundingStageFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion;
- (void)stageFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion;

- (void)getCompanyNameFromDictionary:(NSDictionary *)searchDict completionHandler:(SimpleResultBlock)completion;

- (void)quickSearchWithDictionary:(NSDictionary *)searchDict completionHandler:(SimpleResultBlock)completion;
- (void)quickSearchWithString:(NSString *)searchString completion:(SimpleResultBlock)completion;
- (void)registerToPushWithDictionary:(NSDictionary *)pushDict completionHandler:(SimpleCompletionBlock)completion;
- (void)unregisterFromPushWithDictionary:(NSDictionary *)pushDict completionHandler:(SimpleCompletionBlock)completion;

- (void)registerUserWithLinkedinToken:(NSString *)token completionHandler:(SimpleResultBlock)completion;
- (void)registerWithDictionary:(NSDictionary *)pushDict completionHandler:(SimpleResultBlock)completion;

- (void)followCompanyWithData:(NSDictionary *)body completion:(SimpleCompletionBlock)completion;

- (void)cancelRequestsForTypes:(NSArray *)types;
- (void)cancelAllRequests;

- (void)clearCookies;

- (void)recoverPasswordWithDict:(NSDictionary *)passwordDict completionHandler:(SimpleCompletionBlock)completion;

@property id <CommManagerDelegate> delegate;

@end
