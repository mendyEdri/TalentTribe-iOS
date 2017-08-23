//
//  UserProfileHeaderViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfileKeyboardObservingViewController.h"
#import "User.h"
#import "UserProfileHeaderView.h"
#import "UserProfileAccessoryView.h"

@interface UserProfileHeaderViewController : UserProfileKeyboardObservingViewController <UserProfileAccessoryViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *headerContainer;

@property (nonatomic, strong) UserProfileHeaderView *headerView;

@property (nonatomic, strong) User *tempUser;

@property BOOL reloadUser;

@property BOOL setupObservations;

- (void)updateUserProfileWithCompletionHandler:(SimpleCompletionBlock)completion;

- (void)setBackButtonHidden:(BOOL)hidden;

- (BOOL)canMoveAwayFromController;
- (BOOL)handleMoveAwayFromController;

- (BOOL)validateInput;
- (void)validateInputAndContinue:(BOOL)back;

- (void)updateSaveButtonState;

- (void)scrollToFirstEmptyField;
- (void)scrollToNextField;

- (void)moveToPreviousScreen;

- (void)endEditingView;

- (void)reloadHeaderData;

@end
