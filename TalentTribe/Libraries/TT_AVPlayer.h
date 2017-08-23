//
//  TT_AVPlayer.h
//  TalentTribe
//
//  Created by Asi Givati on 11/12/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class TT_AVPlayer;

@protocol TT_AVPlayerDelegate <NSObject>
@optional

-(void)playerDidStartPlayingVideo:(TT_AVPlayer *)player;
-(void)playerDidPlayToEndTime:(TT_AVPlayer *)player;
-(void)playerDidSetNewThumbnailImage:(UIImage *)image;

@end


@interface TT_AVPlayer : UIView

@property (weak,nonatomic) id <TT_AVPlayerDelegate> delegate;
@property BOOL preventPlayByTouch;
-(id)initWithFrame:(CGRect)frame filePath:(NSURL *)filePath autoPlay:(BOOL)autoPlay delegate:(id)delegate addToView:(UIView *)superView;

-(void)deallocPlayer;

/**
 Playing current loaded file path
 */
-(void)play;
/**
 Playing a new file path
 */
-(void)playFilePath:(NSString *)newPath;

-(void)stop;

@property (nonatomic, strong) UIImageView *thumbnailImageview;
@property (nonatomic, strong) UICollectionViewCell *parent;

@end
