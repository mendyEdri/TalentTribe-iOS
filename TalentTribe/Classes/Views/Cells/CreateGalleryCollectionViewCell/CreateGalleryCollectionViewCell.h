//
//  CreateGalleryCollectionViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGalleryCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *selectionView;
-(void)videoSignNeeded:(BOOL)videoSign;

@end
