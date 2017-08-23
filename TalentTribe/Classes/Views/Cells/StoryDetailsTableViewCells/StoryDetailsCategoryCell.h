//
//  StoryDetailsCategoryCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/13/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsCell.h"

@class StoryDetailsCategoryCell;

@protocol StoryDetailsCategoryDelegate <NSObject>

- (void)storyDetailsCategoryCell:(StoryDetailsCategoryCell *)cell didSelectCategoryAtIndex:(NSInteger)index;

@end

@interface StoryDetailsCategoryCell : StoryDetailsCell

@property (nonatomic, weak) id <StoryDetailsCategoryDelegate> delegate;

- (void)setCategories:(NSArray *)categories;

+ (CGSize)fittedSizeForItems:(NSArray *)categories width:(CGFloat)width;

@end
