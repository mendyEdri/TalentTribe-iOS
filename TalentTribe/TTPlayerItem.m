//
//  TTPlayerItem.m
//  TalentTribe
//
//  Created by Mendy on 05/04/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "TTPlayerItem.h"

@implementation TTPlayerItem

- (instancetype)initWithAsset:(AVAsset *)asset owner:(id)owner {
    self = [super initWithAsset:asset];
    if (self) {
        self.owner = owner;
    }
    return self;
}

+ (TTPlayerItem *)playerItemWithAsset:(AVAsset *)asset {
    TTPlayerItem *playerItem = [[TTPlayerItem alloc] initWithAsset:asset];
    return playerItem;
}

- (void)dealloc {
    if ([self observationInfo]) {
        @try {
            if (self.owner) {
                [self removeObserver:self.owner forKeyPath:@"loadedTimeRanges"];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        @catch (NSException *exception) {
            DLog(@"exception %@", exception);
        }
    }
}

@end
