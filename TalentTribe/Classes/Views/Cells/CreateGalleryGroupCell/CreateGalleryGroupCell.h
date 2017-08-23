//
//  CreateGalleryGroupCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGalleryGroupCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *groupImageView;
@property (nonatomic, weak) IBOutlet UILabel *groupTitle;
@property (nonatomic, weak) IBOutlet UILabel *groupAssetsCount;

@end
