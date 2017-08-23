//
//  AsyncVideoDisplay.m
//  TalentTribe
//
//  Created by Mendy on 16/11/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "AsyncVideoDisplay.h"
#import <UIKit/UIKit.h>
#import "TTAVPlayer.h"

@interface AsyncVideoDisplay () <AVAssetResourceLoaderDelegate>
@property (strong, nonatomic) NSMutableArray *videoPlayers;
@property (strong, nonatomic) NSMutableArray *videoAssetsX;
@property (strong, nonatomic) NSMutableArray *videoAssetsY;
@property (strong, nonatomic) NSMutableArray *videoAssetsMain;
@property (strong, nonatomic) NSMutableArray *urls;

@property (strong, nonatomic) NSMutableArray *initialVideosUrl;

@property (strong, nonatomic) NSString *firstUrl;
@property (strong, nonatomic) NSMutableDictionary *thumbnails;
@property (strong, nonatomic) NSOperationQueue *downloadQueueX;
@property (strong, nonatomic) NSOperationQueue *downloadQueueY;
@property (assign, getter=isCancelingObservers) BOOL cancelingObservers;

@property (strong, nonatomic) void (^playerReadyWithPlayer)(AVURLAsset *asset);
@property (strong, nonatomic) void (^playerStatePlaying)(BOOL playing);
@end

typedef NS_ENUM(NSInteger, VideoType) {
    Main,
    Right,
    Bottom
};

#define downloadCurrentQueue NO

NSString * const kLoadedTimeRangesKey = @"loadedTimeRanges";
static void *AudioControllerBufferingObservationContext = &AudioControllerBufferingObservationContext;

@implementation AsyncVideoDisplay

- (instancetype)initWithCompaniesArray:(NSArray *)companies {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)updateVidoePlayerWithCompanies:(NSArray *)companies {   
    // [self downloadMain:YES right:YES bottom:YES fromCompanies:companies];
    
    [self setFirstVideoUrlFromCompany:companies.firstObject];
}

- (void)downloadMain:(BOOL)main right:(BOOL)right bottom:(BOOL)bottom fromCompanies:(NSArray<Company*>*)companies {
    Company *firstCompany = companies.firstObject;
    Company *bottomCompany;
    if (bottom) {
        bottomCompany = companies[1];
    }
    
    NSString *mainUrl = [self videoUrlsFromCompany:firstCompany index:0];
    NSString *rightUrl = [self videoUrlsFromCompany:firstCompany index:1];
    NSString *bottomUrl = [self videoUrlsFromCompany:bottomCompany index:0];
    
    DLog(@"Downloaded Main %@", mainUrl);
    DLog(@"Downloaded Right %@", rightUrl);
    DLog(@"Downloaded Bottom %@", bottomUrl);
    
    NSOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        operationA.queuePriority = NSOperationQueuePriorityVeryHigh;
        [self downloadWithUrl:mainUrl type:Main];
    }];
    NSOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        operationB.queuePriority = NSOperationQueuePriorityNormal;
        [self downloadWithUrl:rightUrl type:Right];
    }];
    [operationB addDependency:operationA];
    NSOperation *operationC = [NSBlockOperation blockOperationWithBlock:^{
        operationA.queuePriority = NSOperationQueuePriorityLow;
        [self downloadWithUrl:bottomUrl type:Bottom];
    }];
    [operationC addDependency:operationB];
    
    if (!self.downloadQueueY) {
        self.downloadQueueY = [[NSOperationQueue alloc] init];
    } else {
        [self.downloadQueueY cancelAllOperations];
    }
    self.downloadQueueY.maxConcurrentOperationCount = 3;
    if (downloadCurrentQueue) {
        [[NSOperationQueue currentQueue] addOperations:@[operationA, operationB, operationC] waitUntilFinished:NO];
        return;
    }
    [self.downloadQueueY addOperations:@[operationA, operationB, operationC] waitUntilFinished:NO];
}

- (void)downloadVideosForStories:(NSArray<Story*> *)stories currentIndex:(NSInteger)index {
    Story *mainStory = stories[index];
    Story *nextStory = stories[index+1];
    
    NSString *mainUrl;
    NSString *rightUrl;
    
    if (mainStory.videoLink) {
        mainUrl = mainStory.videoLink;
    }
    
    if (nextStory.videoLink) {
        rightUrl = nextStory.videoLink;
    }
    
    DLog(@"Downloaded Main %@", mainUrl);
    DLog(@"Downloaded Right %@", rightUrl);
    
    NSOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        operationA.queuePriority = NSOperationQueuePriorityVeryHigh;
        [self downloadWithUrl:mainUrl type:Main];
    }];
    NSOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        operationB.queuePriority = NSOperationQueuePriorityNormal;
        [self downloadWithUrl:rightUrl type:Right];
    }];
    [operationB addDependency:operationA];
    
    if (!self.downloadQueueX) {
        self.downloadQueueX = [[NSOperationQueue alloc] init];
    } else {
        [self.downloadQueueX cancelAllOperations];
    }
    self.downloadQueueX.maxConcurrentOperationCount = 2;
    if (downloadCurrentQueue) {
        [[NSOperationQueue currentQueue] addOperations:@[operationA, operationB] waitUntilFinished:NO];
        return;
    }
    [self.downloadQueueX addOperations:@[operationA, operationB] waitUntilFinished:NO];
}

- (void)downloadVideosWithUrls:(NSArray *)urls {
    //DLog(@"URLS %@", urls);
    NSString *mainUrl;
    NSString *rightUrl;
    NSString *bottomUrl;
    
    NSInteger index = 0;
    for (NSArray *line in urls) {
        switch (index) {
            case 0: {
                if (line.count) {
                    mainUrl = line.firstObject;
                }
                if (line.count > 1) {
                    rightUrl = line[1];
                }
            } break;
            case 1: {
                if (line.count) {
                    bottomUrl = line.firstObject;
                }
            } break;
                
            default:
                break;
        }
        index++;
    }
    
//    DLog(@"Downloaded Main %@", mainUrl);
//    DLog(@"Downloaded Right %@", rightUrl);
//    DLog(@"Downloaded Bottom %@", bottomUrl);
    
    NSOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        operationA.queuePriority = NSOperationQueuePriorityVeryHigh;
        [self downloadWithUrl:mainUrl type:Main];
    }];
    NSOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        operationB.queuePriority = NSOperationQueuePriorityNormal;
        [self downloadWithUrl:rightUrl type:Right];
    }];
    [operationB addDependency:operationA];
    NSOperation *operationC = [NSBlockOperation blockOperationWithBlock:^{
        operationA.queuePriority = NSOperationQueuePriorityLow;
        [self downloadWithUrl:bottomUrl type:Bottom];
    }];
    [operationC addDependency:operationB];
    
    if (!self.downloadQueueY) {
        self.downloadQueueY = [[NSOperationQueue alloc] init];
    } else {
        [self.downloadQueueY cancelAllOperations];
    }
    self.downloadQueueY.maxConcurrentOperationCount = 3;
    if (downloadCurrentQueue) {
        [[NSOperationQueue currentQueue] addOperations:@[operationA, operationB, operationC] waitUntilFinished:NO];
        return;
    }
    [self.downloadQueueY addOperations:@[operationA, operationB, operationC] waitUntilFinished:NO];
}

- (void)downloadWithUrl:(NSString *)url type:(VideoType)type {
    if ([self assetForUrl:url]) {
        return;
    }

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:url] options:nil];
    //NSArray *keys = @[@"playable"];
    NSArray *keys = @[@"duration"];
    
    __block VideoType blockVideoType = type;
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
        
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:
                //[self updateUserInterfaceForDuration];
                DLog(@"AVKeyValueStatusLoaded");
                break;
            case AVKeyValueStatusFailed:
                //[self reportError:error forAsset:asset];
                DLog(@"AVKeyValueStatusFailed");
                break;
            case AVKeyValueStatusCancelled:
                // Do whatever is appropriate for cancelation.
                DLog(@"AVKeyValueStatusCancelled");
                break;
            case AVKeyValueStatusUnknown:
                DLog(@"AVKeyValueStatusUnknown");
                break;
            case AVKeyValueStatusLoading:
                DLog(@"AVKeyValueStatusLoading")
                break;
        }
        
        
        
        if ([[asset.URL absoluteString] isEqualToString:self.pendingUrl]) {
            if (self.playerReadyWithPlayer) {
                self.playerReadyWithPlayer(asset);
            }
        }
//        DLog(@"Downloaded URL %@", [asset.URL absoluteString]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.videoAssetsX) {
                self.videoAssetsX = [NSMutableArray new];
            }
            if (!self.videoAssetsY) {
                self.videoAssetsY = [NSMutableArray new];
            }
            if (!self.videoAssetsMain) {
                self.videoAssetsMain = [NSMutableArray new];
            }
            
            switch (blockVideoType) {
                case Main: {
                    [self.videoAssetsMain removeAllObjects];
                    //[self.videoAssetsMain insertObject:asset atIndex:0];
                } break;
                case Right: {
                    if (self.videoAssetsX.count > 2) {
                        [self.videoAssetsX removeLastObject];
                    }
                    //[self.videoAssetsX insertObject:asset atIndex:0];
                } break;
                case Bottom: {
                    if (self.videoAssetsY.count > 2) {
                        [self.videoAssetsY removeLastObject];
                    }
                   // [self.videoAssetsY insertObject:asset atIndex:0];
                } break;
            }
        });
    }];
}

- (void)registerObserversForPlayer:(AVPlayerItem *)item {
    [item addObserver:self forKeyPath:kLoadedTimeRangesKey options:NSKeyValueObservingOptionNew context:AudioControllerBufferingObservationContext]; //NSKeyValueObservingOptionInitial |
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
}

- (void)videoEnded:(NSNotification *)notification {
    AVPlayerItem *item = notification.object;
    AVURLAsset *assetUrl = (AVURLAsset *)item.asset;
    
    [self playerWithUrl:[assetUrl.URL absoluteString] completion:^(id result, NSError *error) {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayer *player = result;
                [player seekToTime:kCMTimeZero];
                [player play];
            });
        }
    }];
}

- (void)pausePlayer:(AVPlayer *)player {
    [self removeObservers:player.currentItem withCompletion:nil];
    self.forcedPauseUrl = [self urlStringOfCurrentlyPlayingInPlayer:player];
    [player pause];
}

- (void)registerObserver:(AVPlayer *)player {
    if (!player.currentItem) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self registerObserversForPlayer:player.currentItem];
    });
}

- (NSString *)urlStringOfCurrentlyPlayingInPlayer:(AVPlayer *)player {
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [[(AVURLAsset *)currentPlayerAsset URL] absoluteString];
}

+ (NSString *)urlStringOfItem:(AVPlayerItem *)item {
    AVAsset *currentPlayerAsset = item.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [[(AVURLAsset *)currentPlayerAsset URL] absoluteString];
}

- (void)playerWithUrl:(NSString *)url completion:(SimpleResultBlock)completion {
    AVURLAsset *asset = [self assetForUrl:url];
    if (asset && completion) {
        completion(asset, nil);
        return;
    }
    
    // it's not ready so wait till ready and return it
    self.playerReadyWithPlayer = ^(AVURLAsset *asset) {
        if (completion && [[asset.URL absoluteString] isEqualToString:self.pendingUrl]) {
            completion(asset, nil);
        }
    };
}

- (void)cancelAllPlayingVideosWithCompletion:(SimpleCompletionBlock)completion {
//    if (self.playerItemMain) {
//        [self removeObservers:self.playerItemMain];
//    }
    self.cancelingObservers = YES;
//    [self.currentPlayer pause];
    self.cancelingObservers = NO;
    if (completion) {
        completion(YES, nil);
    }
}

- (void)setFirstVideoUrlFromCompany:(Company *)firstCompany {
    if (firstCompany.stories.count && firstCompany.stories.count > 0) {
        Story *story = firstCompany.stories.firstObject;
        if (story.videoLink) {
            self.firstUrl = story.videoLink;
        }
    }
}

- (NSString *)firstVideoUrl {
    if (!self.firstUrl) {
        return nil;
    }
    return [self.firstUrl copy];
}

- (AVURLAsset *)assetForUrl:(NSString *)url {
    for (AVURLAsset *asset in self.videoAssetsMain) {
        if ([[asset.URL absoluteString] isEqualToString:url]) {
            return asset;
        }
    }
    
    for (AVURLAsset *asset in self.videoAssetsX) {
        if ([[asset.URL absoluteString] isEqualToString:url]) {
            return asset;
        }
    }
    
    for (AVURLAsset *asset in self.videoAssetsY) {
        if ([[asset.URL absoluteString] isEqualToString:url]) {
            return asset;
        }
    }
    return nil;
}

- (NSArray *)videoUrlsFromCompany:(Company *)company max:(NSInteger)count {
    NSInteger index = 0;
    NSMutableArray *videosUrl = [NSMutableArray new];
    for (Story *story in [company.stories copy]) {
        if (!story.videoLink) {
            index++;
            continue;
        }
        if (videosUrl.count == count || index == count) {
            return [videosUrl copy];
        }
        [videosUrl addObject:story.videoLink];
        index++;
    }
    return videosUrl;
}

- (NSString *)videoUrlsFromCompany:(Company *)company index:(NSInteger)index {
    if (company.stories.count <= index) {
        return nil;
    }

    Story *story = company.stories[index];
    if (!story.videoLink) {
        return nil;
    }
    
    return story.videoLink;
}

- (NSString *)currentPlayingPlayerUrl {
    return nil;//[AsyncVideoDisplay urlStringOfItem:self.playerItemMain];
}

#pragma mark Thumbnails 
#pragma mark - Not in Use
- (void)updateThumbnailForUrl:(NSString *)url thumbnail:(UIImage *)thumbnail {
    if (!self.thumbnails) {
        self.thumbnails = [[NSMutableDictionary alloc] init];
    }
    [self.thumbnails setObject:thumbnail forKey:url];
}

- (UIImage *)thumbnailImageForUrl:(NSString *)url {
    if ([self.thumbnails objectForKey:url]) {
        return [self.thumbnails objectForKey:url];
    }
    return nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!object || self.isCancelingObservers) {
        return;
    }
    
    if (context == AudioControllerBufferingObservationContext) {
        AVPlayerItem *playerItem = object;
        
        /*
        Float64 duration = CMTimeGetSeconds(playerItem.currentTime);
        Float64 completeDuration = CMTimeGetSeconds(playerItem.asset.duration);
        DLog(@"*******");
        DLog(@"Availble Buffering Duration %f", [AsyncVideoDisplay availableDurationForPlayerItem:playerItem] - duration);
        DLog(@"Current Time %f", duration);
        DLog(@"Complete Duration %f", completeDuration);
        DLog(@"*******");
        */
        
        if (playerItem.isPlaybackLikelyToKeepUp) {
            if ([self.forcedPauseUrl isEqualToString:[AsyncVideoDisplay urlStringOfItem:playerItem]]) {
                return;
            }
            if (self.playerStatePlaying) {
                self.playerStatePlaying(YES);
            }
            return;
        } else {
            if (self.playerStatePlaying) {
                self.playerStatePlaying(NO);
            }
        }
    
        /*
        NSLog(@"Buffering status: %@", [object loadedTimeRanges]);
        if (([AsyncVideoDisplay availableDurationForPlayerItem:playerItem] - duration) >= 5.0 || ([AsyncVideoDisplay availableDurationForPlayerItem:playerItem]) >= completeDuration) {
            if ([self.forcedPauseUrl isEqualToString:[AsyncVideoDisplay urlStringOfItem:playerItem]]) {
                return;
            }
            if (playerStatePlaying) {
                playerStatePlaying(YES);
            }
        } else {
            if (playerStatePlaying) {
                playerStatePlaying(NO);
            }
        }
         */
    }
    
    /*
    if ([object isKindOfClass:[AVPlayer class]] && [keyPath isEqualToString:@"status"]) {
        [object removeObserver:self forKeyPath:@"status"];
        AVPlayer *avPlayer = object;
        [avPlayer pause];
        avPlayer.muted = YES;

        if (self.playerReadyWithPlayer) {
            self.playerReadyWithPlayer(avPlayer);
        }
    }
     */
}

- (void)videoPlayingState:(SimpleResultBlock)completion {
    self.playerStatePlaying = ^(BOOL playing) {
        if (completion) {
            completion(@(playing), nil);
        }
    };
}

- (void)removeObservers:(TTPlayerItem *)item withCompletion:(SimpleCompletionBlock)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item observationInfo]) {
            @try {
                [[NSNotificationCenter defaultCenter] removeObserver:item forKeyPath:AVPlayerItemDidPlayToEndTimeNotification context:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:item forKeyPath:kLoadedTimeRangesKey context:AudioControllerBufferingObservationContext];
            }
            @catch (NSException *exception) {
                DLog(@"Exeption removeing observers %@", exception);
            }
        }
        DLog(@"OBSERVERS REMOVED FROM: %@", item);
        if (completion) {
            completion(YES, nil);
        }
    });
}

+ (NSTimeInterval)availableDurationForPlayerItem:(AVPlayerItem *)item {
    NSArray *loadedTimeRanges = [item loadedTimeRanges];
    if (loadedTimeRanges.count == 0) {
        return 0.0;
    }
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
    Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

#pragma mark - Loader Delegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    return YES;
}

- (void)dealloc {
    if (!downloadCurrentQueue) {
        if (self.downloadQueueX.operationCount) {
            @try {
                [self.downloadQueueX cancelAllOperations];
                self.downloadQueueX = nil;
            }
            @catch (NSException *exception) {
                DLog(@"self.downloadQueueX cancelAllOperations %@", exception);
            }
        }
        if (self.downloadQueueY.operationCount) {
            @try {
                [self.downloadQueueY cancelAllOperations];
                self.downloadQueueY = nil;
            }
            @catch (NSException *exception) {
                DLog(@"self.downloadQueueY cancelAllOperations %@", exception);
            }
        }
    } else {
        @try {
            if ([NSOperationQueue currentQueue].operationCount) {
                [[NSOperationQueue currentQueue] cancelAllOperations];
            }
        }
        @catch (NSException *exception) {
            DLog(@"Exeption removeing observers %@", exception);
        }
    }
    
    if ([self observationInfo]) {
        @try {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        @catch (NSException *exception) {
            DLog(@"exception remove status observer %@", exception);
        }
    }

    // Crashe - since the observer already removed up here (as super)
    //[self cancelAllPlayingVideosWithCompletion:nil];
}

- (void)removeAsyncPlayer {
//    [self.videoPlayers removeAllObjects];
    [self.initialVideosUrl removeAllObjects];
}

@end
