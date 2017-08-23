//
//  StoryCommentsViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "TTDragVibeView.h"

@class Company, Story;

@protocol StoryDetailsProtocol
- (void)headerViewBackgroundImage:(UIImage *)backgroundImage;
- (void)openProfilePage;
@end

@interface StoryDetailsViewController : SLKTextViewController <TTDragVibeViewDelegate>

@property BOOL shouldOpenComment;
@property BOOL canOpenCompanyDetails;
@property BOOL openedByDeeplink;
@property NSUInteger pageIndex;
@property (nonatomic, strong) Company *company;
@property (nonatomic, strong) Story *currentStory;
@property (nonatomic, assign) BOOL shouldDownloadStory;
@property (nonatomic, assign) id<StoryDetailsProtocol>delegate;
@property (nonatomic, strong) TTDragVibeView *dragVibeView;

@property (nonatomic, copy) void (^dragHandler)(BOOL visible);

typedef NS_ENUM(NSInteger, StoryDetailsControllerType) {
    StoryDetailsTypePageController,
    StoryDetailsTypeViewController
};
@property (nonatomic, assign) StoryDetailsControllerType storyDetailsControllerType;

- (void)shareStory:(Story *)story;
- (void)playVideo:(BOOL)play;
- (void)setupDragViewOnView:(UIView *)view;
- (void)updateHeaderButtonsState;
- (void)didFinishDecelerating;
@end
