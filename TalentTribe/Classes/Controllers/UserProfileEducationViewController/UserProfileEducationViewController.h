//
//  UserProfileEducationViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/5/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileHeaderViewController.h"
#import "Education.h"

@class UserProfileEducationViewController;

@protocol UserProfileEducationViewControllerDelegate <NSObject>

- (void)educationViewController:(UserProfileEducationViewController *)controller replaceEducation:(Education *)oldEducation withEducation:(Education *)newEducation;
- (void)educationViewController:(UserProfileEducationViewController *)controller shouldUpdateEducations:(NSArray *)educations;

@end

@interface UserProfileEducationViewController : UserProfileHeaderViewController

@property (nonatomic, weak) id <UserProfileEducationViewControllerDelegate> delegate;

@property (nonatomic, weak) NSArray *positions;
@property (nonatomic, weak) Education *currentEducation;

@end
