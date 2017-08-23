//
//  CreateStoryViewController.h
//  TalentTribe
//
//  Created by Asi Givati on 10/28/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CreateTabViewController.h"
//#import "RDVTabBarController.h"
#import "CreateStoryAlert.h"
#import "Story.h"
#import "Company.h"
#import "StoryTagsSectionView.h"
#import "StoryMediaCell.h"
#import "CreateGalleryViewController.h"
#import "TT_SquareCameraController.h"
#import "TTTagList.h"
#import "CommManager.h"

#define CS_PAGE_BORDERS 4
#define CS_BORDER_THICKNESS 0.5
#define CS_BORDER_COLOR [UIColor lightGrayColor]
#define CS_PAGE_TEXT_COLOR [UIColor lightGrayColor]
#define CS_PAGE_TITLE_FONT_SIZE 28
#define CS_PAGE_BODY_FONT_SIZE 15
#define CS_VIDEOS_COUNT_LIMIT 1
#define CS_IMAGES_COUNT_LIMIT 10
#define CS_MEDIA_TYPE_ALERT @"Only 1 media type allowed."
#define CS_MAXIMUM_MEDIA_ALERT @"Maximum media selected."

@interface CreateStoryViewController : UIViewController <CreateStoryAlertDelegate,CreateGalleryDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, StoryMediaCellDelegate,TT_SquareCameraControllerDelegate, TTTagListDelegate, CommManagerDelegate> // TagsTextViewDelegate, StoryTagSectionViewDelegate

//@property (strong, nonatomic) NSArray *selectedAssets;
@property (strong, nonatomic) CreateStoryAlert *createStoryAlert;
@property (strong, nonatomic) NSMutableArray *selectedMedia;
@property (strong, nonatomic) NSString *storyIdToLoad;
@property (assign, nonatomic) BOOL *shouldDismiss;

//-(void)showCreateStoryAlertWithMode:(AlertModes)mode;
-(void)publishStory;

@end