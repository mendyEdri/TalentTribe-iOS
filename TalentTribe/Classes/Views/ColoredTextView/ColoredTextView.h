//
//  ColoredTextView.h
//  TalentTribe
//
//  Created by Mendy on 08/12/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColoredTextView : UIView
@property (nonatomic, strong) NSString *text;


+ (void)textViewWithText:(NSString *)text backgroundTextColor:(UIColor *)backgroundTextColor textColor:(UIColor *)textColor rowHeight:(CGFloat)rowHeight fontSize:(CGFloat)fontSize fontName:(NSString *)fontName frame:(CGRect)frame completion:(SimpleResultBlock)completion;

- (void)coloredTextViewWithText:(NSString *)text backgroundTextColor:(UIColor *)backgroundTextColor textColor:(UIColor *)textColor rowHeight:(CGFloat)rowHeight fontSize:(CGFloat)fontSize fontName:(NSString *)fontName;

@end
