//
//  StoryFeedJoinCompanyCollectionViewCell.m
//  TalentTribe
//
//  Created by Mendy on 14/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "StoryFeedJoinCompanyCollectionViewCell.h"

@interface StoryFeedJoinCompanyCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *pingButton;
@end

@implementation StoryFeedJoinCompanyCollectionViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    self.pingButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.pingButton.layer.borderWidth = 1.0;
    self.pingButton.layer.cornerRadius = CGRectGetHeight(self.pingButton.bounds)/2;
}

@end
