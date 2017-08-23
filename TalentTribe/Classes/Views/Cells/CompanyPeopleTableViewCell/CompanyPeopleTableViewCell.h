//
//  CompanyPeopleTableViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRoundedBorderImageView.h"

@interface CompanyPeopleTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet TTRoundedBorderImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *occupationLabel;

@property (nonatomic, weak) IBOutlet UIImageView *storiesIconView;
@property (nonatomic, weak) IBOutlet UILabel *storiesLabel;

@end
