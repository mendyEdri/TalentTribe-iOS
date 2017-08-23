//
//  TT_AVPlayer.m
//  TalentTribe
//
//  Created by Asi Givati on 11/12/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "TT_AVPlayer.h"
#import "GeneralMethods.h"
#import <MediaPlayer/MediaPlayer.h>

static void *AVPlayerStatusObservationContext = &AVPlayerStatusObservationContext;

@interface TT_AVPlayer()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) UIImageView *playImageIcon;
@property (nonatomic, strong) AVAsset *currentAsset;
@property (nonatomic, strong) NSString *filePath;
@end

@implementation TT_AVPlayer


-(id)initWithFrame:(CGRect)frame filePath:(NSURL *)filePath autoPlay:(BOOL)autoPlay delegate:(id)delegate addToView:(UIView *)superView
{
    if (self && superView)
    {
        [self removeFromSuperview];
    }
    
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor blackColor]];
        
        if (filePath == nil)
        {
            return self;
        }
        
        self.delegate = delegate;
        self.filePath = [filePath absoluteString];
        [self setThumbnailImageView];
        [self updateThumbnailImageView]; // include filter filePath inside
        [self setPlayButton];
        [self setNotifications];
    }
    
    if (autoPlay)
    {
        [self play];
    }
    
    if (superView)
    {
        [superView addSubview:self];
    }
    
    return self;
}

-(void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notif
{
    if ([self isPlaying])
    {
        [self stop];
    }
}

-(void)setThumbnailImageView
{
    self.thumbnailImageview = [UIImageView new];
    [self.thumbnailImageview setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.thumbnailImageview];
    [self updateThumbnailImageView];
}

-(void)updateThumbnailImageView
{
    [self.thumbnailImageview setImage:[self generateThumbImage]];
}

-(void)filterFilePath:(NSString *)path
{
    if ([GeneralMethods theWord:@"file:///" existInTheString:path caseSensitive:NO])
    {
        self.filePath = [self.filePath substringFromIndex:7];
    }
}

-(void)deallocPlayer
{
    [self stop];
    [self clearAVPlayerObservers];
    [self.thumbnailImageview removeFromSuperview];
    self.thumbnailImageview = nil;
    self.playerItem = nil;
    self.avPlayer = nil;
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer = nil;
    [self.playImageIcon removeFromSuperview];
    self.playImageIcon = nil;
    self.currentAsset = nil;
    self.filePath = nil;
    self.delegate = nil;
    self.preventPlayByTouch = NO;
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self isPlaying] == NO && self.preventPlayByTouch == NO)
    {
        [self play];
    }
}

-(BOOL)isPlaying
{
    return (self && (self.avPlayer.rate > 0 && !self.avPlayer.error));
}

-(BOOL)fileLoadedWithSuccess
{
    if (self.filePath && self.filePath.length < 1)
    {
        return NO;
    }
    
    if (self.playerItem)
    {
        [self.avPlayerLayer removeFromSuperlayer];
    }
    
    self.currentAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.filePath]];
    
    if ([self isVideoFromLibrary] || [self isVideoFromWeb])
    {
        NSURL *myMovieURL = [NSURL URLWithString:self.filePath];
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:myMovieURL options:nil];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
    }
    else
    {
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.currentAsset];
    }

    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayerLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [self.layer addSublayer:self.avPlayerLayer];
    
    return YES;
}

-(BOOL)isVideoFromLibrary
{
    return ([self.filePath containsString:@"assets-library://"]);
}

-(BOOL)isVideoFromWeb
{
    return ([self.filePath containsString:@"https://"] || [self.filePath containsString:@"http://"]);
}


-(void)playFilePath:(NSString *)newPath
{
    self.filePath = newPath;
    [self updateThumbnailImageView]; // include filter filePath inside
    [self play];
}


-(void)play
{
    if (self.avPlayer != nil)
    {
        [self clearAVPlayerObservers];
    }
    
    if ([self fileLoadedWithSuccess])
    {
        [self.avPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerStatusObservationContext];
    }
    
    if ([GeneralMethods fileExistAtPath:self.filePath])
    {
        DLog(@"Video Exist");
    }
    else
    {
        DLog(@"Video Not Exit")
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.avPlayer && [keyPath isEqualToString:@"status"])
    {
        if (self.avPlayer.status == AVPlayerStatusReadyToPlay)
        {
            self.avPlayerLayer.hidden = NO;
            [self showPlayButton:NO];
            [self.avPlayer play];
            [self clearAVPlayerObservers];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(capturedVideoDidPlayToEndTime) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
            
            if ([self.delegate respondsToSelector:@selector(playerDidStartPlayingVideo:)])
            {
                [self.delegate playerDidStartPlayingVideo:self];
            }
        }
    }
}

-(void)clearAVPlayerObservers
{
    @try
    {
        [self.avPlayer removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    }
    @catch (NSException *exception)
    {
        
    }
}

-(void)removeFromSuperview
{
    [self clearAVPlayerObservers];
    [super removeFromSuperview];
}

-(UIImage *)generateThumbImage
{
    [self filterFilePath:self.filePath];

    UIImage *thumbnail = nil;
    
    NSURL *url;
    
    if ([self isVideoFromLibrary] || [self isVideoFromWeb])
    {
        url = [NSURL URLWithString:self.filePath];
    }
    else
    {
        url = [NSURL fileURLWithPath:self.filePath];
    }
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    CMTime time = [asset duration];
    time.value = 0;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    thumbnail = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    if ([self.delegate respondsToSelector:@selector(playerDidSetNewThumbnailImage:)])
    {
        [self.delegate playerDidSetNewThumbnailImage:thumbnail];
    }

    return thumbnail;
}


-(void)stop
{
    if (self.avPlayer.rate == 1.0) // is Playing
    {
        [self clearAVPlayerObservers];
        [self.avPlayer pause];
        [self showPlayButton:YES];
        
        Float64 seconds = 0.0f;
        CMTime targetTime = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
        [self.avPlayer seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

-(void)capturedVideoDidPlayToEndTime
{
    [self.avPlayerLayer setHidden:YES];
//    [self clearAVPlayerObservers];
    [self showPlayButton:YES];
    if ([self.delegate respondsToSelector:@selector(playerDidPlayToEndTime:)])
    {
        [self.delegate playerDidPlayToEndTime:self];
    }
}

//-(void)showPauseButton:(BOOL)show
//{
//    [self handleShowButtons:show withTitle:@"pause"];
//}

//-(void)showPlayImageIcon:(BOOL)show
//{
//    [self showPlayButton:YES];
//}

-(void)setPlayButton
{
    CGFloat size = CGRectGetWidth(self.frame) * 0.3;
    self.playImageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, size, size)];
    CGFloat point = CGRectGetWidth(self.frame) / 2;
    self.playImageIcon.center = CGPointMake(point, point);
    [self.playImageIcon setImage:[UIImage imageNamed:@"play"]];
    [self addSubview:self.playImageIcon];
}


-(void)showPlayButton:(BOOL)show
{
    CGFloat duration = 0.5;
    CGFloat alpha = 0;
    if (show)
    {
        alpha = 1;

    }
    
    [self bringSubviewToFront:self.playImageIcon];

    [UIView animateWithDuration:duration animations:^
     {
         [self.playImageIcon setAlpha:alpha];
     }];
}


@end
