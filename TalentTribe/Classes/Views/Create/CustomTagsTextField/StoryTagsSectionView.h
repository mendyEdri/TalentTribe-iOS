//
//  StoryTagsSectionView.h
//  TalentTribe
//
//  Created by Asi Givati on 11/2/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsTextView.h"
#define TAGS_SIZE_CHANGED @"tagSizeChanged"

@protocol StoryTagSectionViewDelegate <NSObject>

-(void)tagSectionWholeViewFrameDidChange;
-(void)tagTextViewDidBeginEditing:(TagsTextView *)tagTextView;

@end

@interface StoryTagsSectionView : UIView <TagsTextViewDelegate>

-(instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color;
@property (weak,nonatomic) id <StoryTagSectionViewDelegate> delegate;

@end
