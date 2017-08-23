//
//  WebLinkViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCustomViewController.h"

@interface WebLinkViewController : TTCustomViewController

@property (nonatomic, strong) NSURL *urlToOpen;
@property (nonatomic, strong) NSString *titleString;

@end
