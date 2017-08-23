//
//  StoryFeedCollectionViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTDynamicLabel.h"
#import "TTGradientHandler.h"
#import "LinedTextView.h"
#import "TTDragVibeView.h"

@class StoryFeedCollectionViewCell;

@protocol StoryFeedCollectionViewCellDelegate <NSObject>
@optional
- (void)shareButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell;
- (void)commentButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell;
- (void)editButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell;
- (void)deleteButtonActionOnStoryFeedCell:(StoryFeedCollectionViewCell *)cell;

- (void)willBeginDraggingOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell;
- (void)willEndDraggingOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell;
- (void)profileOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell;
- (void)signupOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell;
- (void)vibeOnStoryFeedTableViewCell:(StoryFeedCollectionViewCell *)cell completion:(SimpleCompletionBlock)completion;
- (void)storyFeedCellShouldMoveToUserProfile:(StoryFeedCollectionViewCell *)cell;
- (void)didHideDragView;
- (void)collectionViewCellShouldClick:(StoryFeedCollectionViewCell *)cell;

@end

@interface StoryFeedCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <StoryFeedCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) IBOutlet UIView *containerView;

@property (nonatomic, weak, setter=setBackgroundImageView:) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet TTCustomGradientView *gradientView;
/*
@property (nonatomic, strong) TTCustomGradientView *blackoutGradientView;
@property (nonatomic, strong) TTCustomGradientView *blackoutGradientViewTop;
*/

@property (nonatomic, weak) IBOutlet TTDynamicLabel *titleLabel;
@property (nonatomic, weak) IBOutlet LinedTextView *textView;

@property (nonatomic, weak) IBOutlet UIView *authorContainer;
@property (nonatomic, weak) IBOutlet UIImageView *authorImageView;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;

@property (nonatomic, weak) IBOutlet UIView *buttonsContainer;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;

@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) IBOutlet UIView *editContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleBottomConstraint;

- (void)commonInit;

- (NSAttributedString *)attributedStringForString:(NSString *)string;

#pragma mark - Company Header

@property (nonatomic, strong) TTDragVibeView *dragVibeView;
@property (nonatomic, weak) IBOutlet UIView *headerContainer;
@property (nonatomic, weak) IBOutlet UIImageView *companyImageView;
@property (nonatomic, weak) IBOutlet UILabel *companyTitle;
@property (nonatomic, strong) Company *company;
- (void)setUserVibedCompany:(BOOL)userVibed;
- (void)setUserVibedStory:(BOOL)userVibed;
- (void)setHeaderEnable:(BOOL)enable;
@end
