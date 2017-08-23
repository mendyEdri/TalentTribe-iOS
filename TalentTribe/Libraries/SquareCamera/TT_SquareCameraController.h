//
//  SquareCamera.h
//  TalentTribe
//
//  Created by Asi Givati on 11/9/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TT_AVPlayer.h"

@class TT_SquareCameraController;

@protocol TT_SquareCameraControllerDelegate <NSObject>

-(void)squareCameraController:(TT_SquareCameraController *)squareCamera didCaptureImage:(UIImage *)image;
-(void)squareCameraController:(TT_SquareCameraController *)squareCamera didCaptureVideoInPath:(NSURL *)filePath withThumbnailImage:(UIImage *)thumbnailImage;
@end


@import UIKit;

@interface TT_SquareCameraController : UIViewController <TT_AVPlayerDelegate>

@property (weak,nonatomic) id <TT_SquareCameraControllerDelegate> delegate;
@property CFStringRef cameraMode;

@end
