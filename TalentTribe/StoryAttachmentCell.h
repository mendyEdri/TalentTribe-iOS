//
//  StoryAttachmentCell.h
//  TalentTribe
//
//  Created by Anton Vilimets on 7/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryAttachmentCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, copy) void (^closeHandler)(StoryAttachmentCell *cell);


- (void)setupWithAttachObj:(id)obj;

@end
