//
//  StoryMediaCell.h
//  TalentTribe
//
//  Created by Asi Givati on 11/3/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TT_AVPlayer.h"

@class StoryMediaCell;

@protocol StoryMediaCellDelegate <NSObject>

-(void)storyMediaCellDidFinishDeleteAnimation:(StoryMediaCell *)cell;

@end

@interface StoryMediaCell : UICollectionViewCell <TT_AVPlayerDelegate>

@property BOOL isVideo;
@property (strong, nonatomic) UIImageView *backgroundImg;
//@property (nonatomic, copy) void (^closeHandler)(StoryMediaCell *cell);
@property TT_AVPlayer *ttPlayer;

-(void)setViews;
- (void)setupWithAttachObj:(id)obj;
-(void)prepareForCellDelete;
-(void)playVideo;
-(void)stopVideo;
-(void)deallocCell;
@property (weak, nonatomic) id <StoryMediaCellDelegate> delegate;

@end
