/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller for camera interface.
 */

@import AVFoundation;
@import Photos;

#import "TT_SquareCameraController.h"
#import "AAPLPreviewView.h"
#import "GeneralMethods.h"
#import "TT_Stopper.h"
#import "TTActivityIndicator.h"

#define TTSC_BUTTONS_HEIGHT 30

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface TT_SquareCameraController () <AVCaptureFileOutputRecordingDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AAPLPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UILabel *cameraUnavailableLabel;
@property (nonatomic, strong) NSTimer *timer;

//@property UIButton *recordButton;
//@property UIButton *stillButton;
//@property UIButton *resumeButton;
@property UIButton *switchCameraButton;
@property UIButton *chooseButton;
@property UIButton *actionButton;
@property UIButton *cancelButton;
@property UIButton *flashModeButton;
@property UIView *actionButtonInnerCircle;

@property UIImageView *visibleArea;
@property UIView *topBar;
@property TT_Stopper *stopper;
@property UIView *bottomBar;
@property CGFloat pageBorder;
@property NSURL *capturedVideoURL;

//@property (nonatomic, strong) AVPlayerItem *playerItem;
//@property (nonatomic, strong) AVPlayer *avPlayer;
//@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property TT_AVPlayer *ttPlayer;

@property BOOL isVideoCamera;
@property BOOL isImageCamera;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, assign) NSInteger count;


@end

@implementation TT_SquareCameraController


#pragma mark Lifecycle

-(void)handleCameraMode
{
    self.isVideoCamera = UTTypeConformsTo(self.cameraMode, kUTTypeMovie) != 0;
    self.isImageCamera = UTTypeConformsTo(self.cameraMode, kUTTypeImage) != 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self appleConfigureDidLoad];
    [self setGeneralProperties];
    [self setBarsAndVisibleArea];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self appleConfigureWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [self popAnimateView:self.stopper];
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamSetupResultSuccess ) {
            [self.session stopRunning];
            [self removeObservers];
            [self inactiveTimer];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    } );
    
    [super viewDidDisappear:animated];
}

#pragma mark Views Setup

-(void)setGeneralProperties
{
    self.pageBorder = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:20];
    [self handleCameraMode];
    [self setNotifications];
}

-(void)setBarsAndVisibleArea
{
    [self setTopBar];
    [self setVisibleArea];
    [self setBottomBar];
}

-(void)setTopBarSubviews
{
    [self setSwitchCameraButton];
    if (self.isVideoCamera)
    {
        [self setStopper];
    }
    [self setFlashModeButton];
}

-(void)setStopper
{
    CGFloat height = CGRectGetHeight(self.topBar.frame) / 2.5;
    CGFloat width = CGRectGetWidth(self.topBar.frame) * 0.5;
    CGFloat xPos = (CGRectGetWidth(self.topBar.frame) / 2) - (width / 2);
    CGFloat yPos = CGRectGetHeight(self.topBar.frame) - height;
    
    self.stopper = [[TT_Stopper alloc]initWithFrame:CGRectMake(xPos, yPos, width, height) textColor:[UIColor whiteColor] distanceBetweenViews:2 milliseconds:NO];
    [self.topBar addSubview:self.stopper];
}

-(void)setFlashModeButton
{
    NSString *imageName = @"";
    CGFloat buttonHeight = CGRectGetHeight(self.topBar.frame) * 0.5;
    CGSize buttonSize;
    
    
    if (self.isVideoCamera)
    {
        buttonSize = CGSizeMake(buttonHeight, buttonHeight);
        imageName = @"video";
    }
    else if (self.isImageCamera)
    {
        imageName = @"";
        CGFloat buttonWidth = 100;
        buttonSize = CGSizeMake(buttonWidth, buttonHeight);
    }
    
    CGFloat yPos = CGRectGetHeight(self.topBar.frame) - buttonSize.height;
    
    self.flashModeButton = [[UIButton alloc]initWithFrame:CGRectMake(8, yPos, buttonSize.width, buttonSize.height)];
    [self.flashModeButton setContentMode:UIViewContentModeScaleAspectFit];
    self.flashModeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self.flashModeButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    [self.flashModeButton addTarget:self action:@selector(flashModeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.topBar addSubview:self.flashModeButton];
    
    if (self.isImageCamera)
    {
        [self setFlashMode:@"Auto"];
    }
}

-(void)flashModeClicked
{
    if (self.isImageCamera)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Flash Mode:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *onMode = [UIAlertAction actionWithTitle:@"On" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
        {
            [self setFlashMode:@"On"];
        }];
        
        
        UIAlertAction *offMode = [UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
        {
            [self setFlashMode:@"Off"];
        }];
        
        UIAlertAction *autoMode = [UIAlertAction actionWithTitle:@"Auto" style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * action)
        {
            [self setFlashMode:@"Auto"];
        }];
        
        [alert addAction:onMode];
        [alert addAction:offMode];
        [alert addAction:autoMode];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)setFlashMode:(NSString *)mode
{
    NSString *title = @"Flash:";
    mode = [mode lowercaseString];
    
    if ([mode isEqualToString:@"on"])
    {
        [TT_SquareCameraController setFlashMode:AVCaptureFlashModeOn forDevice:self.videoDeviceInput.device];
    }
    else if ([mode isEqualToString:@"off"])
    {
        [TT_SquareCameraController setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];
    }
    else if ([mode isEqualToString:@"auto"])
    {
        [TT_SquareCameraController setFlashMode:AVCaptureFlashModeAuto forDevice:self.videoDeviceInput.device];
    }
    
    mode = [GeneralMethods upperCaseFirstCharOfString:mode];
    
    [self.flashModeButton setTitle:[title stringByAppendingString:mode] forState:UIControlStateNormal];
}


-(void)setSwitchCameraButton
{
    self.switchCameraButton = [UIButton new];
    
    CGFloat buttonSize = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:30];
    CGFloat yPos = CGRectGetHeight(self.topBar.frame) - buttonSize;
    CGFloat xPos = CGRectGetWidth(self.topBar.frame) - buttonSize - 5;
    CGRect frame = CGRectMake(xPos, yPos, buttonSize, buttonSize);
    [self.switchCameraButton setFrame:frame];
    
    [self.switchCameraButton addTarget:self action:@selector(switchCameraClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // Adding image to the button
    CGFloat imgSize = self.switchCameraButton.frame.size.height;
    yPos = CGRectGetHeight(self.switchCameraButton.frame) - imgSize;
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos, imgSize,imgSize)];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    [img setImage:[UIImage imageNamed:@"cameraSwitch"]];
    [self.switchCameraButton addSubview:img];
    [self.view addSubview:self.switchCameraButton];
}

-(void)setTopBar
{
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:60];
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    
    self.topBar = [[UIView alloc]initWithFrame:frame];
    
    [self.topBar setBackgroundColor:[UIColor blackColor]]; 

    [self.view addSubview:self.topBar];
    [self setTopBarSubviews];
}

-(void)setVisibleArea
{
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetMaxY(self.topBar.frame);
    CGFloat width = CGRectGetWidth(self.topBar.frame);
    CGFloat height = width;
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    self.visibleArea = [[UIImageView alloc]initWithFrame:frame];
    [self.visibleArea setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.visibleArea];
}


-(void)setBottomBar
{
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetMaxY(self.visibleArea.frame);
    CGFloat width = CGRectGetWidth(self.topBar.frame);
    CGFloat height = CGRectGetHeight(self.view.frame) - yPos;
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    self.bottomBar = [[UIImageView alloc]initWithFrame:frame];
    [self.bottomBar setBackgroundColor:self.topBar.backgroundColor];
    [self.bottomBar setUserInteractionEnabled:YES];
    [self.view addSubview:self.bottomBar];
    
    [self setBottomBarSubviews];
}

-(void)setBottomBarSubviews
{
    [self setActionButton];
    [self setCancelButton];
    [self setChooseButton];
}

-(void)setChooseButton
{
    self.chooseButton = [UIButton new];
    
    CGFloat height = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:TTSC_BUTTONS_HEIGHT];
    CGFloat yPos = self.cancelButton.frame.origin.y;
    CGFloat width = CGRectGetWidth(self.view.frame) - CGRectGetMaxX(self.actionButton.frame) - self.pageBorder;
    CGFloat xPos = CGRectGetWidth(self.view.frame) - width - self.pageBorder;
    
    [self.chooseButton setFrame:CGRectMake(xPos, yPos, width, height)];
    self.chooseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.chooseButton setTitle:@"Choose" forState:UIControlStateNormal];
    [self.chooseButton setAlpha:0];
    [self.chooseButton addTarget:self action:@selector(chooseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar addSubview:self.chooseButton];
}

-(void)chooseButtonClicked:(id)sender
{
    if (self.isImageCamera)
    {
        UIImage *chosenImage = self.visibleArea.image;
        if (chosenImage)
        {
            if ([self.delegate respondsToSelector:@selector(squareCameraController:didCaptureImage:)])
            {
                [self.delegate squareCameraController:self didCaptureImage:chosenImage];
            }
        }
    }
    else if (self.isVideoCamera)
    {
        if (self.capturedVideoURL)
        {
            UIImage *thumbnailImage = self.ttPlayer.thumbnailImageview.image;
            [self.ttPlayer deallocPlayer];
            
            if ([self.delegate respondsToSelector:@selector(squareCameraController:didCaptureVideoInPath:withThumbnailImage:)])
            {
                [self.delegate squareCameraController:self didCaptureVideoInPath:self.capturedVideoURL withThumbnailImage:thumbnailImage];
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setCancelButton
{
    self.cancelButton = [UIButton new];
    
    CGFloat xPos = self.pageBorder;
    CGFloat height = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:TTSC_BUTTONS_HEIGHT];
    CGFloat yPos = CGRectGetHeight(self.bottomBar.frame) - height - self.pageBorder;
    CGFloat width = self.actionButton.frame.origin.x - self.pageBorder;
    
    [self.cancelButton setFrame:CGRectMake(xPos, yPos, width, height)];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar addSubview:self.cancelButton];
}

-(void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notif
{
//    if (self.movieFileOutput.isRecording)
//    {
//        [self stopRecordingClicked];
//    }
}


-(void)setActionButton
{
    self.actionButton = [UIButton new];
    
    CGFloat buttonSize = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:60];
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetHeight(self.bottomBar.frame) - buttonSize - self.pageBorder;
    [self.actionButton setFrame:CGRectMake(xPos, yPos, buttonSize, buttonSize)];
    [self.actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [GeneralMethods createCircleView:self.actionButton];
    [self.actionButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    CGFloat borderWidth = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:4];
    [self.actionButton.layer setBorderWidth:borderWidth];
    [self.actionButton setBackgroundColor:[UIColor clearColor]];
    self.actionButton.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, self.actionButton.center.y);
    [self.bottomBar addSubview:self.actionButton];
    
    // Set actionButtonInnerCircle
    
    self.actionButtonInnerCircle = [UIView new];
    [self actionButtonIsRecording:NO animated:NO];
    [self.actionButtonInnerCircle setUserInteractionEnabled:NO];
    [GeneralMethods createCircleView:self.actionButtonInnerCircle];
    [self.actionButton addSubview:self.actionButtonInnerCircle];
}

-(void)actionButtonIsRecording:(BOOL)isRecording animated:(BOOL)animated
{
    CGFloat buttonSize = self.actionButton.frame.size.width * 0.7;
    UIColor *color = [UIColor redColor];
    CGFloat duration = 0.6;
    
    if (isRecording)
    {
        buttonSize *= 0.5;
        color = [UIColor whiteColor];
    }
    
    CGFloat xPos = (CGRectGetWidth(self.actionButton.frame) / 2) - (buttonSize / 2);
    CGRect frame = CGRectMake(xPos, xPos, buttonSize, buttonSize);
    
    [UIView animateWithDuration:duration animations:^
    {
        [self.actionButtonInnerCircle setBackgroundColor:color];
        [self.actionButtonInnerCircle setFrame:frame];
        [GeneralMethods createCircleView:self.actionButtonInnerCircle];
    }];
    [GeneralMethods spinAnimationOnView:self.actionButtonInnerCircle duration:duration rotations:1 repeat:YES];;
}

- (void)popAnimateView:(UIView *)view {
    static BOOL secondAnimation = NO;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    
    [UIView animateWithDuration:0.23 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (!secondAnimation) {
                secondAnimation = YES;
                [self popAnimateView:view];
            }
        }];
    }];
}

//-(void)animateButtons
//{
//    CGFloat takePictureNewYPos = CGRectGetHeight(self.bottomBar.frame) - CGRectGetHeight(self.actionButton.frame) - self.pageBorder;
//    
//    [self animateView:@{@"view": self.actionButton, @"yPos": @(takePictureNewYPos)}];
//    [self performSelector:@selector(animateView:) withObject:@{@"view": self.cancelButton, @"yPos": @(self.cancelButtonYPos)} afterDelay:0.3];
//}

//-(void)animateView:(NSDictionary *)dict
//{
//    UIView *view = [dict objectForKey:@"view"];
//    CGFloat yPos = [[dict objectForKey:@"yPos"]floatValue];
//    
//    CGFloat distance = 7;
//    
//    [UIView animateWithDuration:0.7 animations:^
//     {
//         [GeneralMethods setNew_Ypos:yPos - distance ToView:view];
//     }
//     completion:^(BOOL finished)
//     {
//         [UIView animateWithDuration:0.3 animations:^
//          {
//              [GeneralMethods setNew_Ypos:yPos ToView:view];
//          }
//          completion:nil];
//     }];
//}

#pragma mark Image crop & resize handling


#pragma mark Image Handling

- (UIImage*)resizeImage:(UIImage*)image withDimension:(CGFloat)dimension fromYpos:(CGFloat)yPos
{
    if (image == nil)
    {
        NSLog(@"Nothing to resize");
        return nil;
    }
    
    image = [GeneralMethods autoRotateImageAndScale:image];
    
    CGSize size = [image size];
    
    yPos = size.height * yPos / CGRectGetHeight(self.view.frame);
    
    // Only crop if height != width
    UIImage *newImage;
    if (size.height != size.width)
    {
        // Create rectangle that represents a square-cropped image.
        // This assumes height > width (portrait mode photo)
        CGRect rect = CGRectMake(0, yPos, size.width, size.width);
        
        // Create bitmap image from original image data,
        // using rectangle to specify desired crop area
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
        newImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    return newImage;
}

#pragma mark Buttons Action

-(void)actionButtonClicked
{
    if (self.isImageCamera)
    {
        [self blink];
        [self showChooseButton:YES];
        [self enableActionButton:NO];
        [self.cancelButton setTitle:@"Retake" forState:UIControlStateNormal];
        [self takePicture];
    }
    else if (self.isVideoCamera)
    {
        if(self.ttPlayer == nil) // Start Record
        {
            [self startVideoRecording];
        }
        else
        {
            [self.ttPlayer play];
        }
    }
}


-(void)blink
{
    __block UIView *whiteView = [UIView new];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [whiteView setAlpha:0.6];
    [whiteView setFrame:CGRectMake(0, 0, self.visibleArea.frame.size.width, self.visibleArea.frame.size.height)];
    [self.visibleArea addSubview:whiteView];
    
    [UIView animateWithDuration:0.7 animations:^
     {
         [whiteView setAlpha:0];
     }
     completion:^(BOOL finished)
     {
         [whiteView removeFromSuperview];
         whiteView = nil;
     }];
}

-(void)cancelButtonClicked
{
    if (self.isImageCamera)
    {
        if (self.visibleArea.image) // Retake clicked
        {
            [self dismissImageAnimation];
            [self showChooseButton:NO];
            [self enableActionButton:YES];
            [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (self.isVideoCamera)
    {
        if(self.ttPlayer != nil) // Retake clicked
        {
            [self handleVideoRetake];
        }
        
        else // video not exist
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)handleVideoRetake
{
    [self.ttPlayer deallocPlayer];
    self.ttPlayer = nil;
    [self showChooseButton:NO];
    [self enableActionButton:YES];
    [self.stopper stop];
    [self stopRecordingClicked];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

-(void)showChooseButton:(BOOL)show
{
    int alpha = (show ? 1:0);
    [UIView animateWithDuration:0.3 animations:^
     {
         [self.chooseButton setAlpha:alpha];
     }];
}

-(void)showCancelButton:(BOOL)show
{
    int alpha = (show ? 1:0);
    [UIView animateWithDuration:0.3 animations:^
     {
         [self.cancelButton setAlpha:alpha];
     }];
}

-(void)dismissImageAnimation
{
    CGFloat originalyPos = self.visibleArea.frame.origin.y;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGFloat newYpos = self.visibleArea.frame.origin.y - CGRectGetHeight(self.visibleArea.frame);
        [GeneralMethods setNew_Ypos:newYpos ToView:self.visibleArea];
    }
      completion:^(BOOL finished)
     {
         self.visibleArea.image = nil;
         [GeneralMethods setNew_Ypos:originalyPos ToView:self.visibleArea];
     }];
}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ! self.movieFileOutput.isRecording;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark KVO and Notifications

- (void)addObservers
{
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:CapturingStillImageContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
    // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
    // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
    // interruption reasons.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
    [self.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage" context:CapturingStillImageContext];
    [self.ttPlayer removeFromSuperview];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext )
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if ( isCapturingStillImage ) {
            dispatch_async( dispatch_get_main_queue(), ^{
                self.previewView.layer.opacity = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    self.previewView.layer.opacity = 1.0;
                }];
            } );
        }
    }
    else if ( context == SessionRunningContext ) {
        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Only enable the ability to change camera if the device has more than one camera.
            self.switchCameraButton.enabled = isSessionRunning && ( [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1 );
//            self.recordButton.enabled = isSessionRunning;
//            self.stillButton.enabled = isSessionRunning;
        } );
    }
    else
    {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake( 0.5, 0.5 );
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog( @"Capture session runtime error: %@", error );
    
    // Automatically try to restart the session running if media services were reset and the last start running succeeded.
    // Otherwise, enable the user to try to resume the session running.
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async( self.sessionQueue, ^{
            if ( self.isSessionRunning ) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
//                    self.resumeButton.hidden = NO;
                } );
            }
        } );
    }
    else {
//        self.resumeButton.hidden = NO;
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    // In some scenarios we want to enable the user to resume the session running.
    // For example, if music playback is initiated via control center while using AVCam,
    // then the user can let AVCam resume the session running, which will stop music playback.
    // Note that stopping music playback in control center will not automatically resume the session running.
    // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
    BOOL showResumeButton = NO;
    
    // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
    if ( &AVCaptureSessionInterruptionReasonKey ) {
        AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
        NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
        
        if ( reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
            reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient ) {
            showResumeButton = YES;
        }
        else if ( reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps ) {
            // Simply fade-in a label to inform the user that the camera is unavailable.
            self.cameraUnavailableLabel.hidden = NO;
            self.cameraUnavailableLabel.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                self.cameraUnavailableLabel.alpha = 1.0;
            }];
        }
    }
    else {
        NSLog( @"Capture session was interrupted" );
        showResumeButton = ( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive );
    }
    
    if ( showResumeButton ) {
        // Simply fade-in a button to enable the user to try to resume the session running.
//        self.resumeButton.hidden = NO;
//        self.resumeButton.alpha = 0.0;
//        [UIView animateWithDuration:0.25 animations:^{
//            self.resumeButton.alpha = 1.0;
//        }];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    NSLog( @"Capture session interruption ended" );
    
//    if (!self.resumeButton.hidden)
//    {
//        [UIView animateWithDuration:0.25 animations:^{
//            self.resumeButton.alpha = 0.0;
//        } completion:^( BOOL finished ) {
//            self.resumeButton.hidden = YES;
//        }];
//    }
    if ( ! self.cameraUnavailableLabel.hidden ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.cameraUnavailableLabel.alpha = 0.0;
        } completion:^( BOOL finished ) {
            self.cameraUnavailableLabel.hidden = YES;
        }];
    }
}

#pragma mark Actions

-(void)resumeInterruptedSession
{
    dispatch_async( self.sessionQueue, ^{
        // The session might fail to start running, e.g., if a phone or FaceTime call is still using audio or video.
        // A failure to start the session running will be communicated via a session runtime error notification.
        // To avoid repeatedly failing to start the session running, we only try to restart the session running in the
        // session runtime error handler if we aren't trying to resume the session running.
        [self.session startRunning];
        self.sessionRunning = self.session.isRunning;
        if ( ! self.session.isRunning ) {
            dispatch_async( dispatch_get_main_queue(), ^{
                NSString *message = NSLocalizedString( @"Unable to resume", @"Alert message when unable to resume the session running" );
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } );
        }
        else {
            dispatch_async( dispatch_get_main_queue(), ^{
//                self.resumeButton.hidden = YES;
            } );
        }
    } );
}

-(void)startVideoRecording
{
    [self.cancelButton setTitle:@"Retake" forState:UIControlStateNormal];
    self.switchCameraButton.enabled = NO;
    [self.stopper start];
    [self actionButtonIsRecording:YES animated:YES];
    [self showCancelButton:NO];
    [self showChooseButton:NO];
    
    dispatch_async( self.sessionQueue, ^
    {
        if (self.movieFileOutput.isRecording == NO)
        {
            if ( [UIDevice currentDevice].isMultitaskingSupported)
            {
                // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                // callback is not received until AVCam returns to the foreground unless you request background execution time.
                // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                // To conclude this background execution, -endBackgroundTask is called in
                // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
            connection.videoOrientation = previewLayer.connection.videoOrientation;
            
            // Turn OFF flash for video recording.
            [TT_SquareCameraController setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];
            
            // Start recording to a temporary file.
            NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
            [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self activateTimer];
            });
        }
        else
        {
            [self stopRecordingClicked];
        }
    } );
}

- (void)activateTimer {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(limitVideoRecording) userInfo:nil repeats:YES];
        self.count = 0;
    }
    [self.timer fire];
}

- (void)inactiveTimer {
    self.count = 0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)limitVideoRecording {
    if (self.count < 30) {
        self.count++;
        return;
    }
    [self inactiveTimer];
    [self stopRecordingClicked];
}

- (CMTime)playerItemDurationWithPlayer:(AVPlayer *)player {
    AVPlayerItem *playerItem = [player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return [[playerItem asset] duration];
    }
    return(kCMTimeInvalid);
}

-(void)stopRecordingClicked
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [self enableActionButton:YES];
         [self.stopper pause];
         [self inactiveTimer];
         [self actionButtonIsRecording:NO animated:YES];
         [self.movieFileOutput stopRecording];
     }];
}

-(void)switchCameraClicked
{
    if (self.visibleArea.image || self.ttPlayer) // prevent switching camera while media existing
    {
        return;
    }
    
    self.switchCameraButton.enabled = NO;
    [self enableActionButton:NO];
    
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        
        switch ( currentPosition )
        {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
        }
        
        AVCaptureDevice *videoDevice = [TT_SquareCameraController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [self.session beginConfiguration];
        
        // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
        [self.session removeInput:self.videoDeviceInput];
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [TT_SquareCameraController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
        }
        else {
            [self.session addInput:self.videoDeviceInput];
        }
        
        AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ( connection.isVideoStabilizationSupported ) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        
        [self.session commitConfiguration];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.switchCameraButton.enabled = YES;
            [self enableActionButton:YES];
        } );
    } );
}

-(void)enableActionButton:(BOOL)enable
{
    if (self.actionButton.enabled == enable)
    {
        return;
    }
    
    self.actionButton.enabled = enable;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        UIColor *color = [UIColor grayColor];
        if (enable)
        {
            color = [UIColor clearColor];
        }
        [self.actionButton setBackgroundColor:color];
    }];
}

-(void)takePicture
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    DLog(@"about to request a capture from: %@", self.stillImageOutput);
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         }
         else
             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         [self imageDidCapture:image];
     }];
}

-(void)imageDidCapture:(UIImage *)image
{
    [self.visibleArea setImage:[self resizeImage:image withDimension:CGRectGetWidth(self.visibleArea.frame) fromYpos:CGRectGetMaxY(self.topBar.frame)]];
}


//- (IBAction)snapStillImage:(id)sender
//{
//    dispatch_async( self.sessionQueue, ^{
//        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
//        
//        // Update the orientation on the still image output video connection before capturing.
//        connection.videoOrientation = previewLayer.connection.videoOrientation;
//        
//        // Flash set to Auto for Still Capture.
//        [TT_SquareCameraController setFlashMode:AVCaptureFlashModeAuto forDevice:self.videoDeviceInput.device];
//        
//        // Capture a still image.
//        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
//            if ( imageDataSampleBuffer ) {
//                // The sample buffer is not retained. Create image data before saving the still image to the photo library asynchronously.
//                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
//                    if ( status == PHAuthorizationStatusAuthorized ) {
//                        // To preserve the metadata, we create an asset from the JPEG NSData representation.
//                        // Note that creating an asset from a UIImage discards the metadata.
//                        // In iOS 9, we can use -[PHAssetCreationRequest addResourceWithType:data:options].
//                        // In iOS 8, we save the image to a temporary file and use +[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:].
//                        if ( [PHAssetCreationRequest class] ) {
//                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
//                            } completionHandler:^( BOOL success, NSError *error ) {
//                                if ( ! success ) {
//                                    NSLog( @"Error occurred while saving image to photo library: %@", error );
//                                }
//                            }];
//                        }
//                        else {
//                            NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
//                            NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
//                            NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
//                            
//                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                                NSError *error = nil;
//                                [imageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
//                                if ( error ) {
//                                    NSLog( @"Error occured while writing image data to a temporary file: %@", error );
//                                }
//                                else {
//                                    [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
//                                }
//                            } completionHandler:^( BOOL success, NSError *error ) {
//                                if ( ! success ) {
//                                    NSLog( @"Error occurred while saving image to photo library: %@", error );
//                                }
//                                
//                                // Delete the temporary file.
//                                [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
//                            }];
//                        }
//                    }
//                }];
////                [self takePicture];
//            }
//            else {
//                NSLog( @"Could not capture still image: %@", error );
//            }
//        }];
//    } );
//}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)self.previewView.layer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

#pragma mark File Output Recording Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    // Enable the Record button to let the user stop the recording.
    dispatch_async( dispatch_get_main_queue(), ^{
//        self.recordButton.enabled = YES;
//        [self.recordButton setTitle:NSLocalizedString( @"Stop", @"Recording button stop title") forState:UIControlStateNormal];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    if (!error) {
        [TTActivityIndicator showOnView:self.view];
    }
    dispatch_block_t cleanup = ^
    {
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if ( currentBackgroundRecordingID != UIBackgroundTaskInvalid )
        {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    if (error)
    {
        NSLog(@"Movie file finishing error: %@", error);
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if (success)
    {
        // Check authorization status.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
        {
            if (status == PHAuthorizationStatusAuthorized)
            {
//                [self playCapturedMovie:[outputFileURL absoluteString]];
            [self cropFromUrl:outputFileURL];
//                cleanup();
            }
            else
            {
                cleanup();
            }
        }];
    }
    else
    {
        cleanup();
    }
    
    // Enable the Camera and Record buttons to let the user switch camera and start another recording.
    dispatch_async( dispatch_get_main_queue(), ^{
        // Only enable the ability to change camera if the device has more than one camera.
        self.switchCameraButton.enabled = ( [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1 );
//        self.recordButton.enabled = YES;
//        [self.recordButton setTitle:NSLocalizedString( @"Record", @"Recording button record title" ) forState:UIControlStateNormal];
    });
}

-(void)cropFromUrl:(NSURL *)url
{
//    __block NSURL *videoURL = url;
//    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
//    NSString *videoStoragePath;//Set your video storage path to this variable
//    [videoData writeToFile:videoStoragePath atomically:YES];
    
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
    
    CGFloat fixed = (clipVideoTrack.naturalSize.height / CGRectGetWidth(self.view.frame)) * CGRectGetHeight(self.topBar.frame);
    
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
    [self removeVideo:url];
    
    //Export
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Call when finished
             self.capturedVideoURL = exporter.outputURL;
             self.ttPlayer = [[TT_AVPlayer alloc]initWithFrame:self.visibleArea.frame filePath:self.capturedVideoURL autoPlay:NO delegate:self addToView:self.view];
             [self showCancelButton:YES];
             [self showChooseButton:YES];
             [self enableActionButton:YES];
             [TTActivityIndicator dismiss];
             [self saveVideoToFile:exporter];
         });
     }];
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

#pragma mark TTPlayer Delegates

-(void)playerDidStartPlayingVideo:(TT_AVPlayer *)player
{
    [self.stopper start];
}

-(void)playerDidPlayToEndTime:(TT_AVPlayer *)player
{
    [self.stopper pause];
}

- (void)saveVideoToFile:(AVAssetExportSession*)session {
    NSURL *outputURL = session.outputURL;
    //  Save the movie file to the photo library and cleanup.
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^ {
        if ([PHAssetResourceCreationOptions class]) {
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = NO; // Video will not play (iOS 9 and above) if set to YES
            PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
            [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputURL options:options];
        } else {
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            // save complete
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not save movie to photo library" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}


#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode] ) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }
            
            if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode] ) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    } );
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ( device.hasFlash && [device isFlashModeSupported:flashMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma Apple Initial Configure


-(void)appleConfigureDidLoad
{
    // Disable UI. The UI is enabled if and only if the session starts running.
    self.switchCameraButton.enabled = NO;
//    self.recordButton.enabled = NO;
//    self.stillButton.enabled = NO;
    
    // Create the AVCaptureSession.
    self.session = [[AVCaptureSession alloc] init];
    
    /*
    NSDictionary *settings = @{AVVideoCodecKey:AVVideoCodecH264,
                               AVVideoWidthKey:@(video_width),
                               AVVideoHeightKey:@(video_height),
                               AVVideoCompressionPropertiesKey:
                                   @{AVVideoAverageBitRateKey:@(desired_bitrate),
                                     AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31, // Or whatever profile & level you wish to use
                                     AVVideoMaxKeyFrameIntervalKey:@(desired_keyframe_interval)}};
    AVAssetWriterInput* writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
*/
    

    // Setup the preview view.
    self.previewView.session = self.session;
    
    // Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    self.setupResult = AVCamSetupResultSuccess;
    
    // Check video authorization status. Video access is required and audio access is optional.
    // If audio access is denied, audio is not recorded during movie recording.
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult != AVCamSetupResultSuccess ) {
            return;
        }
        
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [TT_SquareCameraController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if ( ! videoDeviceInput ) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        [self.session beginConfiguration];
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                // can only be manipulated on the main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                // -[viewWillTransitionToSize:withTransitionCoordinator:].
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                previewLayer.connection.videoOrientation = initialVideoOrientation;
            } );
        }
        else {
            NSLog( @"Could not add video device input to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if ( ! audioDeviceInput ) {
            NSLog( @"Could not create audio device input: %@", error );
        }
        
        if ( [self.session canAddInput:audioDeviceInput] ) {
            [self.session addInput:audioDeviceInput];
        }
        else {
            NSLog( @"Could not add audio device input to the session" );
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ( [self.session canAddOutput:movieFileOutput] ) {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( connection.isVideoStabilizationSupported ) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
        }
        else {
            NSLog( @"Could not add movie file output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ( [self.session canAddOutput:stillImageOutput] ) {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            [self.session addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        }
        else {
            NSLog( @"Could not add still image output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        [self.session commitConfiguration];
    } );
    
}

-(void)appleConfigureWillAppear
{
    dispatch_async( self.sessionQueue, ^{
        switch ( self.setupResult )
        {
            case AVCamSetupResultSuccess:
            {
                // Only setup observers and start the session running if setup succeeded.
                [self addObservers];
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"AVCam doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                   [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
        }
    } );
}



@end
