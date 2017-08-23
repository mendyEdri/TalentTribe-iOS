//
//  DetailsPageViewController.h
//  TalentTribe
//
//  Created by Mendy on 27/10/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Company.h"
#import "Story.h"
#import <CoreMotion/CoreMotion.h>

@protocol DetailsPageDelegate <NSObject>

- (void)updateStoriesArray:(NSArray *)storiesArray atRowIndex:(NSInteger)row;
@end

@interface DetailsPageViewController : UIViewController

@property BOOL shouldOpenComment;
@property BOOL canOpenCompanyDetails;
@property BOOL openedByDeeplink;
@property (nonatomic, strong) Company *company;
@property (nonatomic, strong) Story *currentStory;
@property (nonatomic, assign) NSInteger startingIndex;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) id<DetailsPageDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *storiesIds;
@property (nonatomic, assign) BOOL pagingDisabled;
@property (nonatomic, assign) BOOL shouldDownloadStory;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end
