//
//  TTUtils.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/9/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTUtils : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSDateFormatter *postDateFormatter;

+ (id)sharedUtils;

+ (NSString *)stringForNumberReplacingThousands:(NSInteger)number;
+ (NSMutableAttributedString *)attributedStringForString:(NSString *)string highlight:(NSString *)highlight highlightedColor:(UIColor *)highlightedColor defaultColor:(UIColor *)defaultColor;
+ (NSMutableAttributedString *)attributedCompanyName:(NSString *)name industry:(NSString *)industry;
+ (NSDictionary *)attributesForDot;

+ (NSData *)scaledJPEGImageDataFromImage:(UIImage *)originalImage maxSize:(CGFloat)size quality:(CGFloat)quality;

+ (void)showAlertWithText:(NSString *)text;
- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text otherButton:(NSString *)otherButton withCompletion:(SimpleCompletionBlock)completion;

+ (BOOL)validateEmail:(NSString *)email;
+ (BOOL)validatePhone:(NSString *)phone;
+ (BOOL)validatePassword:(NSString *)password;

@end
