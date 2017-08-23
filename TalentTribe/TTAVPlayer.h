//
//  TTAVPlayer.h
//  TalentTribe
//
//  Created by Mendy on 24/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface TTAVPlayer : AVPlayer

- (instancetype)init;
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithPlayerItem:(AVPlayerItem *)item;
@end
