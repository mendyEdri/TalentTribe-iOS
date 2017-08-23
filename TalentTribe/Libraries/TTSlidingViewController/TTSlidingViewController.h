//
//  TTSlidingViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/5/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTSlidingViewController;

@protocol TTSlidingView <NSObject>

@property (nonatomic) BOOL selected;

@end

@protocol TTSlidingViewControllerDataSource <NSObject>

- (NSInteger)numberOfItemsInSlidingViewController:(TTSlidingViewController *)controller;
- (UIViewController *)slidingViewController:(TTSlidingViewController *)controller viewControllerAtIndex:(NSInteger)index;
- (UIView <TTSlidingView> *)slidingViewController:(TTSlidingViewController *)controller viewForMenuItemAtIndex:(NSInteger)index;

@optional

- (CGFloat)heightForMenuInSlidingViewController:(TTSlidingViewController *)controller;

@end

@protocol TTSlidingViewControllerDelegate <NSObject>

@optional

- (BOOL)slidingViewController:(TTSlidingViewController *)controller shouldSelectItemAtIndex:(NSInteger)index;
- (void)slidingViewController:(TTSlidingViewController *)controller didSelectItemAtIndex:(NSInteger)index;

@end

@interface TTSlidingViewController : UIViewController

@property (nonatomic, weak) id <TTSlidingViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <TTSlidingViewControllerDelegate> delegate;

@property (nonatomic) UIEdgeInsets menuEdgeInsets;
@property (nonatomic) CGFloat menuSpacing;
@property (nonatomic) NSInteger maxNumberOfMenuItemsOnScreen;

@property NSInteger currentSelectedIndex;

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void(^)(void))completion;
- (void)reloadData;

@end
