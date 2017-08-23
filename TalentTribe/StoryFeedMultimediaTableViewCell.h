//
//  StoryFeedMultimediaTableViewCell.h
//  TalentTribe
//
//  Created by Mendy on 18/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryFeedTableViewCell.h"

@interface StoryFeedMultimediaTableViewCell : StoryFeedTableViewCell

- (void)play;
- (void)pause;
- (void)playing:(BOOL)play;
- (void)animateView:(BOOL)animate;
- (void)didEndDisplay;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSString *urlString;
@property (nonatomic, strong) AVPlayer *avPlayer;
@end
