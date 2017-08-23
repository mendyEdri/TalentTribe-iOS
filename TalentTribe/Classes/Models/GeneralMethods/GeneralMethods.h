//
//  GeneralMethods.h
//  justMet
//
//  Created by asi on 12/29/14.
//  Copyright (c) 2014 hive-Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "AppDelegate.h"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>

@protocol GeneralMethodDelegate <NSObject>

@optional

-(void)loadingIsDoneWithSuccess:(BOOL)success;

@end

static UIView *loadingView;
static NSTimer *loadingTimer;

@interface GeneralMethods : NSObject

+(int)generateRandom_Int_From : (int)min To :(int)max;
+(float)generateRandom_Float_FromZeroToOne;
+(void)vibrateDevice;
+(void)sleepWithTime : (float)time;
+(void)hideAndShowViewAnimated : (UIView *)view WithTime : (float)time;
+(UIColor *)colorWithRed:(float)red green:(float)green blue:(float)blue;
+(void)createCircleImageView : (UIImageView *)image;
+(NSMutableDictionary *)getDictionaryWithAllFilesWithPrefix : (NSString *)prefix fileType : (NSString *)type;
+(NSMutableArray *)getArrayWithAllFilesWithPrefix : (NSString *)prefix fileType : (NSString *)type;
+ (NSString *)createUniqueIdentifier;
+(UIButton *)createButtonFrame : (CGRect)frame backgroundColor: (UIColor *)backgroundColor imageName: (NSString *)imageName text : (NSString *)text textColor : (UIColor *)textColor target : (id)target selector : (SEL)selector tag:(NSInteger)tag addToView: (UIView *)parent;
+(void)moveView: (UIView *)view1 toTheCenterOfView: (UIView *)view2;
+(void)moveView: (UIView *)view1 toThe_Xpos_CenterOfView: (UIView *)view2;
+(void)moveView: (UIView *)view1 toThe_Ypos_CenterOfView: (UIView *)view2;
+(BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2;
+(void)setLineSpacingForTextView : (UITextView *)textView withLineHeight : (int)height;
+(UILabel *)createLableWithText : (NSString *)text withFrame : (CGRect)frame withTextColor : (UIColor*)color withFontSize : (int)fontSize withAlignmentCenter : (BOOL)AlignmentCenter boldText : (BOOL)bold fromCharNumber: (int)location length: (int)length withFontName : (NSString *)fontName addToView: (UIView *)parent;
+(void)setColorToPartOfUILabe:(UILabel *)label fromCharNum:(int)charNum textLength:(int)textLength color:(UIColor *)color;
+(void)scrollToLastItemAtCollectionView:(UICollectionView *)collectionView toPosition:(NSString *)position animated:(BOOL)animated;
+(int)getNumberOfCellesInTableView:(UITableView *)tableView;
+(BOOL)array:(NSMutableArray *)arr1 equalToArray:(NSMutableArray *)arr2;
+(void)changeSizeThatFitsForTextView:(UITextView *)textView;
+(UITextView *)createTextViewWithText: (NSString *)text textColor: (UIColor *)color frame:(CGRect)frame editable:(BOOL)editable withLineSpace:(int)lineSpace withAlignmentCenter: (BOOL)AlignmentCenter alpha:(CGFloat)alpha fontSize:(int)fontSize addToView:(UIView *)view;
+(NSString *)upperCaseFirstCharOfString:(NSString *)str;
+(UIImageView *)setBackgroundImageWithImageName : (NSString *)imageName toView : (UIView *)parent;
+(void)updateScrollViewY_ContentSize:(UIScrollView *)scrollView;
+(UIView *)setBackgroundWithColor : (UIColor *)color ToView : (UIView *)view withAlpha : (CGFloat)alpha;
+(void)setNew_Xpos : (CGFloat)xPos ToView : (UIView *)view;
+(void)setNew_Ypos : (CGFloat)yPos ToView : (UIView *)view;
+(void)setNew_width : (CGFloat)width ToView : (UIView *)view;
+(void)setNew_height : (CGFloat)height ToView : (UIView *)view;
+(void)setNew_origin_WithXpos : (CGFloat)xPos andYpos : (CGFloat)yPos ToView : (UIView *)view;
+(void)setNew_Size_WithWidth : (CGFloat)width andHeight : (CGFloat)height ToView : (UIView *)view;
+(UIView *)createViewWithFrame : (CGRect)frame backgroundColor: (UIColor *)color circleView: (BOOL)circle alpha:(CGFloat)alpha cornerSize: (CGFloat)corners borderWidth:(CGFloat)borderWidth borderColor : (UIColor *)borderColor addToView: (UIView *)parent;
+(void)moveView:(UIView *)firstView toEqual_Y_CenterOfView: (UIView *)secondView;
+(void)moveView:(UIView *)firstView toEqual_X_CenterOfView: (UIView *)secondView;
+(void)moveView:(UIView *)firstView toEqualCenterOfView: (UIView *)secondView;
+(UIImageView *)createImageViewWithImageName : (NSString *)imageName withFrame : (CGRect) frame withScaleAspectFit : (bool)scaleAspectFit circleImage : (BOOL)circle addAsSubviewOf : (UIView *)parent;
+(UIImageView *)createImageViewWithImage: (UIImage *)theImage withFrame : (CGRect) frame withScaleAspectFit : (bool)scaleAspectFit circleImage : (BOOL)circle addAsSubviewOf : (UIView *)parent;
+(void)changeColorToTextObject : (UITextView *)textView ToColor : (UIColor *)color FromLocation : (int)location length : (int)length;
+(void)createCircleView : (UIView *)view;
+(void)showAndhideStatusBarWithBool :(BOOL)flag;
+(void)preferredStatusBarStyleColor;
+(UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;
+(UIImage*)resizeImage:(UIImage*)sourceImage scaledToHeight: (float) height;
+(CGSize)returnScaledSizeFromSourceImage :(UIImage*)sourceImage scaledToHeight: (float) height;
+ (void)snapshotImageForVideo:(AVAsset *)asset completion:(SimpleResultBlock)completion;
+(NSString*)languageDetectedWithString :(NSString*)string;
+(BOOL)theDate:(NSDate *)date1 isNewerThan: (NSDate *)date2;
+(UIImage*)resizeImage:(UIImage*)sourceImage scaledToWidth: (float) width;
+(NSArray *)splitTheString:(NSString *)string toArrayByWord:(NSString *)splitKey caseSensitive:(BOOL)caseSensitive;
+(NSArray *)splitTheString:(NSString *)string toArrayByLetter:(NSString *)splitKey caseSensitive:(BOOL)caseSensitive;
+(NSString *)uppercaseTheFirstLetterOfString : (NSString *)string;
+(void)saveImageToFile:(UIImage *)image withName: (NSString *)imageName;
+(UIImage *)loadImageFromFileWithName: (NSString *)imageName;
+(int)getCurrentTimeSecondsFromNSDate : (NSDate *)date;
+(int)getCurrentTimeMinutesFromNSDate : (NSDate *)date;
+(int)getCurrentTimeHoursFromNSDate : (NSDate *)date;
+(void)removeImageFromFileWithName : (NSString *)imageName;
+(UIViewController *)getTopViewController;
+(UIViewController *)topViewController:(UIViewController *)rootViewController;
+(NSString *)getCurrentCountryName;
+(UIStoryboard *)getStoryboardByName:(NSString *)storyboardName;
+(NSLocale *)getCurrentLocale;
+(UIView *)createBreakLineToView:(UIView *)view yPos:(CGFloat)yPos height:(CGFloat)height color:(UIColor *)color alpha:(CGFloat)alpha;
+(BOOL)validateEmail:(NSString *)candidate;
+(int)getNumberOfOccurrencesOfCharacter:(NSString *)theChar inString:(NSString *)theString;
+(void)copyToClipboard:(NSString *)theString;
+(void)showAlertOfSomethingWentWrong;
+(UIImage *)autoRotateImageAndScale:(UIImage *)image;
+(void)showAlertWithTitle:(NSString *)title withAlert:(NSString *)theAlert;
+(void)sortArray: (NSArray *)unSortedArr ByParameterName : (NSString *)param;
+(void)reverseArray : (NSMutableArray *)array;
+(NSString *)removeAllSpeacialCharsNumbersAndSpacesFromString : (NSString *)string;
+(NSString *)replaceString : (NSString *)oldString withString : (NSString *)newString insideString : (NSString *)string;
+(UIAlertController *)showAlertControllerWithSingleButtonTitle:(NSString *)buttonName title:(NSString *)title onController:(UIViewController *)controller buttonClicked:(void (^)(bool clicked))buttonClicked;
+(NSInteger)getNumberOfLinesOfUITextView:(UITextView *)textView;
+(UILabel *)createDynamicLableForString : (NSString *)string withHight : (int)height;
+(UILabel *)createDynamicLableWithText: (NSString *)string xPos:(CGFloat)xPos yPos:(CGFloat)yPos fontSize: (float)fontSize textColor: (UIColor *)color fontName : (NSString *)fontName addToView : (UIView *)parent;
+(UIImage *)centerMaxSquareImageByCroppingImage:(UIImage *)image;
+(BOOL)theWord : (NSString *)word existInTheString : (NSString *)string caseSensitive:(BOOL)sensitive;
+(NSMutableDictionary *)load_JSON_FileToDictionaryWithFileName:(NSString *)name;
+(NSString *)removeNumberOfChars : (int)numberOfChars fromTheEndOfTheString : (NSString *)string;
+(NSString *)removeFirstNumberOfChars : (int)numberOfChars fromTheTheString : (NSString *)string;
+(NSString *)getLastCharOfString : (NSString *)string;
+(NSString *)getLastNumberOfChars : (int)numberOfChars OfString : (NSString *)string;
+(NSInteger)getAgeFromBirthday : (NSDate *)birthday;
+(NSString *)getFirstCharOfString : (NSString *)string;
+(NSString *)getFirstNumberOfChars : (int)num fromString : (NSString *)string;
+(NSDate *)convertStringToNSDate : (NSString *)string;
+(NSString *)removeSpaceCharFromString : (NSString *)string;
+(NSString *)converImageToBase64String:(UIImage *)image;
+(NSString *)convertNSDateToString : (NSDate *)date;
+(UIImage*) blurImage:(UIImage*)theImage withStrength : (float)strength;
+(void)spinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
+(void)getDataFromUrl:(NSURL *)url inBackground:(BOOL)inBackground completionHandler:(void(^)(NSData *responseData, NSError *error))completion;
+(void)printTheTypeOfIphone;
+(float)getCalculateSizeWithScreenSize :(float)screenSize AndElementSize :(float)size;
+ (NSDictionary *)screenSizeDict;
+ (NSString *)sha1FromString:(NSString *)plainString;
+(BOOL)fileExistAtPath:(NSString *)path;
@end
