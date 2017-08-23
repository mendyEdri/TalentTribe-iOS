//
//  TTDragVibeView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/20/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTouchImageView.h"
#import "Company.h"
#import "Story.h"

@class TTDragVibeView;

@protocol  TTDragVibeViewDelegate <NSObject>

- (void)willBeginDraggingOnDragVibeView:(TTDragVibeView *)cell;
- (void)willEndDraggingOnDragVibeView:(TTDragVibeView *)cell;
- (void)didHideDragView:(TTDragVibeView *)cell;
- (void)didTappedOnHiring:(TTDragVibeView *)cell;
- (void)vibeOnDragVibeView:(TTDragVibeView *)cell completion:(SimpleCompletionBlock)completion;
- (void)signupOnDragVibeView:(TTDragVibeView *)cell;
- (void)profileOnDragVibeView:(TTDragVibeView *)cell;
- (void)unlikeVibeOnDragView:(TTDragVibeView *)cell;

@end

@interface TTDragVibeView : UIView

@property (nonatomic, weak) id <TTDragVibeViewDelegate> delegate;

@property (nonatomic, weak) Company *currentCompany;
@property (nonatomic, weak) Story *currentStory;

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL userVibed;

- (void)performVibeActionManually;
- (void)animateManually;
- (void)endDragging;
- (void)hideVibeView;
- (void)hideHiringButton:(BOOL)hide;
- (void)showLikeTitleLabel:(BOOL)show;
- (void)setLikeTop:(BOOL)top companyProfile:(BOOL)companyProfile;
@end
