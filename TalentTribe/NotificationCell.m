//
//  NotificationCell.m
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "NotificationCell.h"
#import "NSDate+TimeAgo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation NotificationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

+ (NSString *)cellIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setupWithNotification:(Notification *)model
{
    self.titleLabel.text = model.companyName;
    self.descriptionLabel.text = model.notificationContent;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.companyLogo] placeholderImage:[UIImage imageNamed:@"logo"]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[model.notificationTime integerValue]/1000];
    self.dateLabel.text = [date timeAgo];
}

@end
