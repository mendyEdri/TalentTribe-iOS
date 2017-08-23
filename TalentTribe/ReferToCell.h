//
//  ReferToCell.h
//  TalentTribe
//
//  Created by Yagil Cohen on 6/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReferToCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblCompanyName;
@property (weak, nonatomic) IBOutlet UIImageView *imgCompanyLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imgCheckmark;

- (void) fillCellWithData: (id) data;

@end
