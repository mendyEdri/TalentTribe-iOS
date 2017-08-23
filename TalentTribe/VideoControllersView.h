//
//  VideoControllersView.h
//  TalentTribe
//
//  Created by Mendy on 30/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGradientHandler.h"

@protocol VideoControllersViewDelegate <NSObject>

- (void)videoMuted:(BOOL)muted;
- (void)videoPaused:(BOOL)paused;
- (void)shareVideo;
- (void)videoControllersDidSwiped;
@end

@interface VideoControllersView : TTCustomGradientView

- (instancetype)initWithColors:(NSArray *)colors locations:(NSArray *)locations;
+ (void)videoControllersViewWithCompletion:(SimpleResultBlock)completion;
- (void)showVolumeGradientView:(BOOL)show player:(AVPlayer *)currentPlayer completion:(SimpleCompletionBlock)completion;
- (void)videoBuffering:(BOOL)buffering;
- (void)playButtonStatePlaying:(BOOL)playing;
@property (nonatomic, strong) UIView *statusBarView;
@property (nonatomic, assign, getter=isMuted, setter=mute:) BOOL muted;
@property (nonatomic, assign, getter=isEnableVolumeObserver, setter=setEnableVolumeObserver:) BOOL enableVolumeObserver;
@property (assign, nonatomic) id<VideoControllersViewDelegate>delegate;
@end
