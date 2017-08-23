//
//  TTPlayerItem.h
//  TalentTribe
//
//  Created by Mendy on 05/04/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface TTPlayerItem : AVPlayerItem
- (instancetype)initWithAsset:(AVAsset *)asset owner:(id)owner;
+ (TTPlayerItem *)playerItemWithAsset:(AVAsset *)asset;
@property (nonatomic, strong, setter=setOwner:) id owner;
@end
