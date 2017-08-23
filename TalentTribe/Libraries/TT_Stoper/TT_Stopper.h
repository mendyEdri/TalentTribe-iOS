//
//  TT_Stopper.h
//  TalentTribe
//
//  Created by Asi Givati on 11/11/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TT_Stopper : UIView

-(instancetype)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor distanceBetweenViews:(CGFloat)distanceBetweenViews milliseconds:(BOOL)includeMilliseconds;

@property NSTimer *mainTimer;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)reset;
- (void)counterWithTime:(CMTime)time;
- (void)countDownWithCurrentTime:(CMTime)time durationTime:(CMTime)duration;

@end
