//
//  StoryFeedCollectionViewMultimediaCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryFeedCollectionViewCell.h"
#import "AsyncVideoDisplay.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "DataManager.h"

@protocol StoryFeedCollectionViewMultimediaCellDelegate <NSObject>
- (void)timeUpdated:(NSTimeInterval)time;
@end

@interface StoryFeedCollectionViewMultimediaCell : StoryFeedCollectionViewCell

- (void)play;
- (void)pause;
- (void)playing:(BOOL)play;
- (void)animateView:(BOOL)animate;
- (void)didEndDisplay;

- (void)setActive;
- (void)muteVideo:(BOOL)mute;
- (void)toggleVideo:(BOOL)play;
- (void)cellWillAppear;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSString *urlString;
@property (nonatomic, strong) AVPlayer *currentPlayer;
@property (nonatomic, assign) BOOL forcePause;
@property (nonatomic, assign) BOOL repeat;
@property (nonnull, assign) id<StoryFeedCollectionViewMultimediaCellDelegate>multimediaCellDelegate;
@end
