//
//  CreateGalleryGroupView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SelectGroupBlock)(ALAssetsGroup *group, NSInteger index);

@interface CreateGalleryGroupView : UIView

@property (nonatomic, copy) SelectGroupBlock selectionBlock;
@property (nonatomic, weak) NSArray *groupsContainer;
@property BOOL visible;

- (void)showInView:(UIView *)superview animated:(BOOL)animated completion:(void(^)(void))completion;
- (void)hideViewAnimated:(BOOL)animated completion:(void(^)(void))completion;

- (void)reloadData;

@end
