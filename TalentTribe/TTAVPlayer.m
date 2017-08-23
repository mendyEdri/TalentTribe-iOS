//
//  TTAVPlayer.m
//  TalentTribe
//
//  Created by Mendy on 24/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "TTAVPlayer.h"
#import "TTPlayerItem.h"

@implementation TTAVPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item {
    self = [super initWithPlayerItem:item];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    if (self) {
        
    }
    return self;
}

- (void)replaceCurrentItemWithPlayerItem:(TTPlayerItem *)item {
    [super replaceCurrentItemWithPlayerItem:(AVPlayerItem *)item];
}

- (void)dealloc {
    DLog(@"TTAVPlayer Deallocated");
}

@end
