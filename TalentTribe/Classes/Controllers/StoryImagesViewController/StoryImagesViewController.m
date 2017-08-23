//
//  StoryImagesViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/9/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryImagesViewController.h"
#import "StoryDetailsCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TTGradientHandler.h"
#import "Story.h"

@interface StoryImagesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet TTCustomGradientView *gradientOverlayView;

@end

@implementation StoryImagesViewController

#pragma mark Data reloading

- (void)reloadData {
    [self.collectionView reloadData];
    [self updateCountLabel];
}

- (void)updateCountLabel {
    NSIndexPath *selectedItem = [self.collectionView indexPathsForVisibleItems].firstObject;
    NSString *highlightString = [NSString stringWithFormat:@"%ld", selectedItem.row + 1];
    NSString *countString = [NSString stringWithFormat:@"%@ / %ld", highlightString, (unsigned long)self.imagesArray.count];
    self.countLabel.attributedText = [TTUtils attributedStringForString:countString highlight:highlightString highlightedColor:UIColorFromRGB(0xb4b4b4) defaultColor:UIColorFromRGB(0xb4b4b4)];
}

#pragma mark Interface actions

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoryDetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[self.imagesArray objectAtIndex:indexPath.row] objectForKeyOrNil:kFullscreenImage]]];
    return cell;
}

#pragma mark UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateCountLabel];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCountLabel];
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.gradientOverlayView setColors:@[UIColorFromRGBA(0x000000, 1.0f), UIColorFromRGBA(0x000000, 0.0f), UIColorFromRGBA(0x000000, 1.0f)]];
    [self.gradientOverlayView setLocations:@[@(0.0f), @(0.5f), @(1.0f)]];
}

@end
