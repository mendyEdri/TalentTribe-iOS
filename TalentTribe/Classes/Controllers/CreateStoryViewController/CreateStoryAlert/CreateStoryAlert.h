//
//  CreateStoryAlert.h
//  TalentTribe
//
//  Created by Asi Givati on 10/22/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EMPTY_PROFILE_ALERT @"Posting stories requires a complete user profile. \nYour profile is empty..."
#define HALF_FILLED_PROFILE_ALERT @"Required fields are missing in your profile, \nPlease update them first."
#define EMAIL_PROCESS_ALERT @"You will post for your company,\nPlease varify your corporate email"
#define CODE_PROCESS_ALERT @"Enter the code sent to you"
#define UPLOAD_COMPLETE_ALERT @"Congratulations! Your story was uploaded successfully."
#define UPLOAD_VIDEO_PROGRESS_MODE @"Uploading Your Video..."
#define UPLOAD_STORY_PROGRESS_MODE @"Uploading Your Story..."
#define CODE_CHARS_LIMIT 4

typedef NS_ENUM(NSUInteger, AlertModes)
{
    resetMode = 0,
    emptyProfileMode = 1,
    halfFilledProfileMode = 2,
    emailProcessMode = 3,
    codeProcessMode = 4,
    uploadCompleteMode = 5,
    uploadVideoProgressMode = 6,
    uploadStoryProgressMode = 7,
    generalAlert = 8
};


@class CreateStoryAlert;

@protocol CreateStoryAlertDelegate <NSObject>
-(void)createStoryAlert:(CreateStoryAlert *)alert closeButtonClicked:(id)sender;
-(void)createStoryAlert:(CreateStoryAlert *)alert emptyOrHalfFilledProfileButtonClicked:(id)sender;
-(void)createStoryAlertDidFinishCodeVerification:(CreateStoryAlert *)alert;
@end

@interface CreateStoryAlert : UIView<UITextFieldDelegate>
//typedef NS_ENUM(NSUInteger, AlertModes);
@property (weak, nonatomic) IBOutlet UIView *alertContainer;
@property (weak, nonatomic) IBOutlet UILabel *alertContainerTitle;
@property (weak, nonatomic) IBOutlet UIButton *alertContainerProcessButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertContainerMovementConstraint;
@property (weak, nonatomic) IBOutlet UIButton *alertContainerBottomButton;
@property (weak, nonatomic) IBOutlet UIView *alertContainerBottomline;
@property (weak, nonatomic) IBOutlet UITextField *alertContainerInputTextField;
@property (weak, nonatomic) IBOutlet UIButton *alertContainerCloseButton;
@property (weak, nonatomic) IBOutlet UIImageView *blurBackgroundImage;
//@property (weak, nonatomic) 
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@property NSUInteger alertMode;
@property (weak, nonatomic) NSString *verificationCode;
@property CGFloat movementConstraintDefaultPosition;
@property (weak, nonatomic) id <CreateStoryAlertDelegate> delegate;

-(void)setNewValueToProgressView:(CGFloat)value;
-(void)animatedContainerAlert;
//-(void)showAlertContainerViewWithTitle:(NSString *)title;
-(void)loadAlertContainerViewWithMode:(AlertModes)mode;
-(void)loadAlertContainerViewWithGeneralAlert:(NSString *)alert showCloseButton:(BOOL)showCloseButton processButtonText:(NSString *)processButtonText;
@end
