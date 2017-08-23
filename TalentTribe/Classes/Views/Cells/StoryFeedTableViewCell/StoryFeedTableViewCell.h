//
//  StoryFeedTableViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTouchImageView.h"
#import "TTDragVibeView.h"
#import "StoryFeedCollectionViewCell.h"
#import "Company.h"

#define kScrollingMode @"SCROLLING_MODE"

@class StoryFeedTableViewCell;

@protocol  StoryFeedTableViewCellDelegate <NSObject>

- (void)willBeginDraggingOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell;
- (void)willEndDraggingOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell;
- (void)profileOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell;
- (void)signupOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell;
- (void)vibeOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell completion:(SimpleCompletionBlock)completion;
- (void)storyFeedCellShouldMoveToUserProfile:(StoryFeedTableViewCell *)cell;
- (void)didHideDragView;
- (void)hiringTappedOnCell:(StoryFeedTableViewCell *)cell;
- (void)leftButtonPressedOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell;
- (void)rightButtonPressedOnStoryFeedTableViewCell:(StoryFeedTableViewCell *)cell;
- (void)collectionViewCellShouldClick:(StoryFeedCollectionViewCell *)cell;
@end

@interface StoryFeedTableViewCell : UITableViewCell

@property (nonatomic, weak) id <StoryFeedTableViewCellDelegate> delegate;

@property (nonatomic, strong) Company *company;

@property (nonatomic, strong) TTDragVibeView *dragVibeView;

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;

@property (nonatomic, weak) IBOutlet UIView *headerContainer;
@property (nonatomic, weak) IBOutlet UIImageView *companyImageView;
@property (nonatomic, weak) IBOutlet UILabel *companyTitle;
@property (nonatomic, weak) IBOutlet UILabel *companyType;
@property (nonatomic, weak) IBOutlet UIImageView *companyLiked;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerHeightConstant;

- (void)setCollectionViewDataSource:(id <UICollectionViewDataSource>)dataSource delegate:(id <UICollectionViewDelegate>)delegate;

- (void)updateButtonsState;

- (void)setUserVibedCompany:(BOOL)userVibed;
- (void)setUserVibedStory:(BOOL)userVibed;

-(void)blinkCellWithColor:(UIColor *)color interval:(CGFloat)interval firstAlpha:(CGFloat)alpha parent:(UITableView *)parent;

@end

