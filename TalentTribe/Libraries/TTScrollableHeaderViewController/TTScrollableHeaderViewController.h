//
//  TTScrollableHeaderViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 11/6/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfileKeyboardObservingViewController.h"
#import "AsyncVideoDisplay.h"

@protocol TTScrollableViewProtocol <NSObject>

#pragma mark Scrolling

- (UIScrollView *)tt_scrollableView;

- (void)restoreContentOffset:(CGFloat)delta;

@end

@protocol TTScrollableViewDelegate <NSObject>

- (void)scrollableView:(UIScrollView *)scrollableView scrollWithDelta:(CGFloat)delta onController:(id <TTScrollableViewProtocol>)controller;
- (void)scrollableView:(UIScrollView *)scrollableView checkForPartialScrollonController:(id <TTScrollableViewProtocol>)controller;

@end

@interface TTScrollableHeaderViewController : UserProfileKeyboardObservingViewController <TTScrollableViewProtocol>

@property (nonatomic, weak) id <TTScrollableViewDelegate> scrollDelegate;

//- (void)startPlayingMultimediaItems;
- (void)cancelPlayingMultimediaItems;
//@property (nonatomic, strong) AsyncVideoDisplay *asyncPlayer;
@end
