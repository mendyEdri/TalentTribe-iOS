//
//  StoryFeedCollectionViewQuestionCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedCollectionViewQuestionCell.h"
#import "TTGradientHandler.h"

@interface StoryFeedCollectionViewQuestionCell ()

@property (nonatomic, weak) IBOutlet UILabel *dashLabel;

@end

@implementation StoryFeedCollectionViewQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dashLabel.attributedText = [[NSAttributedString alloc] initWithString:self.dashLabel.text attributes:@{NSFontAttributeName : self.dashLabel.font, NSForegroundColorAttributeName : self.dashLabel.textColor}];
//    [self.blackoutGradientView setHidden:YES];
}

- (void)setIndex:(NSInteger)index {
    [self.gradientView setGradientType:(TTGradientType)(index % gradientTypeCount)];
}

@end
