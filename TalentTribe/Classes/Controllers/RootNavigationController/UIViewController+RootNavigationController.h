//
//  UIViewController+RootNavigationController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/13/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootNavigationController;

@interface UIViewController (RootNavigationController)

@property (nonatomic, weak, readonly) RootNavigationController *rootNavigationController;

@end
