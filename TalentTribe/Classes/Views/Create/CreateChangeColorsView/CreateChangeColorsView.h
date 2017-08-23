//
//  CreateChangeColorsView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/19/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateChangeColorsView : UIView

@property BOOL visible;

- (void)showViewAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)hideViewAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end
