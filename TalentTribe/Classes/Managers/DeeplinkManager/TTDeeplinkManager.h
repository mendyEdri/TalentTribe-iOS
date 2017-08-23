//
//  TTDeeplinkManager.h
//  TalentTribe
//
//  Created by Asi Givati on 10/12/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoryFeedTableViewCell.h"

#define DEEPLINK_MANAGER [TTDeeplinkManager sharedInstance];
#define TT_DOMAIN @"https://talenttribe.me/"
#define TT_REDIRECT @"redirect.html?"
#define ON_MODE @"working"
#define WAITING_MODE @"waiting"
#define OFF_MODE @"off"

@protocol DeeplinkManagerDelegate <NSObject>

- (void)selectTabBarAtIndex:(int)index;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TTDeeplinkManager : NSObject <UIAlertViewDelegate>

+(id)sharedInstance;

-(void)loadPath:(NSString *)urlPath;

@property (nonatomic) NSString *fullPath;
@property (strong,nonatomic) NSString *pageId;
@property (strong,nonatomic) NSString *objectId;
@property int tabBarNum;
@property BOOL cellClicked;
@property (strong,nonatomic) NSString *mode;
@property NSIndexPath *selectedIndexPath;
@property (nonatomic, weak) id <DeeplinkManagerDelegate> delegate;
@property (strong, nonatomic) id selectedViewController;



-(void)startWithAlert: (BOOL)showAlert;
-(void)deallocDeeplinkManager;
-(void)storyFeedTableViewScrollCompleted;

@end
