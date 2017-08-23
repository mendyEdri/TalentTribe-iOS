//
//  StoryDetailsQuestionCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsCell.h"
#import "TTDynamicLabel.h"

@interface StoryDetailsQuestionCell : StoryDetailsCell

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *authorImageView;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;

@property (nonatomic, weak) IBOutlet TTDynamicLabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

- (void)setIndex:(NSInteger)index;

@end
