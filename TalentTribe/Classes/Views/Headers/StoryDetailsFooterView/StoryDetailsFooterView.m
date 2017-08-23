//
//  StoryDetailsFooterView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/18/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsFooterView.h"

@interface StoryDetailsFooterView ()

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;

@end

@implementation StoryDetailsFooterView

- (IBAction)prevButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(previousButtonPressedOnStoryDetailsFooterView:)]) {
        [self.delegate previousButtonPressedOnStoryDetailsFooterView:self];
    }
}

- (IBAction)nextButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(nextButtonPressedOnStoryDetailsFooterView:)]) {
        [self.delegate nextButtonPressedOnStoryDetailsFooterView:self];
    }
}

- (IBAction)loadMoreComments:(id)sender {
    [self.delegate loadMoreCommentsPressedOnStoryDetailsFooterView:self];
}

- (void)setLeftButtonEnabled:(BOOL)enabled {
    [self.leftButton setHidden:!enabled];
}

- (void)setRightButtonEnabled:(BOOL)enabled {
    [self.rightButton setHidden:!enabled];
}

+ (CGFloat)height {
    return 50.0f;
}

@end
