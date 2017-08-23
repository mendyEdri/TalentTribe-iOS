//
//  StoryFeedMultimediaTableViewCell.m
//  TalentTribe
//
//  Created by Mendy on 18/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "StoryFeedMultimediaTableViewCell.h"
#import "JTMaterialSpinner.h"

@interface StoryFeedMultimediaTableViewCell ()
@property (nonatomic, retain) AVPlayerItem *avPlayerItem;
@property (nonatomic, retain) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, retain) NSDate *start;
@property BOOL forcePlay;
@property BOOL isPlaying;
@property (weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@end

@implementation StoryFeedMultimediaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setNeedsDisplay];
    
    self.spinnerView.circleLayer.lineWidth = 2.0;
    self.spinnerView.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self animateView:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    self.backgroundImage.image = nil;
    [self animateView:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avPlayerLayer.frame = self.contentView.bounds;
}

- (void)animateView:(BOOL)animate {
    if (!animate) {
        [self.spinnerView endRefreshing];
        return;
    }
    [self.spinnerView beginRefreshing];
}


- (NSURL *)urlFromPlayer:(AVPlayer *)player {
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [(AVURLAsset *)currentPlayerAsset URL];
}

- (NSURL *)urlFromPlayerItem:(AVPlayerItem *)item {
    AVAsset *currentPlayerAsset = item.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [(AVURLAsset *)currentPlayerAsset URL];
}

- (void)playerLayerWithPlayer:(AVPlayer *)avPlayer withCompletion:(SimpleResultBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        avPlayerLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
        avPlayerLayer.backgroundColor = [UIColor clearColor].CGColor;
        if (completion) {
            completion(avPlayerLayer, nil);
        }
    });
}

#pragma mark Controls

- (void)play {
    @synchronized(self) {
        if (!self.isPlaying || self.forcePlay) {
            self.isPlaying = YES;
            self.forcePlay = NO;
            [self animateView:NO];
            if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
                //[self.avPlayer play];
            } else {
                //observe and wait for status to become active
            }
        }
    }
}

- (void)pause {
    @synchronized(self) {
        if (self.isPlaying) {
            self.isPlaying = NO;
            [self animateView:YES];
            [self.avPlayer pause];
        }
    }
}

- (void)playing:(BOOL)play {
    @synchronized(self) {
        if (play) {
            self.isPlaying = YES;
            self.forcePlay = NO;
            [self animateView:NO];
        } else {
            self.isPlaying = NO;
            [self animateView:YES];
        }
    }
}

- (void)didEndDisplay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.avPlayerLayer removeFromSuperlayer];
        [self.avPlayer seekToTime:kCMTimeZero];
    });
}

- (void)dealloc {
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer = nil;
    self.avPlayer = nil;
}

@end
