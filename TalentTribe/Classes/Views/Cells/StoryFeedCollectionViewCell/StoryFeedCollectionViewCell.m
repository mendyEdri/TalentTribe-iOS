//
//  StoryFeedCollectionViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedCollectionViewCell.h"
#import "UIView+Additions.h"
#import "TTDragVibeView.h"

#define kShadowBlur 10.0f

#import "StoryFeedCreateUserProfileCell.h"

@interface StoryFeedCollectionViewCell () <TTDragVibeViewDelegate>

@end

@implementation StoryFeedCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    /*
    self.blackoutGradientView = [[TTCustomGradientView alloc] initWithColors:@[[UIColor clearColor], UIColorFromRGBA(0x000000, 0.9f)] locations:@[@(0.0), @(1.0)]];
    self.blackoutGradientViewTop = [[TTCustomGradientView alloc] initWithColors:@[[UIColor clearColor], UIColorFromRGBA(0x000000, 0.9f)] locations:@[@(0.0), @(1.0)]];
     */
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //[self.containerView insertSubview:self.blackoutGradientView aboveSubview:self.backgroundImageView];
    //[self.containerView insertSubview:self.blackoutGradientViewTop aboveSubview:self.backgroundImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /*
    CGFloat height = ceil(CGRectGetWidth(self.contentView.frame) / 374.0f * 140.0f);
    self.blackoutGradientView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.frame) - height, CGRectGetWidth(self.contentView.frame), height);
    self.blackoutGradientViewTop.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), height);
    self.blackoutGradientViewTop.transform = CGAffineTransformMakeRotation(M_PI_2 * 2.0);
     */
}

- (void)setHeaderEnable:(BOOL)enable {
   self.headerContainer.hidden = !enable;
    self.dragVibeView.hidden = !enable;
    if (!enable) {
        return;
    }
    if (self.dragVibeView) {
        return;
    }
    self.dragVibeView = [TTDragVibeView loadFromXib];
    self.dragVibeView.delegate = self;
    [self setupDragView];
}

- (NSAttributedString *)attributedStringForString:(NSString *)string {
    if (string && self.titleLabel) {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:@{NSForegroundColorAttributeName : self.titleLabel.textColor, NSFontAttributeName : self.titleLabel.font}];
        return [[NSAttributedString alloc] initWithString:string attributes:attributes];
    } else {
        return nil;
    }
}

- (void)setUserVibedCompany:(BOOL)userVibed {

}

- (void)setUserVibedStory:(BOOL)userVibed {
    [self.dragVibeView setUserVibed:userVibed];
}

- (void)setupDragView {
    [self.contentView addSubview:self.dragVibeView];
    UIView *parent = self.contentView;
    UIView *child = self.dragVibeView;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];

    [parent layoutIfNeeded];
    
    [self.dragVibeView setCurrentCompany:self.company];
}

#pragma mark Interface actions

- (IBAction)commentButtonPressed:(id)sender {
    [self.delegate commentButtonActionOnStoryFeedCell:self];
}

- (IBAction)shareButtonPressed:(id)sender {
    [self.delegate shareButtonActionOnStoryFeedCell:self];
}

- (IBAction)editButtonPressed:(id)sender {
    [self.delegate editButtonActionOnStoryFeedCell:self];
}

- (IBAction)deleteButtonPressed:(id)sender {
    [self.delegate deleteButtonActionOnStoryFeedCell:self];
}

#pragma mark TTDragVibeView Delegate

- (void)willBeginDraggingOnDragVibeView:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willBeginDraggingOnStoryFeedTableViewCell:)]) {
        [self.delegate willBeginDraggingOnStoryFeedTableViewCell:self];
    }
}

- (void)willEndDraggingOnDragVibeView:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willEndDraggingOnStoryFeedTableViewCell:)]) {
        [self.delegate willEndDraggingOnStoryFeedTableViewCell:self];
    }
}

- (void)unlikeVibeOnDragView:(TTDragVibeView *)cell {

}

- (void)didHideDragView:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideDragView)]) {
        [self.delegate didHideDragView];
    }
}

- (void)vibeOnDragVibeView:(TTDragVibeView *)cell completion:(SimpleCompletionBlock)completion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(vibeOnStoryFeedTableViewCell:completion:)]) {
        [self.delegate vibeOnStoryFeedTableViewCell:self completion:completion];
    }
}

- (void)signupOnDragVibeView:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signupOnStoryFeedTableViewCell:)]) {
        [self.delegate signupOnStoryFeedTableViewCell:self];
    }
}

- (void)profileOnDragVibeView:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileOnStoryFeedTableViewCell:)]) {
        [self.delegate profileOnStoryFeedTableViewCell:self];
    }
}

@end
