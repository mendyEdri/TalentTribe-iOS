//
//  StoryDetailsImageCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsCell.h"

@interface StoryDetailsImageCell : StoryDetailsCell

@property (nonatomic, weak) IBOutlet UIButton *showImagesButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

- (void)setCollectionViewDataSource:(id <UICollectionViewDataSource>)dataSource delegate:(id <UICollectionViewDelegate>)delegate;

@end
