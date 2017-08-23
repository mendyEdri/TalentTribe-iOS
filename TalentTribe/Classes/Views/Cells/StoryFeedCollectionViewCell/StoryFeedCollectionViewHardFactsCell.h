//
//  StoryFeedCollectionViewHardFactsCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedCollectionViewCell.h"

@interface StoryFeedCollectionViewHardFactsCell : StoryFeedCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *aboutLabel;

@property (nonatomic, weak) IBOutlet UIView *leftItemContainer;
@property (nonatomic, weak) IBOutlet UIView *rightItemContainer;
@property (nonatomic, weak) IBOutlet UIView *separatorView;

@property (nonatomic, weak) IBOutlet UILabel *leftItemTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *leftItemValueLabel;

@property (nonatomic, weak) IBOutlet UILabel *rightItemTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightItemValueLabel;
@property (nonatomic, weak) IBOutlet UIButton *openPositionsButton;
@end
