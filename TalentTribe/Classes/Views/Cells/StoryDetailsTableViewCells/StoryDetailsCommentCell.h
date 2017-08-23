//
//  StoryDetailsCommentCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsCell.h"

@interface StoryDetailsCommentCell : StoryDetailsCell

@property (nonatomic, weak) IBOutlet UIImageView *authorImageView;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentLabel;

@end
