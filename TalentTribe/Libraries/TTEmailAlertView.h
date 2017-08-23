//
//  TTEmailAlertView.h
//  TalentTribe
//
//  Created by Mendy on 22/09/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ButtonIndexAccept2,
    ButtonIndexCancel2,
    ButtonIndexClose2
} ButtonIndex2;

@class TTEmailAlertView;

@protocol TTEmailAlertViewDelegate <NSObject>

- (void)emailAlertView:(TTEmailAlertView *)alertView pressedButtonWithindex:(ButtonIndex2)index;

@end

@interface TTEmailAlertView : UIView

@property (nonatomic, weak) id <TTEmailAlertViewDelegate> delegate;

@property BOOL isVisible;
@property NSString *email;

- (void)showOnMainWindow:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

- (id)initWithMessage:(NSString *)message acceptTitle:(NSString *)acceptTitle cancelTitle:(NSString *)cancelTitle;
- (id)initWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle;

@end
