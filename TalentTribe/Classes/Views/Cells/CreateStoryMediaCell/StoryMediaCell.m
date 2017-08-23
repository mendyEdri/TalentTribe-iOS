//
//  StoryMediaCell.m
//  TalentTribe
//
//  Created by Asi Givati on 11/3/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "StoryMediaCell.h"
#import "GeneralMethods.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

@interface StoryMediaCell()

@property UIImage *image;
@property NSURL *url;
@property BOOL isMediaFromWeb;

@end

@implementation StoryMediaCell

-(void)setViews
{
    [self setBackgroundImageView];
}

-(void)deallocCell
{
    self.url = nil;
    self.isVideo = NO;
    self.image = nil;
    [self.backgroundImg removeFromSuperview];
    self.backgroundImg.image = nil;
    self.backgroundImg = nil;
    self.isMediaFromWeb = nil;
    [self dealloceTTPlayer];
}

- (void)setupWithAttachObj:(NSDictionary *)dict
{
    self.url = dict[@"url"];
    self.isMediaFromWeb = [[self.url absoluteString] containsString:@"https://"];
    
    self.isVideo = [dict[@"isVideo"]boolValue];
    if (self.isVideo)
    {
        [self handleVideoFile:dict];
    }
    else // image
    {
        [self handleImageFile:dict];
    }
}

-(void)handleImageFile:(NSDictionary *)dict
{
    if (self.ttPlayer)
    {
        [self dealloceTTPlayer];
    }
    
    if (self.isMediaFromWeb)
    {
        [self.backgroundImg sd_setImageWithURL:self.url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
                self.image = [GeneralMethods centerMaxSquareImageByCroppingImage:image];
                [self.backgroundImg setImage:self.image];
        }];
    }
    else
    {
        [self setBackgroundImage:dict[@"image"]];
    }
}

-(void)dealloceTTPlayer
{
    if (self.ttPlayer)
    {
        [self.ttPlayer deallocPlayer];
        [self.ttPlayer removeFromSuperview];
        self.ttPlayer = nil;
    }
}

-(void)setBackgroundImage:(UIImage *)image
{
    self.image = [GeneralMethods centerMaxSquareImageByCroppingImage:image];
    [self.backgroundImg setImage:self.image];
}

-(void)playVideo
{
    if (self.isVideo && self.ttPlayer)
    {
        [self.ttPlayer play];
    }
}

-(void)stopVideo
{
    if (self.isVideo && self.ttPlayer)
    {
        [self.ttPlayer stop];
    }
}

-(void)playerDidSetNewThumbnailImage:(UIImage *)image
{
    [self setBackgroundImage:image];
}

-(void)handleVideoFile:(NSDictionary *)dict
{
    self.ttPlayer = [[TT_AVPlayer alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) filePath:self.url autoPlay:NO delegate:self addToView:self.contentView];
    self.ttPlayer.parent = (UICollectionViewCell *)self;
}

-(void)prepareForCellDelete
{
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [whiteView setAlpha:0.6];
    [self.contentView addSubview:whiteView];
    
    [UIView animateWithDuration:0.4 animations:^
    {
        [whiteView setAlpha:0];
    }
    completion:^(BOOL finished)
    {
        [whiteView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(storyMediaCellDidFinishDeleteAnimation:)])
        {
            [self.delegate storyMediaCellDidFinishDeleteAnimation:self];
        }
    }];
}

-(void)setBackgroundImageView
{
    if (!self.backgroundImg)
    {
        self.backgroundImg = [[UIImageView alloc]init];
        [self.backgroundImg setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
        self.backgroundImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.backgroundImg];
    }
}

@end
