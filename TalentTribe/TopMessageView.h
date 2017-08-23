//
//  TopMessageView.h
//  TalentTribe
//
//  Created by Mendy on 01/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopMessageView : UIView

- (id)initWithText:(NSString *)text backgroundColor:(UIColor *)color;
- (void)setText:(NSString *)text backgroundColor:(UIColor *)color;
- (void)animate;
@end
