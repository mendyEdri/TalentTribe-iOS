//
//  UserProfilePositionsViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileHeaderViewController.h"
#import "Position.h"

@class UserProfilePositionsViewController;

@protocol UserProfilePositionsViewControllerDelegate <NSObject>

- (void)positionsViewController:(UserProfilePositionsViewController *)controller replacePosition:(Position *)oldPosition withPosition:(Position *)newPosition;
- (void)positionsViewController:(UserProfilePositionsViewController *)controller shouldUpdatePositions:(NSArray *)positions;

@end

@interface UserProfilePositionsViewController : UserProfileHeaderViewController

@property (nonatomic, weak) id <UserProfilePositionsViewControllerDelegate> delegate;

@property (nonatomic, weak) Position *currentPosition;

@end
