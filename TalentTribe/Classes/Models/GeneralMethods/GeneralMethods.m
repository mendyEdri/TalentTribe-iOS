//
//  GeneralMethods.m
//  justMet
//
//  Created by asi on 12/29/14.
//  Copyright (c) 2014 hive-Networks. All rights reserved.
//

#import "GeneralMethods.h"

@implementation GeneralMethods

+(int)generateRandom_Int_From : (int)min To :(int)max
{
    return ((arc4random() % (max - min + 1)) + min);
}

+(float)generateRandom_Float_FromZeroToOne
{
    #define ARC4RANDOM_MAX 0x100000000
    return ((double)arc4random() / ARC4RANDOM_MAX);
}

+(void)vibrateDevice
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); // vibrate device
}

+(void)sleepWithTime : (float)time
{
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:time]];
}

+(void)hideAndShowViewAnimated : (UIView *)view WithTime : (float)time
{
    // if the view if hidden -> show it -> -> otherwise -> hide it
    
    int alpha = 0;
    if (view.alpha == 0)
    {
        alpha = 1;
    }
    [UIView animateWithDuration:time animations:^
     {
         view.alpha = alpha;
     }
      completion:nil];
}

+(UIColor *)colorWithRed:(float)red green:(float)green blue:(float)blue
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}


+(void)createCircleImageView : (UIImageView *)image
{
    image.layer.cornerRadius = image.frame.size.height / 2;
    image.layer.masksToBounds = YES;
    image.layer.borderWidth = 0;
    image.contentMode = UIViewContentModeScaleAspectFill;
}

+(NSMutableDictionary *)getDictionaryWithAllFilesWithPrefix : (NSString *)prefix fileType : (NSString *)type
{
    NSMutableDictionary *Dic = [[NSMutableDictionary alloc]init];
    [[[NSBundle mainBundle] pathsForResourcesOfType:type inDirectory:nil] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
     {
         NSString *path = [obj lastPathComponent];
         if ([path hasPrefix:prefix])
         {
             [Dic setObject:[UIImage imageNamed:path] forKey:path];
         }
     }];
    
    return Dic;
}

+(NSMutableArray *)getArrayWithAllFilesWithPrefix : (NSString *)prefix fileType : (NSString *)type
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    [[[NSBundle mainBundle] pathsForResourcesOfType:type inDirectory:nil] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
     {
         NSString *path = [obj lastPathComponent];
         if ([path hasPrefix:prefix])
         {
             [result addObject:[UIImage imageNamed:path]];
         }
     }];
    
    return result;
}

+ (NSString *)createUniqueIdentifier
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

+(UIButton *)createButtonFrame : (CGRect)frame backgroundColor: (UIColor *)backgroundColor imageName: (NSString *)imageName text : (NSString *)text textColor : (UIColor *)textColor target : (id)target selector : (SEL)selector tag:(NSInteger)tag addToView: (UIView *)parent
{
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    if (text)
    {
        [button setTitle:text forState:UIControlStateNormal];
        [button setTitleColor:textColor forState:UIControlStateNormal];
    }
    if (backgroundColor)
    {
        [button setBackgroundColor:backgroundColor];
    }
    
    if (imageName)
    {
        [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    if (parent)
    {
        [parent addSubview:button];
    }
    
    if(selector)
    {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (tag)
    {
        button.tag = tag;
    }
    
    return button;
}

+(void)moveView: (UIView *)view1 toTheCenterOfView: (UIView *)view2
{
    view1.center = CGPointMake(view2.frame.size.width / 2, view2.frame.size.height / 2);
}

+(void)moveView: (UIView *)view1 toThe_Xpos_CenterOfView: (UIView *)view2
{
    view1.center = CGPointMake(view2.frame.size.width / 2, view1.center.y);
}

+(void)moveView: (UIView *)view1 toThe_Ypos_CenterOfView: (UIView *)view2
{
    view1.center = CGPointMake(view1.center.x, view2.frame.size.height / 2);
}

+(BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    if (image1 == NO && image2 == NO)
    {
        return YES;
    }
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}


+(void)setLineSpacingForTextView : (UITextView *)textView withLineHeight : (int)height
{
    BOOL deleteChar = NO;
    if (textView.text.length < 1)
    {
        [textView setText:@" "]; // bug fix
        deleteChar = YES;
    }
    
    NSString *theText = textView.text;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = height;
    textView.attributedText = [[NSAttributedString alloc] initWithString:theText attributes:@{NSParagraphStyleAttributeName : style}];
    if (deleteChar)
    {
        [textView setText:@""];
    }
    textView.text = theText;
}

+(UILabel *)createLableWithText : (NSString *)text withFrame : (CGRect)frame withTextColor : (UIColor*)color withFontSize : (int)fontSize withAlignmentCenter : (BOOL)AlignmentCenter boldText : (BOOL)bold fromCharNumber: (int)location length: (int)length withFontName : (NSString *)fontName addToView: (UIView *)parent
{
    // add number of lines
    
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setText:text];
    [label setTextColor:color];
    label.font = [label.font fontWithSize:fontSize];
    
    if (fontName)
    {
        [label setFont:[UIFont fontWithName:fontName size:fontSize]];
    }
    
    if (AlignmentCenter)
    {
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    if (bold)
    {
        if (location == 0 && length == 0)
        {
            length = (int)text.length;
        }
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
        
        NSString * originalFontName = [[GeneralMethods splitTheString:fontName toArrayByLetter:@"-" caseSensitive:NO]objectAtIndex:0];
        NSString * fontNameBold = [NSString stringWithFormat:@"%@-Bold",originalFontName];
        UIFont * font = [UIFont fontWithName:fontNameBold size:fontSize];
        
        if (font)
        {
            [str addAttribute:NSFontAttributeName value:font range:NSMakeRange(location, length)];
            label.attributedText = str;
        }
        else
        {
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize] range:NSMakeRange(location, length)];
        }
        label.attributedText = str;
    }
    
    if (parent)
    {
        [parent addSubview:label];
    }
    return label;
}

+(UIStoryboard *)getStoryboardByName:(NSString *)storyboardName
{
    return [UIStoryboard storyboardWithName:storyboardName bundle: nil];
}

+(BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+(void)setColorToPartOfUILabe:(UILabel *)label fromCharNum:(int)charNum textLength:(int)textLength color:(UIColor *)color
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: label.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(charNum, textLength)];
    [label setAttributedText: text];
}

+(int)getNumberOfCellesInTableView:(UITableView *)tableView
{
    int sections = (int)[tableView numberOfSections];
    
    int rows = 0;
    
    for(int i=0; i < sections; i++)
    {
        rows += [tableView numberOfRowsInSection:i];
    }
    return rows;
}

+(BOOL)array:(NSMutableArray *)arr1 equalToArray:(NSMutableArray *)arr2
{
    NSSet *set1 = [NSSet setWithArray:arr1];
    NSSet *set2 = [NSSet setWithArray:arr2];
    
    return [set1 isEqualToSet:set2];
}

+(void)changeSizeThatFitsForTextView:(UITextView *)textView
{
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
    
    [GeneralMethods setNew_height:textViewSize.height ToView:textView];
}


+(UITextView *)createTextViewWithText: (NSString *)text textColor: (UIColor *)color frame:(CGRect)frame editable:(BOOL)editable withLineSpace:(int)lineSpace withAlignmentCenter: (BOOL)AlignmentCenter alpha:(CGFloat)alpha fontSize:(int)fontSize addToView:(UIView *)view
{
    UITextView *textView = [[UITextView alloc]initWithFrame:frame];
    
    if (text)
    {
        [textView setText:text];
    }
    
    if (color)
    {
        [textView setTextColor:color];
    }
    
    if (editable == NO)
    {
//        textView.userInteractionEnabled = NO;
        textView.editable = NO;
    }
    else
    {
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    if (lineSpace > 0)
    {
        [GeneralMethods setLineSpacingForTextView:textView withLineHeight:lineSpace];
    }
    
    if (AlignmentCenter)
    {
        textView.textAlignment = NSTextAlignmentCenter;
    }
    
    [textView setAlpha:alpha];
    
    if (fontSize)
    {
        textView.font = [textView.font fontWithSize:fontSize];
    }
    
    if (view)
    {
        [view addSubview:textView];
    }
    return textView;
}

+(NSString *)upperCaseFirstCharOfString:(NSString *)str
{
    if (str && str.length > 0)
    {
        return [str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[str substringToIndex:1] capitalizedString]];
    }
    return @"";
}


+(UIImageView *)setBackgroundImageWithImageName : (NSString *)imageName toView : (UIView *)parent
{
    return [GeneralMethods createImageViewWithImageName:imageName withFrame:CGRectMake(0, 0, parent.frame.size.width, parent.frame.size.height) withScaleAspectFit:NO circleImage:NO addAsSubviewOf:parent];
}


+(void)updateScrollViewY_ContentSize:(UIScrollView *)scrollView
{
    CGFloat maxYpos = 0;
    for (UIView *view in [scrollView subviews])
    {
        if (CGRectGetMaxY(view.frame) > maxYpos)
        {
            maxYpos = CGRectGetMaxY(view.frame);
        }
    }
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, maxYpos + 10)];
}

+(UIView *)setBackgroundWithColor : (UIColor *)color ToView : (UIView *)view withAlpha : (CGFloat)alpha
{
    UIView *blackBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    [blackBackground setBackgroundColor:color];
    [blackBackground setAlpha:alpha];
    blackBackground.userInteractionEnabled = NO;
    [view addSubview:blackBackground];
    return blackBackground;
}

+(void)setNew_Xpos : (CGFloat)xPos ToView : (UIView *)view
{
    [view setFrame:CGRectMake(xPos, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
}

+(void)setNew_Ypos : (CGFloat)yPos ToView : (UIView *)view
{
    [view setFrame:CGRectMake(view.frame.origin.x, yPos, view.frame.size.width, view.frame.size.height)];
}

+(void)setNew_width : (CGFloat)width ToView : (UIView *)view
{
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height)];
}

+(void)setNew_height : (CGFloat)height ToView : (UIView *)view
{
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height)];
}

+(void)setNew_origin_WithXpos : (CGFloat)xPos andYpos : (CGFloat)yPos ToView : (UIView *)view
{
    [view setFrame:CGRectMake(xPos, yPos, view.frame.size.width, view.frame.size.height)];
}

+(void)setNew_Size_WithWidth : (CGFloat)width andHeight : (CGFloat)height ToView : (UIView *)view
{
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height)];
}


+(UIView *)createViewWithFrame : (CGRect)frame backgroundColor: (UIColor *)color circleView: (BOOL)circle alpha:(CGFloat)alpha cornerSize: (CGFloat)corners borderWidth:(CGFloat)borderWidth borderColor : (UIColor *)borderColor addToView: (UIView *)parent
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    if (color)
    {
        [view setBackgroundColor:color];
    }
    
    [view setAlpha:alpha];
    
    if (circle)
    {
        [GeneralMethods createCircleView:view];
    }
    
    if (corners)
    {
        [view.layer setCornerRadius:corners];
    }
    
    if (borderWidth)
    {
        [view.layer setBorderWidth:borderWidth];
        [view.layer setBorderColor:borderColor.CGColor];
    }
    
    if (parent)
    {
        [parent addSubview:view];
    }
    
    return view;
}

+(void)moveView:(UIView *)firstView toEqual_Y_CenterOfView: (UIView *)secondView
{
    firstView.center = CGPointMake(firstView.center.x, secondView.center.y);
}

+(void)moveView:(UIView *)firstView toEqual_X_CenterOfView: (UIView *)secondView
{
    firstView.center = CGPointMake(secondView.center.x, firstView.center.y);
}

+(void)moveView:(UIView *)firstView toEqualCenterOfView: (UIView *)secondView
{
    firstView.center = CGPointMake(secondView.center.x, secondView.center.y);
}


+(UIImageView *)createImageViewWithImageName : (NSString *)imageName withFrame : (CGRect) frame withScaleAspectFit : (bool)scaleAspectFit circleImage : (BOOL)circle addAsSubviewOf : (UIView *)parent
{
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [image setFrame:frame];
    if (scaleAspectFit)
    {
        image.contentMode = UIViewContentModeScaleAspectFit;
    }
    if (circle)
    {
        [GeneralMethods createCircleView:image];
    }
    
    if (parent)
    {
        [parent addSubview:image];
    }
    
    return image;
}

+(UIImageView *)createImageViewWithImage: (UIImage *)theImage withFrame : (CGRect) frame withScaleAspectFit : (bool)scaleAspectFit circleImage : (BOOL)circle addAsSubviewOf : (UIView *)parent
{
    UIImageView *image = [[UIImageView alloc]initWithImage:theImage];
    [image setFrame:frame];
    if (scaleAspectFit)
    {
        image.contentMode = UIViewContentModeScaleAspectFit;
    }
    if (circle)
    {
        [GeneralMethods createCircleView:image];
    }
    
    if (parent)
    {
        [parent addSubview:image];
    }
    
    return image;
}


+(void)changeColorToTextObject : (UITextView *)textView ToColor : (UIColor *)color FromLocation : (int)location length : (int)length
{
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: textView.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:color
                 range:NSMakeRange(location, length)];
    [textView setAttributedText: text];
}

+(void)createCircleView : (UIView *)view
{
    view.layer.cornerRadius = view.frame.size.height / 2;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 0;
    view.contentMode = UIViewContentModeScaleAspectFill;
}

+(void)showAndhideStatusBarWithBool :(BOOL)flag
{
    [[UIApplication sharedApplication] setStatusBarHidden:flag];
}

+(void)preferredStatusBarStyleColor
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

+(UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize
{
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+(UIImage*)resizeImage:(UIImage*)sourceImage scaledToHeight: (float) height
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = height / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(CGSize)returnScaledSizeFromSourceImage :(UIImage*)sourceImage scaledToHeight: (float) height
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = height / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    return CGSizeMake(newWidth, newHeight);
}


+ (void)snapshotImageForVideo:(AVAsset *)asset completion:(SimpleResultBlock)completion {
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *error;
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), thumb);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (completion) {
        completion(image, nil);
    }
}

+(NSString*)languageDetectedWithString :(NSString*)string
{
    if ([string isEqualToString:@""])
    {
        return @"";
    }
    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    
    [tagger setString:string];
    
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    
    return language;
    
}

+(BOOL)theDate:(NSDate *)date1 isNewerThan: (NSDate *)date2
{
    if ([date1 compare:date2] == NSOrderedDescending)
    {
        return YES;
    }
    else if ([date1 compare:date2] == NSOrderedAscending)
    {
        return NO;
    }
    else
    {
        return NO;
    }
}

+(UIImage*)resizeImage:(UIImage*)sourceImage scaledToWidth: (float) width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(NSArray *)splitTheString:(NSString *)string toArrayByWord:(NSString *)splitKey caseSensitive:(BOOL)caseSensitive
{
    if (caseSensitive)
    {
        string = [string lowercaseString];
        splitKey = [string lowercaseString];
    }
    return [string componentsSeparatedByString:splitKey];
}


+(NSArray *)splitTheString:(NSString *)string toArrayByLetter:(NSString *)splitKey caseSensitive:(BOOL)caseSensitive
{
    if (caseSensitive)
    {
        string = [string lowercaseString];
        splitKey = [string lowercaseString];
    }
    
    return [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:splitKey]];
}

+(NSString *)uppercaseTheFirstLetterOfString : (NSString *)string
{
    return [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]];
}


+(void)saveImageToFile:(UIImage *)image withName: (NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePahe = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSData *binaryImageData = UIImagePNGRepresentation(image);
    [binaryImageData writeToFile:[basePahe stringByAppendingPathComponent:[imageName mutableCopy]]  atomically:YES];
}

+(UIImage *)loadImageFromFileWithName: (NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if (!image)
    {
        image = [UIImage new];
    }
    return image;
}

+(int)getCurrentTimeSecondsFromNSDate : (NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitSecond) fromDate:[NSDate date]];
    return (int)[components second];
}

+(int)getCurrentTimeMinutesFromNSDate : (NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitMinute) fromDate:[NSDate date]];
    return (int)[components minute];
}

+(int)getCurrentTimeHoursFromNSDate : (NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour) fromDate:[NSDate date]];
    return (int)[components hour];
}

+(void)removeImageFromFileWithName : (NSString *)imageName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:imageName];
    
    [manager removeItemAtPath:path error:&error];
    
}


+(UIViewController *)getTopViewController
{
    return [GeneralMethods topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+(UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}


#pragma mark Locations

+(NSString *)getCurrentCountryName
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    
    return country;
}

+(NSLocale *)getCurrentLocale
{
   return [NSLocale currentLocale];
}

+(UIView *)createBreakLineToView:(UIView *)view yPos:(CGFloat)yPos height:(CGFloat)height color:(UIColor *)color alpha:(CGFloat)alpha
{
    return [GeneralMethods createViewWithFrame:CGRectMake(0, yPos, view.frame.size.width, height) backgroundColor:color circleView:NO alpha:alpha cornerSize:0 borderWidth:0 borderColor:0 addToView:view];
}


+(int)getNumberOfOccurrencesOfCharacter:(NSString *)theChar inString:(NSString *)theString
{
    return (int)([[theString componentsSeparatedByString:theChar] count] - 1);
}

+(void)copyToClipboard:(NSString *)theString
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = theString;
}

+(void)showAlertOfSomethingWentWrong
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong..." message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

+(void)showAlertWithTitle:(NSString *)title withAlert:(NSString *)theAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:theAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


+(void)sortArray: (NSArray *)unSortedArr ByParameterName : (NSString *)param
{
    NSMutableArray *arrCopy = [[NSMutableArray alloc]initWithArray:unSortedArr];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:param ascending:TRUE];
    [arrCopy sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]; // sorting all the messages by date
}

+(void)reverseArray : (NSMutableArray *)array
{
    if ([array count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [array count] - 1;
    while (i < j)
    {
        [array exchangeObjectAtIndex:i
                   withObjectAtIndex:j];
        i++;
        j--;
    }
}

+(NSString *)removeAllSpeacialCharsNumbersAndSpacesFromString : (NSString *)string
{
    return [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

+(NSString *)replaceString : (NSString *)oldString withString : (NSString *)newString insideString : (NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:oldString withString:newString];
}

+(UILabel *)createDynamicLableForString : (NSString *)string withHight : (int)height
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5 ,height)];
    label.text = string;
    
    CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    
    CGFloat strikeWidth = textSize.width;
    
    [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, strikeWidth + 1, label.frame.size.height)];
    
    return label;
}

+(UILabel *)createDynamicLableWithText: (NSString *)string xPos:(CGFloat)xPos yPos:(CGFloat)yPos fontSize: (float)fontSize textColor: (UIColor *)color fontName : (NSString *)fontName addToView : (UIView *)parent
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0 ,0)];
    label.text = string;
    [label setTextColor:color];
    
    if (fontName)
    {
        [label setFont:[UIFont fontWithName:fontName size:fontSize]];
    }
    else
    {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    
    [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, textSize.width + 1, textSize.height + 1)];
    
    if (parent)
    {
        [parent addSubview:label];
    }
    
    [GeneralMethods setNew_origin_WithXpos:xPos andYpos:yPos ToView:label];
    
    return label;
}

+(BOOL)theWord : (NSString *)word existInTheString : (NSString *)string caseSensitive:(BOOL)sensitive
{
    if (!word || !string)
    {
        return NO;
    }
    
    if (!sensitive)
    {
        word = [word lowercaseString];
        string = [string lowercaseString];
    }
    
    if ([string rangeOfString:word].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+(NSMutableDictionary *)load_JSON_FileToDictionaryWithFileName:(NSString *)name
{
    NSError *deserializingError;
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializingError];
}



+(NSString *)removeNumberOfChars : (int)numberOfChars fromTheEndOfTheString : (NSString *)string
{
    if ([string length] > numberOfChars)
    {
        string = [string substringToIndex:[string length] - numberOfChars];
    }
    return string;
}

+(NSInteger)getNumberOfLinesOfUITextView:(UITextView *)textView
{
    NSString *text = textView.text;
    NSArray *array = [text componentsSeparatedByString:@"\n"];
    return array.count;
}

+(NSString *)removeFirstNumberOfChars : (int)numberOfChars fromTheTheString : (NSString *)string
{
    if ([string length] > numberOfChars)
    {
        string = [string substringFromIndex:numberOfChars];
    }
    return string;
}

+(UIAlertController *)showAlertControllerWithSingleButtonTitle:(NSString *)buttonName title:(NSString *)title onController:(UIViewController *)controller buttonClicked:(void (^)(bool clicked))buttonClicked
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonName style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        if (buttonClicked)
                                        {
                                            buttonClicked(YES);
                                        }}];
    
    [alert addAction:defaultAction];
    [controller presentViewController:alert animated:YES completion:^{}];
    return alert;
}

+(BOOL)fileExistAtPath:(NSString *)path
{
    return ([[NSFileManager defaultManager] fileExistsAtPath:path]);
}

+(UIImage *)centerMaxSquareImageByCroppingImage:(UIImage *)image
{
    CGSize centerSquareSize;
    double oriImgWid = CGImageGetWidth(image.CGImage);
    double oriImgHgt = CGImageGetHeight(image.CGImage);
    if(oriImgHgt <= oriImgWid) {
        centerSquareSize.width = oriImgHgt;
        centerSquareSize.height = oriImgHgt;
    }else {
        centerSquareSize.width = oriImgWid;
        centerSquareSize.height = oriImgWid;
    }
    
    
    double x = (oriImgWid - centerSquareSize.width) / 2.0;
    double y = (oriImgHgt - centerSquareSize.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, centerSquareSize.height, centerSquareSize.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return cropped;
}

+(NSString *)converImageToBase64String:(UIImage *)image
{
    return [[TTUtils scaledJPEGImageDataFromImage:image maxSize:kImageMaxSize quality:kImageQuality] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+(void)getDataFromUrl:(NSURL *)url inBackground:(BOOL)inBackground completionHandler:(void(^)(NSData *responseData, NSError *error))completion
{
    void (^getData)() = ^
    {
        NSURLRequest *postRequest = [NSURLRequest requestWithURL:url];
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
        
        completion(data, error);
    };
    
    if (inBackground)
    {
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(backgroundQueue,^{
            getData();
        });
    }
    else
    {
        getData();
    }
}
+(NSString *)getLastCharOfString : (NSString *)string
{
    NSString *lastChar;
    
    if([string length] > 0)
    {
        lastChar = [string substringFromIndex:[string length] - 1];
    }
    return lastChar;
}

+(NSString *)getLastNumberOfChars : (int)numberOfChars OfString : (NSString *)string
{
    NSString *lastChar;
    
    if([string length] > 0)
    {
        lastChar = [string substringFromIndex:MAX((int)[string length] - numberOfChars, 0)];
    }
    return lastChar;
}

+(NSInteger)getAgeFromBirthday : (NSDate *)birthday
{
    NSDate *now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthday toDate:now options:0];
    return [ageComponents year];
}


+(NSString *)getFirstCharOfString : (NSString *)string
{
    NSString *firstChar;
    
    if([string length] > 0)
    {
        
        firstChar = [string substringToIndex:1];
    }
    return firstChar;
}

+(NSString *)getFirstNumberOfChars : (int)num fromString : (NSString *)string
{
    NSString *firstChar;
    
    if([string length] >= num)
    {
        firstChar = [string substringToIndex:num];
    }
    return firstChar;
}

+(NSDate *)convertStringToNSDate : (NSString *)string
{
    NSDateFormatter* myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate* myDate = [myFormatter dateFromString:string];
    return myDate;
}


+(NSString *)removeSpaceCharFromString : (NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

+(NSString *)convertNSDateToString : (NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}


+(UIImage*) blurImage:(UIImage*)theImage withStrength : (float)strength
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:strength] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

+(void)spinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)popAnimateView:(UIView *)animateView {
    animateView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    [UIView animateWithDuration:0.3/1.5 animations:^{
        animateView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            animateView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                animateView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

+(UIImage *)autoRotateImageAndScale:(UIImage *)image
{
    int kMaxResolution = 4000;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),      CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+(void)scrollToLastItemAtCollectionView:(UICollectionView *)collectionView toPosition:(NSString *)position animated:(BOOL)animated
{
    NSInteger section = [collectionView numberOfSections] - 1;
    if ([collectionView numberOfItemsInSection:section] == 0)
    {
        return;
    }
    
    NSInteger item  = [collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    
    if ([[position lowercaseString] isEqualToString:@"left"])
    {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
    }
    else if ([[position lowercaseString] isEqualToString:@"right"])
    {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:animated];
    }
    else if ([[position lowercaseString] isEqualToString:@"up"] || [[position lowercaseString] isEqualToString:@"top"])
    {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
    else if ([[position lowercaseString] isEqualToString:@"down"] || [[position lowercaseString] isEqualToString:@"bottom"])
    {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
    }
}

+(void)printTheTypeOfIphone
{
    if (isIphone4)
    {
        NSLog(@" is iphone 4");
    }
    else if (isIphone5)
    {
        NSLog(@" is iphone 5 or 5S");
        
    }
    else if (isIphone6)
    {
        NSLog(@" is iphone 6");
        
    }
    
    else if (isIphone6Plus)
    {
        NSLog(@" is iphone 6+");
    }
}

+(float)getCalculateSizeWithScreenSize :(float)screenSize AndElementSize :(float)size
{
    if (screenSize != 568)
    {
        float Percent = size/568;
        
        return Percent * screenSize;

    }
    else
    {
        return size;
    }
    
}

+ (NSDictionary *)screenSizeDict {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGSize screenSize = CGSizeMake(size.width * scale, size.height * scale);
    return @{@"width" : @((int)screenSize.width), @"height" : @((int)screenSize.height)};
}

#pragma mark - Encryption

+ (NSString *)sha1FromString:(NSString *)plainString {
    const char *cStr = [plainString UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (int)strlen(cStr), result);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", result[i]];
    }
    return output;
}

@end