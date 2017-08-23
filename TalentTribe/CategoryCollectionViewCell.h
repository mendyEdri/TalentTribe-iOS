//
//  CategoryCollectionViewCell.h
//  TalentTribe
//
//  Created by Mendy on 16/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryCategory.h"

@protocol CategoryCollectionViewCellDelegate <NSObject>
- (void)didSelectCategoryAtIndex:(NSInteger)index;
@end

@interface CategoryCollectionViewCell : UICollectionViewCell
- (void)setCategory:(StoryCategory *)category atIndex:(NSInteger)index;
@property (weak, nonatomic) id<CategoryCollectionViewCellDelegate>delegate;
@end
