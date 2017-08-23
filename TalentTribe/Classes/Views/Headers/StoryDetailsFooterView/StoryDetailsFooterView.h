//
//  StoryDetailsFooterView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/18/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoryDetailsFooterView;

@protocol StoryDetailsFooterViewDelegate <NSObject>

@optional

- (void)previousButtonPressedOnStoryDetailsFooterView:(StoryDetailsFooterView *)footerView;
- (void)nextButtonPressedOnStoryDetailsFooterView:(StoryDetailsFooterView *)footerView;
- (void)loadMoreCommentsPressedOnStoryDetailsFooterView:(StoryDetailsFooterView *)footerView;

@end

@interface StoryDetailsFooterView : UITableViewHeaderFooterView

@property (nonatomic, weak) id <StoryDetailsFooterViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *loadMoreCommentsButton;

- (void)setLeftButtonEnabled:(BOOL)enabled;
- (void)setRightButtonEnabled:(BOOL)enabled;

+ (CGFloat)height;

@end
