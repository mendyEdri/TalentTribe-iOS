//
//  PositionViewController.h
//  TalentTribe
//
//  Created by Mendy on 01/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Position.h"
#import "Company.h"

@interface PositionViewController : UIViewController
@property (strong, nonatomic) Position *position;
@property (strong, nonatomic) Company *company;
@end
