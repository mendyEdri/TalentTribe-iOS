//
//  CreateStoryViewController.m
//  TalentTribe
//
//  Created by Asi Givati on 10/28/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "CreateStoryViewController.h"
#import "User.h"
#import "StoryDetailsViewController.h"
#import "DataManager.h"
#import "UserProfileCreateViewController.h"
#import "GeneralMethods.h"
#import "UIImageView+WebCache.h"
#import "UITextView+Placeholder.h"
#import "TTShadowLabel.h"
#import "TTRoundedShadowImageView.h"
#import <CoreMedia/CoreMedia.h>
#import "AAPLPreviewView.h"
#import "StoryCategory.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TalentTribe-Swift.h"
#import "CommManager.h"
#import "AssociateCompanyAlertViewController.h"
#import "CreateViewController.h"

#define CS_STORY_TITLE_TEXT_MAX_LENGTH 30
#define CS_STORY_BODY_TEXT_MAX_LENGTH 10000
#define CS_NUMBER_OF_BUTTONS_BAR 3
#define CS_IMAGE_PLACEHOLDER @"placeHolderImage"
#define CS_IMAGE_URL @"squareCameraImage"
#define CS_MEDIA_CELL_ID @"mediaCell"
#import "AFHTTPRequestOperationManager.h"


@interface CreateStoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate,UITextViewDelegate, AssociateCompanyAlertDelegate>

@property (nonatomic) BOOL shouldCheckUserProfileVerified;
@property (nonatomic) UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBackgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet TTShadowLabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteMediaButton;
@property (strong, nonatomic) AssociateCompanyAlertViewController *alert;


@property (weak, nonatomic) IBOutlet TTRoundedShadowImageView *companyImageView;
@property (strong, nonatomic) Company *company;
@property (strong, nonatomic) Story *currentStory;

@property UIButton *closeKeyboardButton;
//@property CGFloat storyTitleSectionsInitialHeight;
@property BOOL firstRun;
@property BOOL shouldChangeSizeToFit;

#pragma mark Story Title Properties
@property UIView *storyTitleSectionView;
@property CGFloat titleSectionViewInitialYpos;
@property (nonatomic) UITextView *storyTitleTextView;
@property UIView *storyTitleBottomBorder;

#pragma mark Story Body Properties
@property UIView *storyBodySectionView;
@property (nonatomic) UITextView *storyBodyTextView;

#pragma mark Story Tags Properties
//@property (nonatomic) StoryTagsSectionView *storyTagsSectionView; - another version
@property (nonatomic) TTTagList *storyTagsSectionView;

/// will tell the offset scrollview should set or not the header background image
@property CGFloat scrollViewOffsetToChange;
@property CGFloat textViewWidth;
@property (weak, nonatomic) IBOutlet UIView *buttonsBar;

@property (nonatomic) UIView *lastViewBottomBorder;
@property (nonatomic) UIView *progressView;

@end

@implementation CreateStoryViewController

#pragma mark lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    self.firstRun = (!self.textViewWidth || self.textViewWidth == 0);
    [self registerForKeyboardNotifications];
    BOOL shouldSkipUserProfileVerified = NO;
    
    if (![self userIsRegistered]) {
        shouldSkipUserProfileVerified = YES;
        if (self.firstRun) {
            // when user not registered & login screen should appear
            self.view.userInteractionEnabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [self showLoginScreen];
            });
        } else {
             // when back from login screen by "Cancel"
#warning #mendy: this is not the only option, if you select camera and hit 'Cancel' it still came here
            
#if DEBUG

#else
[self dismissViewControllerAnimated:NO completion:nil];
#endif
            
        }
    } else {
        [self closeButtonsBar];
        [self loadContent];
    }
    
    if (!shouldSkipUserProfileVerified)  {
        if (![self userProfileVerified]) {
            return;
        }
    }
    
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    
    if (self.firstRun) {
        self.textViewWidth = CGRectGetWidth(self.mainScrollView.frame) - (CS_PAGE_BORDERS * 2);
        [self setViews];
        [self setGeneralProperties];
    }
}

- (void)progressWithPercent:(double)percent {
    if (!self.progressView) {
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 10)];
        self.progressView.backgroundColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0];
        [self.view addSubview:self.progressView];
    }
    
    @synchronized(self) {
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) * percent, 10);
        }];
    }
}

-(BOOL)userIsRegistered
{
    return [DataManager sharedManager].isCredentialsSavedInKeychain;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.firstRun)
    {
        if (self.storyTitleTextView) // when the user is not verified storyTitleTextView == nil
        {
            [self.storyTitleTextView setScrollEnabled:NO];
            [self.storyBodyTextView setScrollEnabled:NO];
            if ([self userIsRegistered])
            {
                [self.storyTitleTextView becomeFirstResponder];
            }
        }
    }
    
    if (self.createStoryAlert && [self.createStoryAlert isHidden] == NO && [self.createStoryAlert.alertContainerInputTextField isHidden] == NO)
    {
        // When the CreateStoryViewController appear with alert
        [self.createStoryAlert.alertContainerInputTextField becomeFirstResponder];
    }
}

-(void)showLoginScreen
{
    LoginSelectionViewController *loginController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginController.restorationIdentifier = @"shouldContinueCreateStoryProcess";
    loginController.viewState = ViewStateAction;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [navController setNavigationBarHidden:YES];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)createStoryAlertDidFinishCodeVerification:(CreateStoryAlert *)alert
{
    [self viewWillAppear:NO];
    [self viewDidAppear:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}


- (NSAttributedString *)attributedStringForString:(NSString *)string
{
    if (string && self.companyNameLabel) {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:@{NSForegroundColorAttributeName : self.companyNameLabel.textColor, NSFontAttributeName : self.companyNameLabel.font}];
        return [[NSAttributedString alloc] initWithString:string attributes:attributes];
    } else {
        return nil;
    }
}


#pragma mark Gesture Recognizers

-(void)addGestureRecognizers
{
    UITapGestureRecognizer *tapOnHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.headerView addGestureRecognizer:tapOnHeader];
    
//    UITapGestureRecognizer *tapOnMainScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
//    [self.mainScrollView addGestureRecognizer:tapOnMainScrollView];
    
    UITapGestureRecognizer *tapOnMediaCollectionView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaCollectionViewDidClicked)];
    [self.mediaCollectionView addGestureRecognizer:tapOnMediaCollectionView];
}

-(void)mediaCollectionViewDidClicked
{
    StoryMediaCell *cell = [self getMediaCollectionViewVisibleCell];
    [cell playVideo];
}

#pragma mark Touches

#pragma mark Keyboard Actions

-(void)handleTap
{
    [self scrollToTop];
}

-(void)scrollToTop
{
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self closeKeyboard];
}

-(void)closeKeyboard
{
    [self.view endEditing:YES];
}

- (void)registerForKeyboardNotifications
{
    [self deregisterFromKeyboardNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShown:(NSNotification *)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:duration animations:^
     {
         [self.closeKeyboardButton setAlpha:1];
         CGFloat yPos = CGRectGetHeight(self.view.frame) - keyboardSize.height - CGRectGetHeight(self.buttonsBar.frame);
         [GeneralMethods setNew_Ypos:yPos ToView:self.buttonsBar];
     }];
}

-(void)keyboardWillBeHidden:(NSNotification *)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^
     {
         [self.closeKeyboardButton setAlpha:0];
         [self closeButtonsBar];
     }];
}

-(void)closeButtonsBar
{
    CGFloat yPos = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.buttonsBar.frame);
    [GeneralMethods setNew_Ypos:yPos ToView:self.buttonsBar];
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)setGeneralProperties
{
//    [GeneralMethods createCircleImageView:self.companyImageView];
    self.scrollViewOffsetToChange = CGRectGetWidth(self.mainScrollView.frame) - CGRectGetHeight(self.headerView.frame);
    self.mainScrollView.delegate = self;
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, 2000)];
    [self.mainScrollView setContentOffset:CGPointMake(0, self.scrollViewOffsetToChange) animated:NO];
    [self setNotifications];
}


-(void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notif
{
    StoryMediaCell *cell = [self getMediaCollectionViewVisibleCell];
    [cell stopVideo];
}



#pragma mark Setup Views

-(void)setViews
{
    [self setMediaCollectionView];
    [self setImageToDeleteMediaButton];
    [self setStoryTitleTextView];
    [self setStoryTitleSectionView];
    [self setButtonsToButtonsBar];
    [self setStoryBodyTextView];
    [self setStoryBodySectionView];
    [self setStoryTagsSectionView];
    [self updateLastViewBottomBorder];
    [self addGestureRecognizers];
}

-(void)setImageToDeleteMediaButton
{
    CGFloat imgSize = CGRectGetWidth(self.deleteMediaButton.frame) * 0.5;
    CGFloat xPos = CGRectGetWidth(self.deleteMediaButton.frame) - imgSize;
    CGFloat yPos = 0;
    CGRect frame = CGRectMake(xPos, yPos, imgSize, imgSize);
    UIImageView *img = [[UIImageView alloc]initWithFrame:frame];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    [img setImage:[UIImage imageNamed:@"close"]];
    [GeneralMethods moveView:img toThe_Ypos_CenterOfView:self.deleteMediaButton];
    [self.deleteMediaButton addSubview:img];
}

- (UIView *)putView:(UIView *)view insideShadowWithColor:(UIColor *)color andRadius:(CGFloat)shadowRadius andOffset:(CGSize)shadowOffset andOpacity:(CGFloat)shadowOpacity
{
    CGRect shadowFrame; // Modify this if needed
    shadowFrame.size.width = 0.f;
    shadowFrame.size.height = 0.f;
    shadowFrame.origin.x = 0.f;
    shadowFrame.origin.y = 0.f;
    UIView * shadow = [[UIView alloc] initWithFrame:shadowFrame];
    shadow.userInteractionEnabled = NO; // Modify this if needed
    shadow.layer.shadowColor = color.CGColor;
    shadow.layer.shadowOffset = shadowOffset;
    shadow.layer.shadowRadius = shadowRadius;
    shadow.layer.masksToBounds = NO;
    shadow.clipsToBounds = NO;
    shadow.layer.shadowOpacity = shadowOpacity;
    [view.superview insertSubview:shadow belowSubview:view];
    [shadow addSubview:view];
    return shadow;
}

-(void)updateLastViewBottomBorder
{
//    [GeneralMethods sleepWithTime:1];
    UIView *lastView = self.storyTagsSectionView;
    CGFloat borderYpos = CGRectGetMaxY(lastView.frame);
    if (!self.lastViewBottomBorder)
    {
        self.lastViewBottomBorder = [UIView new];
        [self.mainScrollView insertSubview:self.lastViewBottomBorder aboveSubview:lastView];
    }
    
    [self.lastViewBottomBorder setFrame:CGRectMake(0, borderYpos, CGRectGetWidth(lastView.frame), CS_BORDER_THICKNESS)];
    [self.lastViewBottomBorder setBackgroundColor:CS_BORDER_COLOR];
    
}

-(void)setStoryTagsSectionView
{
    self.storyTagsSectionView = [[TTTagList alloc]initWithFrame:[self getStoryTagsFrame]];
    self.storyTagsSectionView.delegate = self;
    self.storyTagsSectionView.showsTagButton = NO;
    self.storyTagsSectionView.placeholderLabel.text = @"Tags";
    [self updateStoryTagsSectionsFrame];
    [self addBordersToView:self.storyTagsSectionView];
    [self.mainScrollView insertSubview:self.storyTagsSectionView belowSubview:self.storyBodySectionView];
}

//-(void)setStoryTagsSectionView - another tag list
//{
//    self.storyTagsSectionView = [[StoryTagsSectionView alloc]initWithFrame:[self getStoryTagsFrame] backgroundColor:self.view.backgroundColor];
//    self.storyTagsSectionView.delegate = self;
//    [self updateStoryTagsSectionsFrame];
//    [self addBordersToView:self.storyTagsSectionView];
//    [self.mainScrollView insertSubview:self.storyTagsSectionView belowSubview:self.storyBodySectionView];
//}

-(void)tagSectionWholeViewFrameDidChange
{
    [self updateLastViewBottomBorder];
}

-(void)setStoryTitleTextView
{
    CGFloat xPos = CS_PAGE_BORDERS;
    CGFloat yPos = CS_PAGE_BORDERS;
    CGFloat width = self.textViewWidth;
    CGFloat height = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:CS_PAGE_TITLE_FONT_SIZE + 20];
    
    CGRect frame = CGRectMake(xPos, yPos,width, height);
    
    self.storyTitleTextView = [GeneralMethods createTextViewWithText:@"" textColor:CS_PAGE_TEXT_COLOR frame:frame editable:YES withLineSpace:0 withAlignmentCenter:NO alpha:1 fontSize:1 addToView:nil];
    [self.storyTitleTextView setFont: [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:CS_PAGE_TITLE_FONT_SIZE]];
    [self.storyTitleTextView setTag:storyTitleTextViewTag];
    self.storyTitleTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.storyTitleTextView.delegate = self;
    self.storyTitleTextView.placeholder = @"STORY TITLE";
}

-(void)setStoryTitleSectionView
{
    self.storyTitleSectionView = [UIView new];
    [self updateStoryTitleSectionFrame];
    [self addBordersToView:self.storyTitleSectionView];
    [self.storyTitleSectionView setBackgroundColor:self.view.backgroundColor];
    
    self.titleSectionViewInitialYpos = self.storyTitleSectionView.frame.origin.y;
//    self.storyTitleSectionsInitialHeight = CGRectGetHeight(self.storyTitleSectionView.frame);
    
    [self.storyTitleSectionView addSubview:self.storyTitleTextView];
    [self.mainScrollView addSubview:self.storyTitleSectionView];
    
    // Bottom Border
    
    [self updateStoryTitleBottomBorder];
//    self.storyTitleBottomBorder =
}

-(void)setStoryBodyTextView
{
    CGFloat xPos = CS_PAGE_BORDERS;
    CGFloat yPos = CS_PAGE_BORDERS;
    CGFloat width = self.textViewWidth;
    CGFloat height = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:30];
    
    CGRect frame = CGRectMake(xPos, yPos,width, height);
    
    self.storyBodyTextView = [GeneralMethods createTextViewWithText:@"" textColor:CS_PAGE_TEXT_COLOR frame:frame editable:YES withLineSpace:0 withAlignmentCenter:NO alpha:1 fontSize:1 addToView:nil];
    [self.storyBodyTextView setFont: [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:CS_PAGE_BODY_FONT_SIZE]];
    [self.storyBodyTextView setTag:storyBodyTextViewTag];
    self.storyBodyTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.storyBodyTextView.delegate = self;
    self.storyBodyTextView.placeholder = @"TELL YOUR STORY...";
}

-(void)setStoryBodySectionView
{
    self.storyBodySectionView = [UIView new];
    [self updateStoryBodySectionsFrame];
    //    [self addBordersToView:self.storyBodySectionView];
    [self.storyBodySectionView setBackgroundColor:self.view.backgroundColor];
    [self.storyBodySectionView addSubview:self.storyBodyTextView];
    [self.mainScrollView insertSubview:self.storyBodySectionView belowSubview:self.storyTitleSectionView];
}


-(void)updateStoryTitleBottomBorder
{
    if (!self.storyTitleBottomBorder)
    {
        self.storyTitleBottomBorder = [UIView new];
        [self.storyTitleBottomBorder setBackgroundColor:CS_BORDER_COLOR];
        [self.storyTitleSectionView addSubview:self.storyTitleBottomBorder];
    }
    
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetHeight(self.storyTitleSectionView.frame) - CS_BORDER_THICKNESS;
    CGFloat width = CGRectGetWidth(self.storyTitleSectionView.frame);
    CGFloat height = CS_BORDER_THICKNESS;
    
    [self.storyTitleBottomBorder setFrame:CGRectMake(xPos, yPos, width, height)];
}

-(void)addBordersToView:(UIView *)view
{
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CS_BORDER_THICKNESS)];
    [border setBackgroundColor:CS_BORDER_COLOR];
    [view addSubview:border];
}


-(void)updateStoryTitleSectionFrame
{
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetMaxY(self.mediaCollectionView.frame);
    CGFloat width = CGRectGetWidth(self.mainScrollView.frame);
    CGFloat height = CGRectGetHeight(self.storyTitleTextView.frame) + (CS_PAGE_BORDERS * 2);
    
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    [self.storyTitleSectionView setFrame:frame];
    
    [GeneralMethods setNew_width:self.textViewWidth ToView:self.storyTitleTextView];
}

-(void)updateStoryBodySectionsFrame
{
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetMaxY(self.storyTitleSectionView.frame);
    CGFloat width = CGRectGetWidth(self.mainScrollView.frame);
    CGFloat height = CGRectGetHeight(self.storyBodyTextView.frame) + (CS_PAGE_BORDERS * 2);
    [self.storyBodySectionView setFrame:CGRectMake(xPos, yPos, width, height)];
    
    [GeneralMethods setNew_width:self.textViewWidth ToView:self.storyBodyTextView];
}

-(void)updateStoryTagsSectionsFrame
{
    [self.storyTagsSectionView setFrame:[self getStoryTagsFrame]];
}

-(CGRect)getStoryTagsFrame
{
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetMaxY(self.storyBodySectionView.frame);
    CGFloat width = CGRectGetWidth(self.mainScrollView.frame);
    CGFloat height;
    if(CGRectIsEmpty(self.storyTagsSectionView.frame))
    {
//        height = self.storyTitleSectionsInitialHeight;
        height = CGRectGetHeight(self.view.frame) * 0.07;
    }
    else
    {
        height = CGRectGetHeight(self.storyTagsSectionView.frame);
    }
    return CGRectMake(xPos, yPos, width, height);
}


-(void)setButtonsToButtonsBar
{
    CGFloat buttonWidth = CGRectGetHeight(self.buttonsBar.frame) * 0.65;
    CGFloat buttonYpos = CGRectGetHeight(self.buttonsBar.frame) / 2 - (buttonWidth / 2);
    CGFloat buttonHeight = CGRectGetHeight(self.buttonsBar.frame);
    CGFloat distanceBetweenButtons = ((CGRectGetWidth(self.buttonsBar.frame) - (buttonWidth * CS_NUMBER_OF_BUTTONS_BAR)) / (CS_NUMBER_OF_BUTTONS_BAR + 1));
    
    CGFloat currentXpos = distanceBetweenButtons;
    
    for (int i = 0; i < CS_NUMBER_OF_BUTTONS_BAR; i++)
    {
        CGRect frame = CGRectMake(currentXpos, buttonYpos, buttonWidth, buttonHeight);
        
        NSString *imageName = @"";
        switch (i)
        {
            case 0:
            {
                imageName = @"keyboard_camera";
            }
                break;
            case 1:
            {
                imageName = @"keyboard_video";
            }
                break;
            case 2:
            {
                imageName = @"keyboard_gallery";
            }
                break;
        }
        
        UIButton *button = [GeneralMethods createButtonFrame:frame backgroundColor:[UIColor clearColor] imageName:nil text:nil textColor:nil target:self selector:@selector(buttonBarClicked:) tag:i addToView:self.buttonsBar];
        
        // setting image to the button
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [imageView setFrame:CGRectMake(0, 0, buttonWidth, CGRectGetHeight(imageView.frame))];
        imageView.center = CGPointMake(button.frame.size.width / 2, button.frame.size.width / 2);
        [button addSubview:imageView];
        
        currentXpos += (buttonWidth + distanceBetweenButtons);
    }
    
    // creating close keyboard button
    
    self.closeKeyboardButton = [UIButton new];
    CGFloat xPos = CGRectGetWidth(self.buttonsBar.frame) - buttonWidth - 5;
    
    self.closeKeyboardButton = [GeneralMethods createButtonFrame:CGRectMake(xPos, buttonYpos, buttonWidth, buttonHeight) backgroundColor:[UIColor clearColor] imageName:nil text:nil textColor:nil target:self selector:@selector(closeKeyboard) tag:100 addToView:self.buttonsBar];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"keyboard_close"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat fixedSize = 0.8;
    CGFloat closeImageWidth = buttonWidth * fixedSize;
    CGFloat closeImageHeight = buttonHeight * fixedSize;
    
    [imageView setFrame:CGRectMake(0, 0, closeImageWidth, closeImageHeight)];
    imageView.center = CGPointMake(self.closeKeyboardButton.frame.size.width / 2, self.closeKeyboardButton.frame.size.width / 2);
    [self.closeKeyboardButton addSubview:imageView];
    
    [self setTopLineForButtonsBar];
}

-(void)setTopLineForButtonsBar
{
    UIView *line = [UIView new];
    [line setFrame:CGRectMake(0, 0, CGRectGetWidth(self.buttonsBar.frame), CS_BORDER_THICKNESS)];
    [line setBackgroundColor:CS_BORDER_COLOR];
    [self.buttonsBar addSubview:line];
}


-(void)setMediaCollectionView
{
    CGFloat cellSize = CGRectGetWidth(self.mainScrollView.frame);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [layout setMinimumLineSpacing:0.0f];
    
    self.mediaCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, cellSize, cellSize) collectionViewLayout:layout];
    [self.mediaCollectionView setDataSource:self];
    [self.mediaCollectionView setDelegate:self];
    self.mediaCollectionView.pagingEnabled = YES;
//    [self.mediaCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.mediaCollectionView setShowsVerticalScrollIndicator:NO];
    self.mediaCollectionView.bounces = NO;
    [self.mediaCollectionView setBackgroundColor:[GeneralMethods colorWithRed:243 green:243 blue:243]];
    [self.mediaCollectionView registerClass:[StoryMediaCell class] forCellWithReuseIdentifier:CS_MEDIA_CELL_ID];
    
    [self.mainScrollView addSubview:self.mediaCollectionView];
    [self addBordersToView:self.mediaCollectionView];
//    [self setEmptyImageToMediaCollectionView];
    [self reloadMediaCollection];
}


#pragma mark mediaCollectionView Deleagtes

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self.selectedMedia count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoryMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CS_MEDIA_CELL_ID forIndexPath:indexPath];
    [cell deallocCell];
    cell.delegate = self;
    [cell setViews];
    
    if ([self mediaExist] == NO)
    {
        [cell.backgroundImg setImage:[self.selectedMedia[0]objectForKey:@"image"]];
    }
    else
    {
        [cell setupWithAttachObj:self.selectedMedia[indexPath.row]];
    }
    
    return cell;
}

//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    StoryMediaCell *cell = (StoryMediaCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    [cell playVideo];
//}

-(BOOL)mediaExist
{
    return (([self.selectedMedia count] > 0 && [[[self.selectedMedia[0]objectForKey:@"url"] absoluteString] isEqualToString:CS_IMAGE_PLACEHOLDER] == NO));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellSize = self.mediaCollectionView.frame.size.width;
    return CGSizeMake(cellSize, cellSize);
}


#pragma mark UITextView Delegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger maxLength = 0;
    switch ([textView tag])
    {
        case storyTitleTextViewTag:
        {
            maxLength = CS_STORY_TITLE_TEXT_MAX_LENGTH;
        }
            break;
        case storyBodyTextViewTag:
        {
            maxLength = CS_STORY_BODY_TEXT_MAX_LENGTH;
        }
            break;
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= maxLength)
    {
        return YES;
    }
    else
    {
        NSUInteger emptySpace = maxLength - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    switch ([textView tag])
    {
        case storyTitleTextViewTag:
        {
            [self scrollToDefaultTop];
        }
            break;
        case storyBodyTextViewTag:
        {
            [self scrollToDefaultTop];
        }
            break;
    }
}

-(void)scrollToDefaultTop
{
    bool animated = YES;
    CGFloat a = CGRectGetMaxY(self.storyTitleSectionView.frame);
    CGFloat b = self.storyTagsSectionView.frame.origin.y;
    
    if (MAX(a, b) - MIN(a, b) <= 1)
    {
        animated = NO;
    }
    
    [self.mainScrollView setContentOffset:CGPointMake(0, self.scrollViewOffsetToChange) animated:animated];
}

-(void)textViewDidChange:(UITextView *)textView
{
    CGFloat cursorXPos = [textView caretRectForPosition:textView.selectedTextRange.start].origin.x;
    // when cursorXPos == 0 -> means the line is too long and should break. the init value of the x pos is 4.
    if ((self.shouldChangeSizeToFit == NO && textView.numberOfLines > 1) || cursorXPos == 0)
    {
        self.shouldChangeSizeToFit = YES; // this value will no change to NO again
    }
    
    if(self.shouldChangeSizeToFit)
    {
        [GeneralMethods setNew_width:self.textViewWidth ToView:self.storyTitleTextView];
        [GeneralMethods setNew_width:self.textViewWidth ToView:self.storyBodyTextView];
        [textView sizeToFit];
        
        [UIView animateWithDuration:0.115 animations:^
         {
             [self updateStoryTitleSectionFrame];
             [self updateStoryTitleBottomBorder];
             [self updateStoryBodySectionsFrame];
             [self updateStoryTagsSectionsFrame];
             [self updateLastViewBottomBorder];
         }];
    }
}

-(void)loadContent
{
    if (self.company)
    {
        return;
    }
    if (self.storyIdToLoad.length > 0) // loading exist story for edit
    {
        [TTActivityIndicator showOnMainWindowAnimated:YES];
        [self loadWithStoryId:self.storyIdToLoad];
    }
    else
    {
        [self loadCompany];
    }
}

-(void)loadCompany
{
    if (self.company)
    {
        [self updateProperties];
    }
    else
    {
        if ([[DataManager sharedManager].currentUser.validatedCompanies count] > 0 && [[DataManager sharedManager].currentUser.validatedCompanies[0] isMemberOfClass:[Company class]])
        {
            NSArray *validatedCompanies = [DataManager sharedManager].currentUser.validatedCompanies;
            Company *company = validatedCompanies[0];
            NSString *companyId;
            if(company)
            {
                companyId = company.companyId;
            }
            
            [[DataManager sharedManager] getCompanyById:companyId completionHandler:^(id result, NSError *error)
             {
                 if (!error && result) {
                     NSDictionary *companyDictKey = @{@"company": result};
                     self.company = [[Company alloc]initWithDictionary:companyDictKey];
                     if (self.company)
                     {
                         [self loadCompany];
                     }
                     else
                     {
                         // handle error...
                     }
                 }
            }];
        }
    }
}


-(void)loadWithStoryId:(NSString *)storyId
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:storyId forKey:@"storyId"];
    
    [[DataManager sharedManager] getStoryWithParams:params completionHandler:^(id result, NSError *error)
     {
         if (result && !error)
         {
             NSDictionary *resultDict = [[NSDictionary alloc]initWithDictionary:result];
             
             if ([resultDict allKeys] > 0)
             {
                 self.company = [[Company alloc]initWithDictionary:result];
                 self.currentStory = [[Story alloc]initWithDictionary:result];
                 [self loadExistStory];
                 [self loadCompany];
                 [TTActivityIndicator dismiss];
             }
         }
         else
         {
             // handle error...
             [TTActivityIndicator dismiss];
         }
     }];
}

-(void)loadExistStory
{
    if (self.currentStory.storyId && self.currentStory.storyId.length > 0)
    {
        if (self.currentStory.storyTitle.length > 0)
        {
            self.storyTitleTextView.text = self.currentStory.storyTitle;
        }
        if (self.currentStory.storyContent.length > 0)
        {
            self.storyBodyTextView.text = self.currentStory.storyContent;
        }
        if ([self.currentStory.categories count] > 0)
        {
            NSMutableArray *tagsName = [[NSMutableArray alloc]init];
            for (StoryCategory *cat in self.currentStory.categories)
            {
                [tagsName addObject:cat.categoryName];
            }
            
            [self.storyTagsSectionView setTags:tagsName];
        }
        
        self.shouldChangeSizeToFit = YES;
        [self handleExistStoryMedia:self.currentStory];
        [self textViewDidChange:self.storyTitleTextView];
        [self textViewDidChange:self.storyBodyTextView];
        [self reloadMediaCollection];
    }
}

-(void)handleExistStoryMedia:(Story *)story
{
    BOOL isVideo = story.storyType == StoryTypeMultimedia ? YES : NO;
    NSMutableArray *imagesUrls = [NSMutableArray new];
    
    if (isVideo == NO && [story.storyImages count] > 0) // storyTypeStory
    {
        for (id storyImage in story.storyImages)
        {
            if (storyImage[@"fullscreen"])
            {
                NSURL *url = [NSURL URLWithString:storyImage[@"fullscreen"]];
                [imagesUrls addObject:url];
                [self.selectedMedia addObject:@{/*@"image" : [[UIImage alloc]init],*/@"url" : url, @"isVideo" :@(isVideo)}];
            }
        }
        
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imagesUrls];
    }
    else if (isVideo && story.videoLink) // storyTypeMultimedia
    {
        
//        [self clearEmptyImageExample];
        [self.selectedMedia addObject:@{@"image" : [[UIImage alloc]init], @"url" : [NSURL URLWithString:story.videoLink], @"isVideo" :@(isVideo)}];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [self reloadMediaCollection];
         }];
        
        
        return;
    }
}

#pragma mark mainScrollView Deleagtes

-(StoryMediaCell *)getMediaCollectionViewVisibleCell
{
    NSIndexPath *path;
    for (UICollectionViewCell *cell in [self.mediaCollectionView visibleCells])
    {
        NSIndexPath *indexPath = [self.mediaCollectionView indexPathForCell:cell];
        path = indexPath;
        break;
    }
    
    return (StoryMediaCell *)[self.mediaCollectionView cellForItemAtIndexPath:path];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    StoryMediaCell *cell = [self getMediaCollectionViewVisibleCell];
    if (cell.isVideo)
    {
        [cell stopVideo];
        cell.ttPlayer.preventPlayByTouch = YES;
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    StoryMediaCell *cell = [self getMediaCollectionViewVisibleCell];
    if (cell.isVideo)
    {
        cell.ttPlayer.preventPlayByTouch = NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%f",scrollView.contentOffset.y);
    if ([scrollView isEqual:self.mainScrollView])
    {
        CGFloat scrollYPosition = scrollView.contentOffset.y;
        
        if (scrollYPosition < 0)
        {
            [scrollView setContentOffset:CGPointMake(0, 0)];
        }
        else if (scrollYPosition > self.scrollViewOffsetToChange)
        {
            StoryMediaCell *cell = [self getMediaCollectionViewVisibleCell];
            [self.headerBackgroundImage setImage:cell.backgroundImg.image];
            
            CGFloat storyTitleNewYpos = [self getFixedYposForViewWithInitialYpos:self.titleSectionViewInitialYpos contentOffset:scrollYPosition];
            [GeneralMethods setNew_Ypos:storyTitleNewYpos ToView:self.storyTitleSectionView];
            
            CGFloat storyTitleTouchTagSectionPos = self.scrollViewOffsetToChange + CGRectGetHeight(self.storyBodySectionView.frame);
            if (scrollYPosition >= storyTitleTouchTagSectionPos)
            {
                [self scrollToIntersectionPointOfTitleSectionAndTagsSectionAnimated:NO];
            }
        }
        else
        {
            [self.headerBackgroundImage setImage:nil];
            if (self.storyTitleSectionView.frame.origin.y != self.titleSectionViewInitialYpos)
            {
                [GeneralMethods setNew_Ypos:self.titleSectionViewInitialYpos ToView:self.storyTitleSectionView];
            }
            
        }
    }
}

-(void)scrollToIntersectionPointOfTitleSectionAndTagsSectionAnimated:(BOOL)animated
{
    CGFloat storyTitleTouchTagSectionPos = self.scrollViewOffsetToChange + CGRectGetHeight(self.storyBodySectionView.frame) + CS_BORDER_THICKNESS * 2;
    [self.mainScrollView setContentOffset:CGPointMake(0, storyTitleTouchTagSectionPos) animated:animated];
}

-(CGFloat)getFixedYposForViewWithInitialYpos:(CGFloat)initialYpos contentOffset:(CGFloat)contentOffset
{
    CGFloat scrollViewOffsetFixed = self.scrollViewOffsetToChange - contentOffset;
    return initialYpos - scrollViewOffsetFixed;
}


//#pragma mark TagTextView Delegate
//
//-(void)tagTextViewDidBeginEditing:(TagsTextView *)tagTextView
//{
//    [self scrollToIntersectionPointOfTitleSectionAndTagsSectionAnimated:YES];
//}

#pragma mark Tags Delegate

-(void)tagListDidBeginEditing:(TTTagList *)tagList
{
    [self scrollToIntersectionPointOfTitleSectionAndTagsSectionAnimated:YES];
}

#pragma mark Button Actions


-(void)buttonBarClicked:(id)sender
{
    [self closeKeyboard];
    
    void (^showAlert)(NSString *) = ^(NSString *alertTitle)
    {
        UIAlertController *alert =  [GeneralMethods showAlertControllerWithSingleButtonTitle:@"OK" title:alertTitle onController:self buttonClicked:^(bool clicked)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:^{}];
                                     }];
    };
    
    switch ([sender tag])
    {
        case 0: // Open Square Camera
        {
            if ([self numberOfExistingImages] >= CS_IMAGES_COUNT_LIMIT)
            {
                showAlert(CS_MAXIMUM_MEDIA_ALERT);
            }
            else if ([self numberOfExistingVideos] > 0)
            {
                showAlert(CS_MEDIA_TYPE_ALERT);
            }
            else
            {
                [self presetnSquareTTCameraForMode:kUTTypeImage];
            }
        }
            break;
        case 1: // Open Video Camera
        {
            if ([self numberOfExistingVideos] >= CS_VIDEOS_COUNT_LIMIT)
            {
                showAlert(CS_MAXIMUM_MEDIA_ALERT);
            }
            else if ([self numberOfExistingImages] > 0)
            {
                showAlert(CS_MEDIA_TYPE_ALERT);
            }
            else
            {
                [self presetnSquareTTCameraForMode:kUTTypeMovie];
            }
            
        }
            break;
        case 2: // Open Image Picker
        {
            [self presentGalleryPicker];
        }
            break;
    }
}

-(void)presetnSquareTTCameraForMode:(CFStringRef)mode
{
    if ([self deviceSupportedFor:mode])
    {
        UIStoryboard *storyBoard = [GeneralMethods getStoryboardByName:@"TT_SquareCamera"];
        TT_SquareCameraController *squareCamera = [storyBoard instantiateViewControllerWithIdentifier:@"TT_SquareCameraController"];
        squareCamera.delegate = self;
        squareCamera.cameraMode = mode;
        [self presentViewController:squareCamera animated:YES completion:nil];
    }
}

-(BOOL)deviceSupportedFor:(CFStringRef)type
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *videoRecorder = [[UIImagePickerController alloc]init];
        NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:videoRecorder.sourceType];
//        NSLog(@"Available types for source as camera = %@", sourceTypes);
        if (![sourceTypes containsObject:(__bridge NSString*)type])  // kUTTypeMovie
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Device Not Supported for Image Camera." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil,nil];
            [alert show];
            return NO;
        }
        //        self.recorder_ = videoRecorder;
        //        [self presentModalViewController:self.recorder_ animated:YES];
    }
    return YES;
}

#pragma mark SquareCameraController Delegate

-(void)squareCameraController:(TT_SquareCameraController *)squareCamera didCaptureImage:(UIImage *)image
{
    [self handleRecordedMediaFromCamera:squareCamera WithImage:image withUrl:nil];
}

-(void)squareCameraController:(TT_SquareCameraController *)squareCamera didCaptureVideoInPath:(NSURL *)filePath withThumbnailImage:(UIImage *)thumbnailImage
{
    [self handleRecordedMediaFromCamera:squareCamera WithImage:thumbnailImage withUrl:filePath];
}

-(void)handleRecordedMediaFromCamera:(TT_SquareCameraController *)squareCamera WithImage:(UIImage *)image withUrl:(NSURL *)url
{
    if ([self mediaExist] == NO)
    {
        self.selectedMedia = [NSMutableArray new];
    }
    
    BOOL isVideo = (url); // if url exist = its a video file!
    
    if (isVideo == NO) // still camera image
    {
        url = [NSURL URLWithString:CS_IMAGE_URL];
    }
    
    [self.selectedMedia addObject:@{@"image" : image, @"url" : url, @"isVideo" : @(isVideo)}];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self reloadMediaCollection];
    });
    
    [squareCamera dismissViewControllerAnimated:YES completion:^
     {
         [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
         [GeneralMethods scrollToLastItemAtCollectionView:self.mediaCollectionView toPosition:@"bottom" animated:YES];
     }];
}

-(void)reloadMediaCollection
{
    switch ([self.selectedMedia count])
    {
        case 0:
        {
            [self setEmptyImageToMediaCollectionView];
        }
            break;
        case 1:
        {
            if ([self mediaExist])
            {
                [self clearEmptyImageExample];
                [self.deleteMediaButton setHidden:NO];
            }
            else
            {
                [self setEmptyImageToMediaCollectionView];
            }
        }
            break;
        default:
        {
            [self clearEmptyImageExample];
            [self.deleteMediaButton setHidden:NO];
        }
            break;
    }
    
    [self.mediaCollectionView reloadData];
}

- (void)createGalleryViewController:(CreateGalleryViewController *)controller didSelectAssets:(NSArray *)assets
{
    ALAsset *asset;
    if ([assets count] > 0)
    {
        asset = assets[0];
    }
    
    if ([assets count] == 0) // nothing selected
    {
        return;
    }
    
    //    [self clearEmptyImageExample];
    //    [self.deleteMediaButton setHidden:NO];
    
    for (ALAsset *asset in assets)  {
        if ([self assetWithURLExist:asset.defaultRepresentation.url])
        {
            continue;
        }
        
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        UIImage *previewImage = [UIImage imageWithCGImage:[rep fullScreenImage] scale:[rep scale] orientation:UIImageOrientationUp];
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            [self.selectedMedia addObject:@{@"image" : previewImage}];
            [self cropFromUrl:asset.defaultRepresentation.url];
        } else if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            [self.selectedMedia addObject:@{@"image" :previewImage , @"url" : asset.defaultRepresentation.url}];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self reloadMediaCollection];
    });
    
    [controller dismissViewControllerAnimated:YES completion:^
     {
         [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
         [GeneralMethods scrollToLastItemAtCollectionView:self.mediaCollectionView toPosition:@"down" animated:YES];
     }];
}


-(BOOL)assetWithURLExist:(NSURL *)url
{
    BOOL exist = NO;
    for (NSDictionary *dict in self.selectedMedia)
    {
        if ([[[dict objectForKey:@"url"] absoluteString] isEqualToString:[url absoluteString]])
        {
            exist = YES;
            break;
        }
    }
    
    return exist;
}

-(void)animateSectionToRed:(UIView *)view
{
    UIColor *prevBackgroundColor = view.backgroundColor;
    UIColor *warningColor = [UIColor colorWithRed:31.0f/255.0f green:172.0f/255.0f blue:228.0f/255.0f alpha:0.63];
    [view setBackgroundColor:warningColor];
    
    [UIView animateWithDuration:1 animations:^
    {
        [view setBackgroundColor:prevBackgroundColor];
    }];
}

-(BOOL)readyToPublish
{
    CGFloat delay = 0.6;
    if (self.storyTitleTextView.text.length < 1)
    {
        [self scrollToDefaultTop];
        [self performSelector:@selector(animateSectionToRed:) withObject:self.storyTitleSectionView afterDelay:delay];
        return NO;
    }
    else if (self.storyBodyTextView.text.length < 1)
    {
        [self scrollToDefaultTop];
        [self performSelector:@selector(animateSectionToRed:) withObject:self.storyBodySectionView afterDelay:delay];
        return NO;
    }
    else if ([self mediaExist] == NO)
    {
        UIAlertController *alert =  [GeneralMethods showAlertControllerWithSingleButtonTitle:@"OK" title:@"Please add at least one media item." onController:self buttonClicked:^(bool clicked)
        {
            [alert dismissViewControllerAnimated:YES completion:^{}];
            [self scrollToTop];
            [self performSelector:@selector(animateSectionToRed:) withObject:self.buttonsBar afterDelay:delay];
        }];
        
        return NO;
    }
    else if (!self.company || !self.company.companyId)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)publishStory {
    if ([self readyToPublish] == NO)
    {
        return;
    }
    
    [self closeKeyboard];
    __block NSURL *tempVideoURL;
    __block NSURL *tempThumbnailURL;
    
    for (NSDictionary *mediaDict in self.selectedMedia)
    {
        if ([mediaDict[@"isVideo"]boolValue] == YES)
        {
            tempVideoURL = mediaDict[@"url"];
            break;
        }
    }
    
    NSMutableDictionary *storyDict = [NSMutableDictionary new];
    
    storyDict = [self packNewStoryToDictionary];
    
    void (^uploadStory)(NSString *videoUrl, NSString *thumbnailURL) = ^(NSString *videoURL, NSString *thumbnailURL)
    {
        if (videoURL) {
            [storyDict setObject:videoURL forKey:kVideoLink];
        }
        if (thumbnailURL) {
            [storyDict setObject:thumbnailURL forKey:kVideoThumbnail];
        }
        
        BOOL isNewStory = !self.storyIdToLoad.length;
        
        [Story publishStoryFromDict:storyDict newStory:isNewStory completionHandler:^(BOOL success, NSError *error)
         {
             if (success && !error)
             {
                 if (!videoURL)
                 {
                     [TTActivityIndicator dismiss:NO];
                 }
                 
                 [self dismissViewControllerAnimated:YES completion:nil];
             }
             else
             {
                 if (!videoURL)
                 {
                     [TTActivityIndicator dismiss:NO];
                 }
                 
                 [self.createStoryAlert loadAlertContainerViewWithGeneralAlert:@"Something went wrong, Please try again later" showCloseButton:YES processButtonText:@"OK"];
             }
         }];
    };
    
    if (tempVideoURL) // story with video
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [TTActivityIndicator showOnView:self.view];
            CreateViewController *createViewController = (CreateViewController *)self.parentViewController;
            createViewController.postButton.enabled = NO;
        });
        if ([self isWebUrl:tempVideoURL]) // video from existing story didn't changed
        {
            uploadStory([tempVideoURL absoluteString], [tempThumbnailURL absoluteString]);
            return;
        }
        
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:tempVideoURL forKey:@"videoFile"];
        [CommManager sharedManager].delegate = self;
        //[self showCreateStoryAlertWithMode:uploadVideoProgressMode];
        __block NSURL *videoUrl = tempVideoURL;
        [[DataManager sharedManager] uploadVideoWithParams:param completionHandler:^(id result, NSError *error) {
            // delete story from device documents
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTActivityIndicator dismiss:YES];
                CreateViewController *createViewController = (CreateViewController *)self.parentViewController;
                createViewController.postButton.enabled = YES;
            });
             if (result && !error) {
                 [self removeVideo:videoUrl];
                 uploadStory(result[kVideoLink], result[kVideoThumbnail]);
             } else {
                 [self.createStoryAlert loadAlertContainerViewWithGeneralAlert:@"An error occurred. video cannot be uploaded. please try again later." showCloseButton:YES processButtonText:@"OK"];
             }
         }];
    }
    else // story without video
    {
        [TTActivityIndicator showOnView:self.view];
        uploadStory(nil, nil);
    }
}

-(BOOL)isWebUrl:(NSURL *)url
{
    return ([[url absoluteString]containsString:@"http://"] || [[url absoluteString]containsString:@"https://"]);
}

-(void)commManager:(CommManager *)manager uploadProcessDidUpdatedWithPercent:(CGFloat)percent
{
    DLog(@"Percent %f", [[NSNumber numberWithFloat:percent] doubleValue]);
   // [self progressWithPercent:[[NSNumber numberWithFloat:percent] doubleValue]];
    [self.createStoryAlert setNewValueToProgressView:percent];
}

-(NSMutableDictionary *)packNewStoryToDictionary
{
    NSMutableDictionary *storyDict = [NSMutableDictionary new];
    NSString *title = [NSString stringWithFormat:@"%@",self.storyTitleTextView.text];
    [storyDict setObject:title forKey:kTitle];
    NSString *content = [NSString stringWithFormat:@"%@",self.storyBodyTextView.text];
    [storyDict setObject:content forKey:kContent];
    
    [storyDict setObject:[self.storyTagsSectionView tags] forKey:kCategories];
    
    if ([self numberOfExistingVideos] > 0)
    {
        [storyDict setObject:@(StoryTypeMultimedia) forKey:kStoryType];
    }
    else
    {
        [storyDict setObject:@(StoryTypeStory) forKey:kStoryType];
    }
    
    [storyDict setObject:[self getAllImagesOnly] forKey:kImages];
    
    [storyDict setObject:self.company forKey:kCompany];
    
    return storyDict;
}

-(NSMutableArray *)getAllImagesOnly
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (NSDictionary *dict in self.selectedMedia)
    {
        // media exist in this point always
        
        if ([[dict objectForKey:@"isVideo"]boolValue] != YES)
        {
            if (dict[@"image"])
            {
                [result addObject:[GeneralMethods centerMaxSquareImageByCroppingImage:dict[@"image"]]];
            }
            else if (dict[@"url"] && [self isWebUrl:dict[@"url"]]) // will fill with image's url of EXIST STORY only
            {
                [result addObject:dict[@"url"]];
            }
        }
    }
    
    return result;
}


-(int)numberOfExistingVideos
{
    int numOfExistinVideos = 0;
    
    for (NSDictionary *dict in self.selectedMedia)
    {
        if ([[dict objectForKey:@"isVideo"]boolValue])
        {
            numOfExistinVideos++;
        }
    }
    
    return numOfExistinVideos;
}

-(int)numberOfExistingImages
{
    int numOfExistinImages = 0;
    
    for (NSDictionary *dict in self.selectedMedia)
    {
        NSString *str1 = CS_IMAGE_URL;
        NSString *str2 = [dict[@"url"]absoluteString];
        
        if ([str2 isEqualToString:str1] || ((dict[@"isVideo"] == NO && [[dict[@"url"]absoluteString] isEqualToString:CS_IMAGE_PLACEHOLDER] == NO)) || [self isWebUrl:dict[@"url"]])
        {
            numOfExistinImages++;
        }
    }
    
    return numOfExistinImages;
}

- (void)removeVideo:(NSURL *)fileUrl {
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
    if (success) {
        DLog(@"success deleting video %@", fileUrl);
    } else {
        DLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (void)presentGalleryPicker
{
    CreateGalleryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"createGalleryViewController"];
    int numberOfExistingVideos = [self numberOfExistingVideos]; // avoid uploading videos
    int numberOfExistingImages = [self numberOfExistingImages];
    controller.numOfVideosAllowed = 0;
    controller.numOfImagesAllowed = 0;
    
    if (CS_VIDEOS_COUNT_LIMIT == numberOfExistingVideos || CS_IMAGES_COUNT_LIMIT == numberOfExistingImages)
    {
        UIAlertController *alert = [GeneralMethods showAlertControllerWithSingleButtonTitle:@"OK" title:CS_MAXIMUM_MEDIA_ALERT onController:self buttonClicked:^(bool clicked)
        {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        return;
    }
    else if (numberOfExistingVideos > 0) // video already exist
    {
        controller.numOfVideosAllowed = CS_VIDEOS_COUNT_LIMIT - numberOfExistingVideos;
    }
    else if (numberOfExistingImages > 0) // image already exist
    {
        controller.numOfImagesAllowed = CS_IMAGES_COUNT_LIMIT - numberOfExistingImages;
    }
    else // no video or image exist
    {
        controller.numOfVideosAllowed = CS_VIDEOS_COUNT_LIMIT - numberOfExistingVideos;
        controller.numOfImagesAllowed = CS_IMAGES_COUNT_LIMIT - numberOfExistingImages;
    }
    
    controller.allowVideo = YES;
    controller.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

//- (void)presentPickerWithType:(UIImagePickerControllerSourceType)type media:(NSArray *)media
//{
//    if ([UIImagePickerController isSourceTypeAvailable:type])
//    {
//        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
//        controller.delegate = self;
//        controller.mediaTypes = media;
//        controller.sourceType = type;
//        [self presentViewController:controller animated:YES completion:nil];
//    }
//}

-(void)clearEmptyImageExample
{
    id url = [self.selectedMedia[0]objectForKey:@"url"];
    
    if ([[url absoluteString] isEqualToString:CS_IMAGE_PLACEHOLDER])
    {
        [self.selectedMedia removeObjectAtIndex:0];
    }
}

-(void)setEmptyImageToMediaCollectionView
{
    self.selectedMedia = [[NSMutableArray alloc] init];
    [self.selectedMedia addObject:@{@"image" : [UIImage imageNamed:@"EmptyCollectionBackground.jpg"], @"url": [NSURL URLWithString:CS_IMAGE_PLACEHOLDER]}];
    [self.deleteMediaButton setHidden:YES];
}

- (void)createGalleryViewControllerShouldDismiss:(CreateGalleryViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)deleteMediaButtonClicked:(id)sender
{
    if ([self mediaExist]) // media exist
    {
        StoryMediaCell *cell = [self getMediaCollectionViewVisibleCell];
        [cell prepareForCellDelete]; // continue in storyMediaCellDidFinishDeleteAnimation
    }
}

-(void)storyMediaCellDidFinishDeleteAnimation:(StoryMediaCell *)cell
{
    NSIndexPath *path = [self.mediaCollectionView indexPathForCell:cell];
    [cell deallocCell];
    [self.selectedMedia removeObjectAtIndex:path.row];
    [self.mediaCollectionView deleteItemsAtIndexPaths:@[path]];
//    if ([self.selectedMedia count] == 0)
//    {
//        [self setEmptyImageToMediaCollectionView];
////        [self.mediaCollectionView insertItemsAtIndexPaths:@[path]];
//    }
    
    [self reloadMediaCollection];
}


- (void)cropFromUrl:(NSURL *)url {
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    //    CGFloat newSize =  clipVideoTrack.naturalSize.width * yPos / CGRectGetWidth(self.view.frame);
    //    Here we shift the viewing square up to the TOP of the video so we only see the top
    
    //    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipHeight, -yPos);
    
    //    Here we shift the viewing square up to the TOP of the video so we only see the top
    
    CGFloat fixed = (clipVideoTrack.naturalSize.height / CGRectGetWidth(self.view.frame)) * CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height,-fixed);
    
    //Make sure the square is portrait
    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //Create an Export Path to store the cropped video
    NSString *outputPath = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(),[GeneralMethods createUniqueIdentifier], @".mp4"];
    NSURL *exportUrl = [NSURL fileURLWithPath:outputPath];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager] removeItemAtURL:exportUrl error:nil];
    
    //Export
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
           //  self.capturedVideoURL = exporter.outputURL;
             UIImage *image;
             if (self.selectedMedia.count > 0) {
                 image = [self.selectedMedia[0]objectForKey:@"image"];
                 [self.selectedMedia removeObjectAtIndex:0];
             }
             [self.selectedMedia addObject:@{@"image" : image , @"url" : exporter.outputURL, @"isVideo" : @(YES)}];
         });
     }];
}

#pragma mark Updates

-(void)updateMainScrollViewContentSize
{
    
}

- (void)setCompanyImageFromURL:(NSString *)imageURL
{
    [self.companyImageView sd_cancelCurrentImageLoad];
    if (imageURL)
    {
        [self.companyImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (image)
             {
                 [self.companyImageView setImage:image];
             }
        }];
    }
    else
    {
        self.companyImageView.image = nil;
    }
}

-(void)updateProperties
{
    self.companyNameLabel.text = self.company.companyName;
    self.companyNameLabel.shadowEnabled = YES;
    self.companyNameLabel.attributedText = [self attributedStringForString:self.companyNameLabel.text]; // DONT DELETE !
    
    [self setCompanyImageFromURL:self.company.companyLogo];
}

#pragma mark CreateStoryAlert

- (BOOL)userProfileVerified {
    __block User *user = [[DataManager sharedManager] currentUser];
    if (!user.validatedCompanies || [user.validatedCompanies count] < 1) {
        [self showAssociateCompanyAlertViewController];
        return NO;
    }
    return YES;
}

-(void)showAssociateCompanyAlertViewController {
    if (self.alert) {
        return;
    }
    UIStoryboard *alertStoryboard = [UIStoryboard storyboardWithName:@"Alert" bundle:nil];
    self.alert = [alertStoryboard instantiateViewControllerWithIdentifier:@"associateCompanyAlertViewController"];
    self.alert.delegate = self;
    [self presentViewController:self.alert animated:YES completion:nil];
}

-(void)dismissCreateStoryAlert
{
    if(self.createStoryAlert && ![self.createStoryAlert isHidden])
    {
        [self.createStoryAlert removeFromSuperview];
        self.createStoryAlert = nil;
    }
}

#pragma mark CreateStoryAlertDelegate

-(void)createStoryAlert:(CreateStoryAlert *)alert closeButtonClicked:(id)sender
{
    if (alert.alertMode != generalAlert)
    {
         [self dismissViewControllerAnimated:YES completion:nil];   
    }
    [self dismissCreateStoryAlert];
}


-(void)createStoryAlert:(CreateStoryAlert *)alert emptyOrHalfFilledProfileButtonClicked:(id)sender
{
    self.shouldCheckUserProfileVerified = YES;
    UserProfileCreateViewController *userProfileCreateViewController = [[UIStoryboard storyboardWithName:@"UserProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"userProfileCreateViewController"];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:userProfileCreateViewController];
    [navController.navigationBar setTranslucent:NO];
    [self presentViewController:navController animated:NO completion:nil];
}

#pragma mark - AssociateCompanyAlert Delegate

- (void)willClosedAlertViewControllerAndAssociationSucceed:(BOOL)succeed {
    if (succeed) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Enum

typedef NS_ENUM(NSUInteger, textViewEnum)
{
    storyTitleTextViewTag = 1,
    storyBodyTextViewTag = 2,
};

@end
