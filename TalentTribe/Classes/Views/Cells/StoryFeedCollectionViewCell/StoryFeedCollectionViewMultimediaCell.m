//
//  StoryFeedCollectionViewMultimediaCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedCollectionViewMultimediaCell.h"
#import <JTMaterialSpinner/JTMaterialSpinner.h>
#import "LinedTextView.h"
#import "AsyncVideoDisplay.h"
#import "TTPlayerItem.h"
#import "VideoControllersView.h"

@interface StoryFeedCollectionViewMultimediaCell ()

@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, retain) NSDate *start;
@property (nonatomic, assign) CMTime currentTime;
@property (weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL forcePlay;
@property (nonatomic, assign) BOOL isPlaying;
//@property (nonatomic, strong) AVPlayerItem *item;
@end

@implementation StoryFeedCollectionViewMultimediaCell

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isPlaying = NO;
        self.forcePlay = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
   // [self.blackoutGradientView setHidden:YES];
    [self setNeedsDisplay];
    
    self.spinnerView.circleLayer.lineWidth = 2.0;
    //self.spinnerView.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.indicator = [[UIActivityIndicatorView alloc] init];
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.indicator.frame = self.spinnerView.bounds;
    [self.spinnerView addSubview:self.indicator];
    [self animateView:NO];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avPlayerLayer removeFromSuperlayer];
    
    self.currentTime = kCMTimeZero;
    [self.currentPlayer.currentItem seekToTime:kCMTimeZero];
    [self.currentPlayer pause];
    [self animateView:NO];
    self.forcePause = NO;
}

- (void)cellWillAppear {
    //AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:self.urlString] options:nil];
}

- (void)startVideo {
    self.currentPlayer.muted = [DataManager sharedManager].isMuted;
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.currentPlayer];
    self.avPlayerLayer.drawsAsynchronously = YES;
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.avPlayerLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
    self.avPlayerLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    [self.containerView.layer insertSublayer:self.avPlayerLayer above:self.backgroundImageView.layer];

    
    [[DataManager sharedManager].videoController playButtonStatePlaying:self.currentPlayer.rate];
    self.playButton.hidden = YES;
    [self animateView:YES];
    
    self.repeat = YES;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatEverySecondOnMain) userInfo:nil repeats:YES];
        [self.timer fire];
    }
}

- (void)repeatEverySecondOnMain {
    if (!self.repeat) {
        //DLog(@"Not Repeating");
        [self animateView:NO];
        self.playButton.hidden = NO;
        return;
    }
    
    if (self.forcePause) {
        return;
    }
    
    if (self.multimediaCellDelegate && [self.multimediaCellDelegate respondsToSelector:@selector(timeUpdated:)]) {
        NSTimeInterval time = CMTimeGetSeconds(self.currentPlayer.currentTime);
        [self.multimediaCellDelegate timeUpdated:time];
    }
  
    
    NSTimeInterval currentTime = CMTimeGetSeconds(self.currentPlayer.currentItem.currentTime);
    NSTimeInterval completeDuration = CMTimeGetSeconds(self.currentPlayer.currentItem.duration);
    if (roundf(currentTime) == roundf(completeDuration)) {
        [self videoEnded:nil];
        return;
    }
    DLog(@"available %f", roundf([self availableDurationForPlayerItem:self.currentPlayer.currentItem]) - roundf(currentTime));
    if (roundf([self availableDurationForPlayerItem:self.currentPlayer.currentItem]) - roundf(currentTime) >= 1.8 || roundf([self availableDurationForPlayerItem:self.currentPlayer.currentItem]) == roundf(completeDuration) || roundf([self availableDurationForPlayerItem:self.currentPlayer.currentItem]) >= (roundf(completeDuration) - 1)) {
        if (!self.isPlaying) {
            [self.currentPlayer play];
            self.playButton.hidden = YES;
            self.isPlaying = YES;
            self.forcePlay = NO;
        }
        
        [self animateView:!self.currentPlayer.currentItem.isPlaybackLikelyToKeepUp];
        [[DataManager sharedManager].videoController videoBuffering:!self.currentPlayer.currentItem.isPlaybackLikelyToKeepUp];
        [[DataManager sharedManager].videoController playButtonStatePlaying:self.currentPlayer.currentItem.isPlaybackLikelyToKeepUp];
    } else {
        if (self.isPlaying) {
            [self.currentPlayer pause];
            self.isPlaying = NO;
        }
        [[DataManager sharedManager].videoController videoBuffering:!self.forcePause];
        [[DataManager sharedManager].videoController playButtonStatePlaying:!self.forcePause];
        [self animateView:!self.forcePause];
        self.playButton.hidden = !self.forcePause;
    }
    
    
    DLog(@"Normal Repeat %@", self.urlString);
    /*
    __weak StoryFeedCollectionViewMultimediaCell *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DLog(@"Normal Repeat %@", self.urlString);
        [self repeatEverySecondOnMain];
    });
     */
}

- (void)animateView:(BOOL)animate {
    if (!animate) {
        [self.indicator stopAnimating];
        return;
    }
    
    if (!self.spinnerView.isAnimating) {
        [self.indicator startAnimating];
    }
}

- (void)videoFrameShot {
    if (self.avPlayerLayer.player.rate == 0) {
        return;
    }
    [self loadImageWithCompletion:^(id result, NSError *error) {
        if (![result isKindOfClass:[UIImage class]]) {
            return ;
        }
        self.backgroundImageView.image = result;
    }];
}

#pragma mark Interface actions

- (IBAction)playPressed:(UIButton *)sender {
}

- (void)playerLayerWithPlayer:(AVPlayer *)avPlayer withCompletion:(SimpleResultBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        avPlayerLayer.drawsAsynchronously = YES;
        avPlayerLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
        avPlayerLayer.backgroundColor = [UIColor clearColor].CGColor;
        if (completion) {
            completion(avPlayerLayer, nil);
        }
    });
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avPlayerLayer.frame = self.containerView.bounds;
}

- (void)playVideo:(BOOL)play {
    if (play) {
//        [self.currentPlayer play];
        self.isPlaying = YES;
        self.forcePlay = NO;
        [self animateView:!self.currentPlayer.currentItem.isPlaybackLikelyToKeepUp];
        [[DataManager sharedManager].videoController videoBuffering:!self.currentPlayer.currentItem.isPlaybackLikelyToKeepUp];
        [[DataManager sharedManager].videoController playButtonStatePlaying:!self.currentPlayer.currentItem.isPlaybackLikelyToKeepUp];
        return;
    }
    [self.currentPlayer pause];
    [[DataManager sharedManager].videoController videoBuffering:!self.forcePause];
    [[DataManager sharedManager].videoController playButtonStatePlaying:!self.forcePause];
    self.isPlaying = NO;
    [self animateView:!self.forcePause];
    self.playButton.hidden = !self.forcePause;
}

#pragma mark Controls

- (void)play {
    @synchronized(self) {
        if (!self.isPlaying || self.forcePlay) {
            self.isPlaying = YES;
            self.forcePlay = NO;
            [self animateView:NO];
        }
    }
}

- (void)pause {
    @synchronized(self) {
        if (self.isPlaying) {
            self.isPlaying = NO;
            [self animateView:YES];
        }
    }
}

- (void)playing:(BOOL)play {
    @synchronized(self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (play) {
                self.isPlaying = YES;
                self.forcePlay = NO;
                [self animateView:NO];
                [self.currentPlayer play];
            } else {
                self.isPlaying = NO;
                [self animateView:YES];
                self.playButton.hidden = YES;
                [self.currentPlayer pause];
            }
        });
    }
}

- (void)toggleVideo:(BOOL)play {
    if ([DataManager sharedManager].isScrolling) {
        return;
    }
    
    if (self.forcePause && play) {
        self.forcePause = !play;
        self.repeat = YES;
        [self repeatEverySecondOnMain];
    }
    
    self.forcePause = !play;
    play ? [self.currentPlayer play] : [self.currentPlayer pause];
    self.playButton.hidden = play;
}

- (void)didEndDisplay {
    self.playButton.hidden = NO;
    if (CMTIME_IS_VALID(self.currentTime)) {
        self.currentTime = kCMTimeZero;
    }
    
    [self.timer invalidate];
    self.timer = nil;

    [self.currentPlayer seekToTime:kCMTimeZero];
    [self.currentPlayer pause];
    [self.avPlayerLayer removeFromSuperlayer];
    self.currentPlayer = nil;
    
    self.repeat = NO;
    //DLog(@"didEndDisplay");
    [self animateView:NO];
    //[self toggleVideo:NO];
}

- (void)dealloc {
    [self.avPlayerLayer removeFromSuperlayer];
    
    self.currentPlayer = nil;
    self.avPlayerLayer = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.repeat = NO;
}

- (UIImage *)snapshotImageFromPlayer:(AVPlayer *)player {
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:self.currentPlayer.currentItem.asset];
    NSError *error;
    CGImageRef cgIm = [generate copyCGImageAtTime:player.currentTime actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:cgIm];
    return image;
}

- (void)loadImageWithCompletion:(SimpleResultBlock)completion {
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:self.currentPlayer.currentItem.asset];
    [generate generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:self.currentPlayer.currentItem.currentTime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (completion) {
            self.currentTime = actualTime;
            completion([[UIImage alloc] initWithCGImage:image], error);
        }
    }];
}

- (NSURL *)urlFromPlayer:(AVPlayer *)player{
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [(AVURLAsset *)currentPlayerAsset URL];
}

#pragma mark - New Logic 

- (void)setActive {
    [self animateView:YES];
    self.playButton.hidden = YES;
    self.repeat = YES;
    
    self.forcePause = NO;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:self.urlString] options:nil];
    self.currentPlayer = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
    [self startVideo];
}

- (void)muteVideo:(BOOL)mute {
    self.currentPlayer.muted = mute;
}

- (void)shouldStartVideoWithPlayerItem:(AVPlayerItem *)item completion:(SimpleCompletionBlock)completion {
    if (self.forcePause) {
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    
    NSTimeInterval currentTime = CMTimeGetSeconds(item.currentTime);
    NSTimeInterval completeDuration = CMTimeGetSeconds(item.duration);
    if (roundf(currentTime) == roundf(completeDuration)) {
        [self videoEnded:nil];
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    //DLog(@"available %f", roundf([self availableDurationForPlayerItem:item]) - roundf(currentTime));
    if (roundf([self availableDurationForPlayerItem:item]) - roundf(currentTime) >= 1.8 || roundf([self availableDurationForPlayerItem:item]) == roundf(completeDuration) || roundf([self availableDurationForPlayerItem:item]) >= (roundf(completeDuration) - 1)) {
        if (completion) {
            completion(YES, nil);
        }
    } else {
        if (completion) {
            completion(NO, nil);
        }
    }
}

- (void)videoEnded:(NSNotification *)notification {
    __weak StoryFeedCollectionViewMultimediaCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.currentPlayer seekToTime:kCMTimeZero];
        [weakSelf.currentPlayer play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self repeatEverySecondOnMain];
        });
    });
}

- (NSURL *)urlFromPlayerItem:(AVPlayerItem *)item {
    AVAsset *currentPlayerAsset = item.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [(AVURLAsset *)currentPlayerAsset URL];
}

- (NSTimeInterval)availableDurationForPlayerItem:(AVPlayerItem *)item {
    NSArray *loadedTimeRanges = [item loadedTimeRanges];
    if (loadedTimeRanges.count == 0) {
        return 0.0;
    }
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
    Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

@end
