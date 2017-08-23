//
//  StoryFeedCollectionViewLinkCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedCollectionViewLinkCell.h"
#import "TTGradientHandler.h"

@interface StoryFeedCollectionViewLinkCell ()

@property (nonatomic, weak) IBOutlet UILabel *dashLabel;

@end

@implementation StoryFeedCollectionViewLinkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dashLabel.attributedText = [[NSAttributedString alloc] initWithString:self.dashLabel.text attributes:@{NSFontAttributeName : self.dashLabel.font, NSForegroundColorAttributeName : self.dashLabel.textColor}];
}

@end
