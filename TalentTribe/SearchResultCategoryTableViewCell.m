//
//  CategorySearchResultCell.m
//  TalentTribe
//
//  Created by Mendy on 16/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "SearchResultCategoryTableViewCell.h"
#import "CategoryCollectionViewCell.h"
#import "LeftAlignCollectionFlowLayout.h"

@interface SearchResultCategoryTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, LeftAlignCollectionViewDelegateLayout, CategoryCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (assign, nonatomic) CGFloat lastHeight;
@end

#define lightGrayColor [UIColor colorWithRed:(240.0/255.0) green:(240.0/255.0) blue:(240.0/255.0) alpha:1.0]
#define cellHeight 32
#define cellMinWidth 60

@implementation SearchResultCategoryTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCategories:(NSArray *)categories {
    if (!categories || categories.count == 0) {
        self.dataSource = @[];
        [self.collectionView reloadData];
        return;
    }
    self.dataSource = categories;
    [self.collectionView reloadData];
    
    if (self.collectionView.contentSize.height == self.lastHeight) {
        // height didn't change, notify not necessary
        return;
    }

    self.collectionView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame), CGRectGetMinY(self.collectionView.frame), CGRectGetWidth(self.collectionView.bounds), self.collectionView.contentSize.height);
    self.lastHeight = CGRectGetHeight(self.collectionView.bounds);
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:didUpdateHeight:)]) {
        [self.delegate collectionView:self.collectionView didUpdateHeight:self.collectionView.contentSize.height];
    }
}

#pragma mark - CategoryCollectionViewCellDelegate

- (void)didSelectCategoryAtIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(categorySelectedAtIndex:)]) {
        [self.delegate categorySelectedAtIndex:index];
    }
}

#pragma mark UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCollectionViewCell *categoryCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionCell" forIndexPath:indexPath];
    categoryCell.delegate = self;
    return categoryCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CategoryCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell setCategory:self.dataSource[indexPath.item] atIndex:indexPath.item];
}

#pragma mark UICollectionView FlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    StoryCategory *category = self.dataSource[indexPath.item];
    CGRect rect = [category.categoryName boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 0.8, flowLayout.itemSize.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : TITILLIUMWEB_SEMIBOLD(15) } context:nil];
    return CGSizeMake(MAX(rect.size.width + 10, cellMinWidth), cellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
