//
//  UIViewController+RootNavigationController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/13/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UIViewController+RootNavigationController.h"
#import "RootNavigationController.h"



@implementation UIViewController (RootNavigationController)

- (RootNavigationController *)rootNavigationController {
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[RootNavigationController class]]) {
            return (RootNavigationController *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

@end
