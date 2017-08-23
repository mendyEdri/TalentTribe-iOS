//
//  CompanyProfileMenuView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/10/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSlidingViewController.h"

@interface TTSlidingMenuView : UIView <TTSlidingView>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) BOOL selected;

- (id)initWithTitle:(NSString *)title;

@end
