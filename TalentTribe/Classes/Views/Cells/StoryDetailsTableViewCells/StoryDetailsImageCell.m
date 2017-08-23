//
//  StoryDetailsImageCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsImageCell.h"

@implementation StoryDetailsImageCell

- (void)setCollectionViewDataSource:(id <UICollectionViewDataSource>)dataSource delegate:(id <UICollectionViewDelegate>)delegate {
    self.collectionView.dataSource = dataSource;
    self.collectionView.delegate = delegate;
    
    [self.collectionView reloadData];
}

@end
