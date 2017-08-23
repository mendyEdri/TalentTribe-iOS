//
//  TTAlertView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/20/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ButtonIndexAccept,
    ButtonIndexCancel,
    ButtonIndexClose
} ButtonIndex;

@class TTAlertView;

@protocol TTAlertViewDelegate <NSObject>

- (void)alertView:(TTAlertView *)alertView pressedButtonWithindex:(ButtonIndex)index;

@end

@interface TTAlertView : UIView

@property (nonatomic, weak) id <TTAlertViewDelegate> delegate;

@property BOOL isVisible;

- (void)showOnMainWindow:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

- (id)initWithMessage:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle;
- (id)initWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle;

@end
