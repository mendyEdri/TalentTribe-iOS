//
//  CreateGalleryViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateGalleryViewController;

@protocol CreateGalleryDelegate <NSObject>

- (void)createGalleryViewController:(CreateGalleryViewController *)controller didSelectAssets:(NSArray *)assets;
- (void)createGalleryViewControllerShouldDismiss:(CreateGalleryViewController *)controller;

@optional
- (NSArray *)selectedAssets;
@end

@interface CreateGalleryViewController : UIViewController

@property (nonatomic, weak) id <CreateGalleryDelegate> delegate;
@property (assign, nonatomic) BOOL allowVideo;
@property int numOfVideosAllowed;
@property int numOfImagesAllowed;

@end
