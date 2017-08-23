//
//  AppDelegate.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APPDELEGATE_INSTANCE [AppDelegate appDelegate];

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (AppDelegate *)appDelegate;

@end

