//
//  SearchResultStoryTableViewCell.m
//  TalentTribe
//
//  Created by Mendy on 09/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "SearchResultStoryTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SearchResultStoryTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *storyImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint;
@end

@implementation SearchResultStoryTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setStory:(Story *)story {
    if (!story || ![story isKindOfClass:[Story class]]) {
        return;
    }
    self.title.text = story.storyTitle;
    self.content.text = story.storyContent;
    [self.storyImageView sd_setImageWithURL:[NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage] ? [story.storyImages.firstObject objectForKeyOrNil:kRegularImage] : story.videoThumbnailLink]];
}

+ (CGFloat)topAndBottomSpace {
    return 26;
}

+ (CGFloat)sideSpaces {
    return 109;
}

@end
