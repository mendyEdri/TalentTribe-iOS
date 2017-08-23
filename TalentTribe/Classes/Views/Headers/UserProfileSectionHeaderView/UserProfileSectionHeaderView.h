//
//  UserProfileSectionHeaderView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/7/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIButton *addButton;

@end
