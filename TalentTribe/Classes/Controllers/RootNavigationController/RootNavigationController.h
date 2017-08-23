//
//  RootNavigationController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootNavigationController : UINavigationController

- (void)moveToLoginScreen:(BOOL)animated;
- (void)moveToTabBar:(BOOL)animated;

@end
