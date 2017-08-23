//
//  CreateGalleryCollectionViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateGalleryCollectionViewCell.h"

@interface CreateGalleryCollectionViewCell ()

@property UIImageView *videoSignImageView;

@end

@implementation CreateGalleryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionView.layer.borderColor = UIColorFromRGB(0x13AFED).CGColor;
    self.selectionView.layer.borderWidth = 5.0f;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectionView.hidden = !selected;
}


-(void)videoSignNeeded:(BOOL)videoSign
{
    if (videoSign)
    {
        CGFloat borderSize = CGRectGetWidth(self.frame) * 0.01;
        CGFloat xPos = borderSize;
        CGFloat size = CGRectGetWidth(self.frame) * 0.2;
        CGFloat yPos = CGRectGetHeight(self.frame) - size - borderSize;
        CGRect frame = CGRectMake(xPos, yPos, size, size);
        
        if (!self.videoSignImageView) {
           self.videoSignImageView = [[UIImageView alloc]initWithFrame:frame];
        }
        [self.videoSignImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.videoSignImageView setImage:[UIImage imageNamed:@"play"]];
        [self.videoSignImageView removeFromSuperview];
        [self.contentView addSubview:self.videoSignImageView];
    }
    else
    {
        [self.videoSignImageView removeFromSuperview];
    }
}

@end
