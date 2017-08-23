//
//  UserProfileHeaderView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGradientHandler.h"
#import "TTRoundButton.h"

@class UserProfileHeaderView;

@protocol UserProfileHeaderViewDelegate <NSObject>

- (void)backButtonPressedOnProfileHeaderView:(UserProfileHeaderView *)headerView;
- (void)nextButtonPressedOnProfileHeaderView:(UserProfileHeaderView *)headerView;
- (void)imageButtonPressedOnProfileHeaderView:(UserProfileHeaderView *)headerView;

- (void)userFirstNameUpdatedOnProfileHeaderView:(UserProfileHeaderView *)headerView;
- (void)userLastNameUpdatedOnProfileHeaderView:(UserProfileHeaderView *)headerView;

@end

@interface UserProfileHeaderView : TTCustomGradientView

@property (nonatomic, weak) id <UserProfileHeaderViewDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIView *nameContainer;
@property (nonatomic, weak) IBOutlet UIView *inputContainer;

@property (nonatomic, weak) IBOutlet UILabel *animationTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *userTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *userPositionLabel;

@property (nonatomic, weak) IBOutlet TTRoundButton *userImageButton;

@property (nonatomic, weak) IBOutlet UITextField *inputFirstNameField;
@property (nonatomic, weak) IBOutlet UITextField *inputLastNameField;

@property (nonatomic, weak) IBOutlet UIView *inputFirstNameUnderline;
@property (nonatomic, weak) IBOutlet UIView *inputLastNameUnderline;

@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property CGFloat maxHeight;
@property CGFloat minHeight;

@property (nonatomic) CGFloat progress;

- (void)setProgress:(CGFloat)progress withAnimationDuration:(CGFloat)duration;

@end
