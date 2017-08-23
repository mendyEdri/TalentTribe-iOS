//
//  CompanyProfileHeaderView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/11/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGradientHandler.h"

@interface CompanyProfileHeaderView : TTCustomGradientView

@property (nonatomic, weak) IBOutlet UIImageView *companyImageView;
@property (nonatomic, weak) IBOutlet UILabel *companyLabel;

@property (nonatomic) CGFloat progress;

- (void)setProgress:(CGFloat)progress withAnimationDuration:(CGFloat)duration;

- (void)setCompanyTitle:(NSString *)title;

@end
