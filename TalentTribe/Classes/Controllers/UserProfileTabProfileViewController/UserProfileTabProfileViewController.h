//
//  UserProfileTabProfileViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileTabViewController.h"

@class UserProfileTabProfileViewController;

@protocol UserProfileTabProfileViewControllerDelegate <NSObject>

- (void)profileTabProfileViewController:(UserProfileTabProfileViewController *)controller shouldChangeSaveButtonState:(BOOL)hidden;
- (void)profileTabProfileViewController:(UserProfileTabProfileViewController *)controller reloadUserState:(BOOL)reloadUser;
- (void)moveAwayFromProfileTabProfileViewController:(UserProfileTabProfileViewController *)controller;
- (void)cancelMoveAwayFromProfileTabProfileViewController:(UserProfileTabProfileViewController *)controller;
- (void)reloadUserOnProfileTabProfileViewController:(UserProfileTabProfileViewController *)controller;

@end

@interface UserProfileTabProfileViewController : UserProfileTabViewController

@property (nonatomic, weak) id <UserProfileTabProfileViewControllerDelegate> delegate;

@property (nonatomic, strong) User *tempUser;

@property BOOL scrollToEmptyField;

- (BOOL)handleMoveAwayFromController;
- (BOOL)handleMoveAwayFromControllerOnSlide;

- (void)saveButtonPressed;

@end
