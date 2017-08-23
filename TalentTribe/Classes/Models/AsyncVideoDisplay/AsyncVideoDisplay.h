//
//  AsyncVideoDisplay.h
//  TalentTribe
//
//  Created by Mendy on 16/11/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"
#import "Story.h"
#import <AVFoundation/AVFoundation.h>
#import "StoryFeedCollectionViewCell.h"
#import "StoryFeedCollectionViewMultimediaCell.h"
#import "TTPlayerItem.h"

typedef void (^StateHandler)(NSString *urlString);

@interface AsyncVideoDisplay : NSObject

- (instancetype)initWithCompaniesArray:(NSArray *)companies;
- (void)updateVidoePlayerWithCompanies:(NSArray *)companies;
// should be use pause player
- (void)pausePlayerWithUrl:(NSString *)url;
- (void)registerObserver:(AVPlayer *)player;
- (NSString *)urlStringOfCurrentlyPlayingInPlayer:(AVPlayer *)player;
- (void)videoPlayingState:(SimpleResultBlock)completion;
- (void)cancelAllPlayingVideosWithCompletion:(SimpleCompletionBlock)completion;

- (void)playerWithUrl:(NSString *)url completion:(SimpleResultBlock)completion;
- (void)removeAsyncPlayer;
- (NSString *)firstVideoUrl;

- (void)createVideoPlayersForCompanyStories:(NSArray<Story*> *)stories currentIndex:(NSInteger)index;
- (void)downloadVideosForStories:(NSArray<Story*> *)stories currentIndex:(NSInteger)index;

- (void)downloadVideosWithUrls:(NSArray *)urls;
- (void)pausePlayer:(AVPlayer *)player;

- (NSString *)currentPlayingPlayerUrl;
- (void)removeObservers:(AVPlayerItem *)item withCompletion:(SimpleCompletionBlock)completion;
+ (NSTimeInterval)availableDurationForPlayerItem:(AVPlayerItem *)item;
@property (strong, nonatomic) NSString *pendingUrl;
@property (strong, nonatomic) NSString *forcedPauseUrl;
@end
