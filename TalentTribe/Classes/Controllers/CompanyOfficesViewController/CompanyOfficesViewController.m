//
//  CompanyOfficesViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyOfficesViewController.h"
#import "CompanyInfo.h"
#import "CompanyOfficesCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MessageTextView.h"

@interface CompanyOfficesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *emptyContainer;
@property (nonatomic, weak) IBOutlet UILabel *emptyMessageLabel;

@property (nonatomic, strong) NSArray *imagesContainer;

@end

@implementation CompanyOfficesViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    if (self.company.companyInfo.officePhotos.count) {
        [self.collectionView setHidden:NO];
        [self.emptyContainer setHidden:YES];
        self.imagesContainer = self.company.companyInfo.officePhotos;
        [self.collectionView reloadData];
    } else {
        [MessageTextView textViewWithHeader:@"Office Photos" message:[NSString stringWithFormat:@"Please visit our website: %@", self.company.webLink] onView:self.view completion:^(id result, NSError *error) {
            UITextView *message = (UITextView *)result;
            [self.view addSubview:message];
        }];
        [self.collectionView setHidden:YES];
        [self.emptyContainer setHidden:NO];
    }
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesContainer.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *storyImageURL = [self.imagesContainer objectAtIndex:indexPath.row];
    CompanyOfficesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.activityIndicator.hidden = NO;
    [cell.activityIndicator startAnimating];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:storyImageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        cell.activityIndicator.hidden = YES;
    }];
    return cell;
}

#pragma mark UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *storyImageURL = [self.imagesContainer objectAtIndex:indexPath.row];
    if (storyImageURL.length) {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:storyImageURL]]) {
            UIImage *storyImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:storyImageURL];
            return CGSizeMake(collectionView.bounds.size.width, ceil(storyImage.size.height * collectionView.bounds.size.width / storyImage.size.width));
        } else {
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.width);
        }
    } else {
        return CGSizeMake(self.view.bounds.size.width, 0);
    }
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.collectionView;
}

#pragma mark View lifeCycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
}

@end
