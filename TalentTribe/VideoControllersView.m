//
//  VideoControllersView.m
//  TalentTribe
//
//  Created by Mendy on 30/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "VideoControllersView.h"
#import "TT_Stopper.h"
#import "UIView+Additions.h"

@interface VideoControllersView ()
@property (assign, nonatomic) CGFloat volume;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) AVAudioSession *audioSession;
@property (nonatomic, weak) IBOutlet UIView *redLine;
@property (nonatomic, weak) IBOutlet UIView *bufferLine;
@property (weak, nonatomic) IBOutlet UIView *dragView;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet TT_Stopper *counterView;
@property (weak, nonatomic) IBOutlet TT_Stopper *counterDownView;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *pan;
@property (strong, nonatomic) TT_Stopper *stopper;
@property (weak, nonatomic) AVPlayer *currentPlayer;
@property (assign, nonatomic) BOOL repeat;
@end

@implementation VideoControllersView

+ (void)videoControllersViewWithCompletion:(SimpleResultBlock)completion {
    static VideoControllersView *videoControllers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoControllers = [VideoControllersView loadFromXib];
    });
    if (completion) {
        completion(videoControllers, nil);
    }
}

- (void)awakeFromNib {
    [self setColors:@[UIColorFromRGBA(0x000000, 0.16f), UIColorFromRGBA(0x000000, 0.66f), UIColorFromRGBA(0x000000, 0.96f)]]; //
    [self setLocations:@[@(0.0), @(0.4), @(1.0)]];
    [self commonInit];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;
}

- (instancetype)init {
    self = [super initWithColors:@[UIColorFromRGBA(0x000000, 0.36f), UIColorFromRGBA(0x000000, 0.96f)] locations:@[@(1.0), @(1.0)]];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithColors:(NSArray *)colors locations:(NSArray *)locations {
   self = [super initWithColors:colors locations:locations];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    CGFloat tabbarHeight = 44;
    self.frame = CGRectMake(0, CGRectGetWidth([UIScreen mainScreen].bounds) + 20, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - (CGRectGetWidth([UIScreen mainScreen].bounds) + 20 + tabbarHeight));
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gradientSwiped:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
    //[self addGestureRecognizer:swipe];
    self.hidden = YES;
    self.muted = YES;
    self.repeat = YES;
 
    [self.pan addTarget:self action:@selector(panSelector:)];
    self.dragView.layer.cornerRadius = CGRectGetWidth(self.dragView.bounds)/2;
}

- (void)observeVolumeChange {
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setActive:YES error:nil];
    [self.audioSession addObserver:self forKeyPath:@"outputVolume" options:0 context:(__bridge void * _Nullable)(self.audioSession)];
}

- (void)toggleVideoSound:(UIButton *)sender {
    [sender setSelected:!sender.selected];
}

- (void)gradientSwiped:(UISwipeGestureRecognizer *)swipe {
    DLog(@"Swiped");
    [self showVolumeGradientView:NO player:self.currentPlayer completion:nil];
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(videoControllersDidSwiped)]) {
        return;
    }
    [self.delegate videoControllersDidSwiped];
}

- (void)showVolumeGradientView:(BOOL)show player:(AVPlayer *)currentPlayer completion:(SimpleCompletionBlock)completion {
    self.currentPlayer = currentPlayer;
    
    show ? [self updateTime] : [self resetTime];
    if (show != self.hidden) {
        // dont repeat animation if not necessary
        return;
    }
    
    [UIView transitionWithView:self duration:show ? 0.26 : 0.2 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewKeyframeAnimationOptionAllowUserInteraction animations:^(void){
        [self setHidden:!show];
        self.statusBarView.backgroundColor = show ? [UIColor blackColor] : [UIColor colorWithRed:(0.0/255.0) green:(179.0/255.0) blue:(234.0/255.0) alpha:1.0];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(YES, nil);
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"outputVolume"] && self.isEnableVolumeObserver) {
        AVAudioSession *audioSession = (__bridge AVAudioSession *)(context);
        NSLog(@"volume changed! %f", audioSession.outputVolume);
        if (audioSession.outputVolume > self.volume || self.volume == 1.0) {
            // [self showVolumeGradientView:YES completion:nil];
        }
        [self showVolumeGradientView:YES player:self.currentPlayer completion:nil];
        self.volume = audioSession.outputVolume;
    }
}

- (void)videoBuffering:(BOOL)buffering {
    self.playButton.enabled = !buffering;
}

- (void)playButtonStatePlaying:(BOOL)playing {
    self.playButton.selected = !playing;
}

#pragma mark - Actions 

- (IBAction)playTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(videoPaused:)]) {
        return;
    }
    [self.delegate videoPaused:sender.selected];
}

- (IBAction)muteTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.muted = !sender.selected;
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(videoMuted:)]) {
        return;
    }
    [[DataManager sharedManager] setMuted:!sender.selected];
    [self.delegate videoMuted:!sender.selected];
}

- (IBAction)shareTapped:(UIButton *)sender {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(shareVideo)]) {
        return;
    }
    [self.delegate shareVideo];
}

#pragma mark - Line

- (void)panSelector:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.line];
    self.repeat = NO;
    if ((recognizer.view.center.x - CGRectGetMinX(self.line.frame)) + translation.x <= CGRectGetWidth(self.line.bounds) && (recognizer.view.center.x - CGRectGetMinX(self.line.frame)) + translation.x >= 0) {
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.line];
    }
    
    self.redLine.frame = CGRectMake(0, CGRectGetMinY(self.redLine.frame), (recognizer.view.center.x - CGRectGetMinX(self.line.frame)), CGRectGetHeight(self.redLine.frame));
    if (self.pan.state == UIGestureRecognizerStateEnded) {
        CGFloat currentPrecantege = (recognizer.view.center.x - CGRectGetMinX(self.line.frame)) / CGRectGetWidth(self.line.bounds) * 100.0;
        [self.currentPlayer seekToTime:[self timeForPercentage:currentPrecantege] completionHandler:^(BOOL finished) {
            self.repeat = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTime];
            });
        }];
    }
}

- (void)updateTime {
    if (!self.repeat) {
        return;
    }
    //DLog(@"Repinting");
    [self updateX:[self pointForPercentage:[self percentageForTime:self.currentPlayer.currentTime]] view:self.dragView];
    [self updateWidth:[self pointForPercentage:[self percentageForTime:self.currentPlayer.currentTime]] view:self.redLine];
    //DLog(@"Current Time %f", round(CMTimeGetSeconds(self.currentPlayer.currentTime)));

    [self.counterView counterWithTime:self.currentPlayer.currentTime];
    [self.counterDownView countDownWithCurrentTime:self.currentPlayer.currentItem.currentTime durationTime:self.currentPlayer.currentItem.asset.duration];
}

- (void)resetTime {
    [self updateX:[self pointForPercentage:[self percentageForTime:kCMTimeZero]] view:self.dragView];
    [self updateWidth:[self pointForPercentage:[self percentageForTime:kCMTimeZero]] view:self.redLine];
    [self.stopper reset];
}

- (CMTime)timeForPercentage:(NSInteger)precant {
    Float64 completeDuration = CMTimeGetSeconds(self.currentPlayer.currentItem.asset.duration);
    CGFloat devided = precant / 100.0;
    return CMTimeMake(devided * completeDuration, 1);
}

- (CGFloat)pointForPercentage:(NSInteger)percent {
    return ((percent / 100.0) * CGRectGetWidth(self.line.bounds));
}

- (CGFloat)percentageForPoint:(UIView *)view {
    return (view.center.x - CGRectGetMinX(self.line.frame)) / CGRectGetWidth(self.line.bounds) * 100;
}

- (CGFloat)percentageForTime:(CMTime)time {
    return CMTimeGetSeconds(time) / CMTimeGetSeconds(self.currentPlayer.currentItem.asset.duration) * 100.0;
}

- (void)updateWidth:(CGFloat)width view:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.frame = CGRectMake(CGRectGetMinX(view.frame), CGRectGetMinY(view.frame), width, CGRectGetHeight(view.bounds));
}

- (void)updateX:(CGFloat)x view:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.frame = CGRectMake((CGRectGetMinX(self.line.frame) + x) - CGRectGetWidth(self.dragView.bounds) / 2, CGRectGetMinY(view.frame), CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
}

- (void)dealloc {
    @try {
        [self.audioSession removeObserver:self forKeyPath:@"outputVolume"];
    }
    @catch (NSException *exception) {
        DLog(@"Exception removing outputVolume observer:%@", exception);
    }
}

@end
