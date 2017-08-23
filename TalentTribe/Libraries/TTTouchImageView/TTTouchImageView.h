//
//  TTTouchImageView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTouchImageView;

@protocol TTTouchImageViewDelegate <NSObject>

- (void)touchedTTTouchImageView:(TTTouchImageView *)imageView;
- (void)touchEndedTTTouchImageView:(TTTouchImageView *)imageView;

@end

@interface TTTouchImageView : UIImageView

@property (nonatomic, weak) id <TTTouchImageViewDelegate> delegate;

@end
