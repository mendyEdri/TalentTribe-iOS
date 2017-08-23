//
//  CategorySearchResultCell.h
//  TalentTribe
//
//  Created by Mendy on 16/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryCategory.h"

@protocol SearchResultCategoryCellDelegate <NSObject>
- (void)collectionView:(UICollectionView *)collectionView didUpdateHeight:(CGFloat)height;
- (void)categorySelectedAtIndex:(NSInteger)index;
@end

@interface SearchResultCategoryTableViewCell : UITableViewCell
- (void)setCategories:(NSArray *)categories;
@property (assign, nonatomic) id<SearchResultCategoryCellDelegate>delegate;
@end
