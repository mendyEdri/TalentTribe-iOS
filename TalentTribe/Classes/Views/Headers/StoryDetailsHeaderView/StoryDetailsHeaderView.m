//
//  StoryDetailsHeaderView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsHeaderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface StoryDetailsHeaderView ()

@end

@implementation StoryDetailsHeaderView

#pragma mark View lifeCycle

- (void)awakeFromNib {
    [super awakeFromNib];
    self.authorImageView.layer.cornerRadius = CGRectGetWidth(self.authorImageView.bounds)/2;
    self.authorImageView.clipsToBounds = YES;
    self.authorImageView.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark Custom setters

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title.length ? title : nil;
}

- (void)setOccupation:(NSString *)occupation {
    self.authorOccupation.text = occupation.length ? occupation : nil;
}

- (void)setAuthor:(NSString *)author date:(NSDate *)date {
    
}

- (void)setAuthor:(NSString *)author highlight:(NSString *)highlight {
    if (author && highlight) {
        NSMutableAttributedString *attributedString = [self attributedStringForString:author highlight:highlight];
        self.authorLabel.attributedText = attributedString;
        self.authorContainer.hidden = NO;
        self.authorContainerHeight.constant = [StoryDetailsHeaderView contentBottomMargin];
    } else {
        self.authorLabel.attributedText = nil;
        self.authorContainer.hidden = YES;
        self.authorContainerHeight.constant = 0.0f;
    }
    [self layoutIfNeeded];
}

- (void)setAuthorImageURL:(NSString *)imageURL {
    if (imageURL) {
        [self.authorImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    } else {
        self.authorImageView.image = [UIImage imageNamed:@"avatar_story"];
    }
}

- (NSMutableAttributedString *)attributedStringForString:(NSString *)string highlight:(NSString *)highlight {
    return [TTUtils attributedStringForString:string highlight:highlight highlightedColor:UIColorFromRGB(0x8d8d8d) defaultColor:UIColorFromRGB(0x8d8d8d)];
}

#pragma mark Layout constants

+ (CGFloat)heightForTitle:(NSString *)title author:(NSString *)author size:(CGFloat)width {
    CGFloat titleHeight = ceil([title boundingRectWithSize:CGSizeMake(width - [self contentLeftMargin] - [self contentRightMargin], CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[self font]} context:nil].size.height);
    if (title.length && author.length) {
        return titleHeight + [self contentTopMargin] + [self contentBottomMargin] + 20;
    } else {
        if (title.length) {
            return titleHeight;
        } else if (author.length) {
            return [self contentBottomMargin];
        } else {
            return 0.0f;
        }
    }
}

+ (CGFloat)contentTopMargin {
    return 0.0f;
}

+ (CGFloat)contentBottomMargin {
    return 0.0f;
}

+ (CGFloat)contentLeftMargin {
    return 15.0f;
}

+ (CGFloat)contentRightMargin {
    return 15.0f;
}

+ (UIFont *)font {
    return [UIFont fontWithName:@"TitilliumWeb-Regular" size:25.0f];
}

@end
