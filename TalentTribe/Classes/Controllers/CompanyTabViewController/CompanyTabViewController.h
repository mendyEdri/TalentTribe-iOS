//
//  CompanyTabViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/26/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTScrollableHeaderViewController.h"
#import "Company.h"

@interface CompanyTabViewController : TTScrollableHeaderViewController

@property (nonatomic, weak) Company *company;
@property (nonatomic, assign) BOOL isProfileTab;

- (void)reloadData;

@end
