//
//  StoryDetailsCategoryCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/13/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryDetailsCategoryCell.h"
#import "DWTagList.h"

@interface StoryDetailsCategoryCell () <DWTagListDelegate>

@property (nonatomic, weak) IBOutlet DWTagList *tagList;

@end

@implementation StoryDetailsCategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [StoryDetailsCategoryCell styleTagList:self.tagList];
    self.tagList.tagDelegate = self;
}

- (void)setCategories:(NSArray *)categories {
    [self.tagList setTags:categories];
}

+ (CGSize)fittedSizeForItems:(NSArray *)categories width:(CGFloat)width {
    static DWTagList *tagList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagList = [[DWTagList alloc] initWithFrame:CGRectZero];
        [StoryDetailsCategoryCell styleTagList:tagList];
    });
    [tagList setFrame:CGRectMake(0, 0, width, MAXFLOAT)];
    [tagList setTags:categories];
    [tagList display];
    return [tagList fittedSize];
}

+ (void)styleTagList:(DWTagList *)tagList {
    [tagList setCornerRadius:4.0f];
    [tagList setBackgroundColor:[UIColor clearColor]];
    [tagList setTagBackgroundColor:UIColorFromRGB(0xedf0f5)];
    [tagList setTextColor:UIColorFromRGB(0x8d8d8d)];
    [tagList setFont:[UIFont fontWithName:@"TitilliumWeb-Light" size:13]];
    [tagList setBorderWidth:0.0f];
    [tagList setLabelMargin:15.0f];
}

#pragma  DWTagListDelegate

- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex {
    [self.delegate storyDetailsCategoryCell:self didSelectCategoryAtIndex:tagIndex];
}

@end
