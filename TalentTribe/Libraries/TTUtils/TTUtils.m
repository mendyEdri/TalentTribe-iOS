//
//  TTUtils.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/9/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTUtils.h"
#import <UIKit/UIKit.h>

#define kShadowBlur 10.0f

void (^alertDone)(BOOL otherButtonPressed);

@implementation TTUtils

+ (id)sharedUtils {
    static TTUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TTUtils new];
    });
    return instance;
}

- (NSDateFormatter *)postDateFormatter {
    if (!_postDateFormatter) {
        _postDateFormatter = [[NSDateFormatter alloc] init];
        [_postDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [_postDateFormatter setDateFormat:@"dd MMM yyyy"];
    }
    return _postDateFormatter;
}

+ (NSString *)stringForNumberReplacingThousands:(NSInteger)number {
    if (number >= 1000) {
        NSInteger hundreds = (NSInteger)((number % 1000) / 100);
        if (hundreds > 0) {
            return [NSString stringWithFormat:@"%ld,%ldk", number / 1000, (long)hundreds];
        } else {
            return [NSString stringWithFormat:@"%ldk", number / 1000];
        }
    } else {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }
}

+ (NSMutableAttributedString *)attributedStringForString:(NSString *)string highlight:(NSString *)highlight highlightedColor:(UIColor *)highlightedColor defaultColor:(UIColor *)defaultColor {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Raleway-Light" size:13], NSForegroundColorAttributeName : defaultColor} range:NSMakeRange(0, attributedString.string.length)];
    if (highlight) {
        [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Raleway-Semibold" size:13], NSForegroundColorAttributeName : highlightedColor} range:[attributedString.string rangeOfString:highlight]];
    }
    NSString *dot = @"·";
    NSRange range = [attributedString.string rangeOfString:dot];
    if (range.location != NSNotFound) {
        [attributedString setAttributes:[TTUtils attributesForDot] range:range];
    }
    return attributedString;
}

+ (NSDictionary *)attributesForDot {
    return @{NSFontAttributeName : [UIFont fontWithName:@"HiraKakuProN-W3" size:13], NSForegroundColorAttributeName : UIColorFromRGB(0x8d8d8d)};
}

+ (NSMutableAttributedString *)attributedCompanyName:(NSString *)name industry:(NSString *)industry {
    if (!name) {
        return nil;
    }
    NSMutableString *titleString = [[NSMutableString alloc] initWithString:name];
    /*if (industry) {
        [titleString appendFormat:@"  %@", industry];
    }*/
    
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    [attributedTitleString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Raleway-Bold" size:16]} range:[attributedTitleString.string rangeOfString:name]];
    /*if (industry) {
        [attributedTitleString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"TitilliumWeb-Light" size:18]} range:[attributedTitleString.string rangeOfString:industry]];
    }*/
    return attributedTitleString;
}

+ (NSData *)scaledJPEGImageDataFromImage:(UIImage *)originalImage maxSize:(CGFloat)size quality:(CGFloat)quality {
    UIImage *scaledImage;
    if (originalImage.size.width < size && originalImage.size.height < size) {
        scaledImage = originalImage;
    } else {
        CGFloat aspect = originalImage.size.width / originalImage.size.height;
        CGSize newSize;
        
        if (originalImage.size.width > originalImage.size.height) {
            newSize = CGSizeMake(size, size / aspect);
        } else {
            newSize = CGSizeMake(size * aspect, size);
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
        CGRect newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
        [originalImage drawInRect:newImageRect];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return UIImageJPEGRepresentation(scaledImage, quality);
}

+ (void)showAlertWithText:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:text delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text otherButton:(NSString *)otherButton withCompletion:(SimpleCompletionBlock)completion {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:otherButton, nil];
    alertView.tag = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    
    alertDone = ^(BOOL otherButtonPressed) {
        if (completion) {
            completion(otherButtonPressed, nil);
        }
    };
}

#pragma mark AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertDone(buttonIndex == alertView.cancelButtonIndex ? NO : YES);
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    alertDone(NO);
}

+ (BOOL)validateEmail:(NSString *)email {
    if (email.length > 0) {
        NSString *emailRegex =  @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:email];
    }
    return NO;
}

+ (BOOL)validatePhone:(NSString *)phone {
    if (phone.length > 0) {
        NSString *phoneRegex = @"[0-9]{6,14}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
        return [phoneTest evaluateWithObject:phone];
    }
    return NO;
}

+ (BOOL)validatePassword:(NSString *)password {
    if (password.length >= 6 && password.length <= 14) {
        return YES;
    }
    return NO;
}

@end
