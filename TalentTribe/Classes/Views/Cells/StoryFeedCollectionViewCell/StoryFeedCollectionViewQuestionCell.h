//
//  StoryFeedCollectionViewQuestionCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryFeedCollectionViewCell.h"

@interface StoryFeedCollectionViewQuestionCell : StoryFeedCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *questionAnswersLabel;
@property (nonatomic, weak) IBOutlet UILabel *readMoreLabel;

- (void)setIndex:(NSInteger)index;

@end
