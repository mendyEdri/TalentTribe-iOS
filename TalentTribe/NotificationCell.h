//
//  NotificationCell.h
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
+ (NSString *)cellIdentifier;
- (void)setupWithNotification:(Notification *)model;

@end
