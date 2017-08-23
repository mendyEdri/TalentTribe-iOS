//
//  TT_Stoper.m
//  TalentTribe
//
//  Created by Asi Givati on 11/11/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "TT_Stopper.h"
#import "GeneralMethods.h"

@interface TT_Stopper()

@property NSString *hourStr;
@property NSString *minStr;
@property NSString *secStr;
@property NSString *millisecondsStr;

@property UILabel *hourLabel;
@property UILabel *minLabel;
@property UILabel *secLabel;
@property UILabel *millisecondsLabel;
@property BOOL includeMilliseconds;
@property BOOL smallViews;

@property UIView *containerView;
@property UILabel *colon1;
@property UILabel *colon2;
@property UILabel *colon3;
@property UIColor *textColor;
@property CGFloat distanceBetweenViews;
@property CGFloat fontSize;
@end

@implementation TT_Stopper
 

-(instancetype)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor distanceBetweenViews:(CGFloat)distanceBetweenViews milliseconds:(BOOL)includeMilliseconds
{
    if (self = [super initWithFrame:frame])
    {
        self.textColor = textColor;
        self.distanceBetweenViews = distanceBetweenViews;
        self.includeMilliseconds = includeMilliseconds;
        [self setViews];
    }
    return self;
}

- (void)awakeFromNib {
    self.textColor = [UIColor whiteColor];
    self.distanceBetweenViews = 0;
    self.includeMilliseconds = NO;
    self.smallViews = YES;
    [self setViews];
}

-(void)animateColons
{
    if ([self.mainTimer isValid] == NO)
    {
        [self showColons:YES];
        return;
    }
    
    [UIView animateWithDuration:1 animations:^
    {
        [self showColons:(self.colon1.alpha != 1)];
    }
    completion:^(BOOL finished)
    {
        [self animateColons];
    }];
}

-(void)showColons:(BOOL)show
{
    CGFloat alpha = 0;
    if (show)
    {
        alpha = 1;
    }
    
    [self.colon1 setAlpha:alpha];
    [self.colon2 setAlpha:alpha];
    if (self.includeMilliseconds)
    {
        [self.colon3 setAlpha:alpha];
    }
}

-(void)reset
{
//    self.hourStr = @"00";
    self.minStr = @"00";
    self.secStr = @"30";
    self.millisecondsStr = @"00";
}

-(void)setViews
{
    [self reset];
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    self.fontSize = self.smallViews ? 14 :CGRectGetHeight(self.containerView.frame) - 6;
    if (self.hourLabel.text.length) {
        self.hourLabel = [self createDynamicLabel:self.hourLabel withText:self.hourStr prevLabel:nil];
        self.colon1 = [self createDynamicLabel:self.colon1 withText:@":" prevLabel:self.hourLabel];
    }
    self.minLabel = [self createDynamicLabel:self.minLabel withText:self.minStr prevLabel:self.colon1];
    self.colon2 = [self createDynamicLabel:self.colon2 withText:@":" prevLabel:self.minLabel];
    self.secLabel = [self createDynamicLabel:self.secLabel withText:self.secStr prevLabel:self.colon2];
    if (self.includeMilliseconds)
    {
        self.colon3 = [self createDynamicLabel:self.colon3 withText:@":" prevLabel:self.secLabel];
        self.millisecondsLabel = [self createDynamicLabel:self.millisecondsLabel withText:self.millisecondsStr prevLabel:self.colon3];
    }

    [self updateContainerViewFrame];
    
    [self addSubview:self.containerView];
}

-(void)updateContainerViewFrame
{
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    CGFloat width = CGRectGetMaxX([[self.containerView subviews] lastObject].frame);
    CGFloat height = CGRectGetHeight(self.frame);
    [self.containerView setFrame:CGRectMake(xPos, yPos, width, height)];
    self.containerView.center = CGPointMake(self.frame.size.width / 2, self.containerView.center.y);
}

-(UILabel *)createDynamicLabel:(UILabel *)label withText:(NSString *)text prevLabel:(UILabel *)prev
{
    CGFloat xPos = 0;

    if (prev)
    {
        xPos = CGRectGetMaxX(prev.frame) + self.distanceBetweenViews;
    }
    
    return [GeneralMethods createDynamicLableWithText:text xPos:xPos yPos:0 fontSize:self.fontSize textColor:self.textColor fontName:nil addToView:self.containerView];
}

-(void)start
{
    [self reset];
    [self resetTimer];
    self.mainTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(counter) userInfo:nil repeats:YES];
    [self animateColons];
}

-(void)resume
{
    [self resetTimer];
    self.mainTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(counter) userInfo:nil repeats:YES];
}

-(void)counter
{
    int hour = [self.hourStr intValue];
    int min = [self.minStr intValue];
    int sec = [self.secStr intValue];
    int millisec = [self.millisecondsStr intValue];
    
    millisec++;
    
    if (millisec > 99)
    {
        millisec = 0;
        sec--;
    }
    
    if (sec > 59)
    {
        sec = 0;
        min++;
    }
    
    if (min > 59)
    {
        min = 0;
        hour ++;
    }
    
    self.millisecondsStr = [NSString stringWithFormat:@"%02d",millisec];
    self.secStr = [NSString stringWithFormat:@"%02d",sec];
    self.minStr = [NSString stringWithFormat:@"%02d",min];
    self.hourStr = [NSString stringWithFormat:@"%02d",hour];
    [self updateLabels];
}

- (void)counterWithTime:(CMTime)time {
    int seconds = CMTimeGetSeconds(time);
    int minutes = seconds / 60;
    seconds = seconds % 60;
    
    //self.millisecondsStr = [NSString stringWithFormat:@"%02d",miliseconds];
    //self.hourStr = [NSString stringWithFormat:@"%02d",hour];
    self.secStr = [NSString stringWithFormat:@"%02d",seconds];
    self.minStr = [NSString stringWithFormat:@"%02d",minutes];
    [self updateLabels];
}

- (void)countDownWithCurrentTime:(CMTime)time durationTime:(CMTime)duration {
    int seconds = CMTimeGetSeconds(duration) - CMTimeGetSeconds(time);
    int minutes = seconds / 60;
    seconds = seconds % 60;
    
    self.secStr = [NSString stringWithFormat:@"%02d",seconds];
    self.minStr = [NSString stringWithFormat:@"%02d",minutes];
    [self updateLabels];
}

-(void)pause
{
    [self resetTimer];
}

-(void)updateLabels
{
    if (self.includeMilliseconds)
    {
        [self.millisecondsLabel setText:self.millisecondsStr];
    }
    [self.secLabel setText:self.secStr];
    [self.minLabel setText:self.minStr];
    [self.hourLabel setText:self.hourStr];
}

-(void)resetTimer
{
    [self.mainTimer invalidate];
    self.mainTimer = nil;
}

-(void)stop
{
    [self pause];
    [self reset];
    [self updateLabels];
}


@end
