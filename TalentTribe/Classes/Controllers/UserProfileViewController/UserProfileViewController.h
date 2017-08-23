//
//  UserProfileViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/23/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfileHeaderViewController.h"

@interface UserProfileViewController : UserProfileHeaderViewController

- (void)handleTabChanged:(NSNumber *)tabChanged;

- (void)setScrollToEmptyField:(BOOL)scroll;

@end
