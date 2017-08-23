//
//  Constants.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/26/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#ifndef TalentTribe_Constants_h
#define TalentTribe_Constants_h

#import "NSDictionary+ValueOrNil.h"
#import "DataManager.h"
#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "TTActivityIndicator.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#ifdef STAGING
#   define SERVER_URL @"https://talenttribe.me"
#else
#   define SERVER_URL @"https://prodserver.talenttribe.me"
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define kTouchedStatusBar @"touchedStatusBar"
#define kDeviceToken @"deviceToken"
#define kRemoteNotification @"RemoteNotification"

#define kPasswordKey @"password"
#define kEmailKey @"userEmail"

#define kTitleKey @"title"
#define kValueKey @"value"

#define kShareImageUrl @"TT_SHARE_IMAGE_URL"
#define kSharePlayButton @"TT_SHARE_PLAY_IMAGE"
#define kShareStoryUrl @"TT_SHARE_STORY_URL"
#define kShareTitle @"TT_SHARE_TITLE_TEXT"
#define kShareBody @"TT_SHARE_BODY_TEXT"

#pragma mark - Mixpanel Event Keys

// Interactions
#define kUserInteractionType @"UserInteractionType"

#define kCancel @"cancelPressed"
#define kTap @"Tap"
#define kBackButton @"BackPressed"
#define kSkipped @"SkippedPressed"

// User
#define kUserCompleted @"UserCompletedProfile"
#define kUserRegisterd @"UserRegisterd"
#define kUserFirstVibe @"UserFirstVibe"

// User Events Type
#define kEventType @"EventType"

#define kLikeVibe @"LikeVibe"
#define kLikeVibeCanceled @"LikeVibeCanceled"
#define kStoryShare @"StoryShare"
#define kSignedUp @"SignUpButtonPressed"
#define kSignedIn @"SignInButtonPressed"
#define kLinkedinButton @"LinkedinButtonPressed"
#define kLinkedinLogin @"LinkedinLogin"
#define kOpenPositionsFromFeed @"OpenPositionsFromFeedTapped"

#define kVibeAnimateStart @"LikeVibeAnimateSatrt"
#define kVibeAnimateCanceld @"LikeVibeAnimateCanceld"

#define kNewVibeTapped @"NewVibeTapped"
#define kFollowPositionCheck @"FollowPositionChecked"
#define kFollowStoriesCheck @"FollowStoriesChecked"

#define kContinuePostLike @"ContinuePostLike"
#define kSignupPostLike @"SignupPostLike"

#define kCompanyProfile @"CompanyProfileEntered"
#define kScreenName @"ScreenName"
#define kConnecting @"Connecting"
#define kSucceed @"Succeed"
#define kUserScrolledSide @"userScrolledToSide"

#define screenWidth  [UIScreen mainScreen].bounds.size.width

#define screenHeight  [UIScreen mainScreen].bounds.size.height

#define isIphone4  ([[UIScreen mainScreen] bounds].size.height == 480)?TRUE:FALSE

#define isIphone5   ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

#define isIphone6  ([[UIScreen mainScreen] bounds].size.height == 667)?TRUE:FALSE

#define isIphone6Plus  ([[UIScreen mainScreen] bounds].size.height == 736)?TRUE:FALSE

#define ISiOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define ISiOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#define kShowLoginScreenNotification @"showLoginScreenNotification"
//#define kLogedInNotification @"LoggedInNotification"

#define kSummaryCharacterLimit 1000

#define STORYFEED_DEFAULT_PAGE_SIZE 10
#define STORYFEED_VIBE_INDEX 4
#define STORYFEED_PRIVACY_INDEX 7
#define STORYFEED_JOIN_COMPANY_INDEX 13
#define STORYFEED_CREATE_PROFILE_INDEX 13
#define STORYFEED_DEFAULT_GENERAL_ID @"GENERAL_QUESTION_LINE"
#define STORYCOMMENTS_DEFAULT_PAGE_SIZE 6
#define USERFEED_DEFAULT_PAGE_SIZE 10
#define COMPANYFEED_DEFAULT_PAGE_SIZE 10
#define EXPLORE_DEFAULT_PAGE_SIZE 25
#define FILTER_DEFAULT_PAGE_SIZE 20

#define kImageMaxSize 1500
#define kImageQuality 0.7f

//Fonts

#define TITILLIUMWEB_SEMIBOLD(s) [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:s]
#define TITILLIUMWEB_REGULAR(s) [UIFont fontWithName:@"TitilliumWeb-Regular" size:s]
#define TITILLIUMWEB_BOLD(s) [UIFont fontWithName:@"TitilliumWeb-Bold" size:s]
#define TITILLIUMWEB_LIGHT(s) [UIFont fontWithName:@"TitilliumWeb-Light" size:s]

#define BEBAS_BOLD(s) [UIFont fontWithName:@"BebasNeueBold" size:s]

#endif
