//
//  StoryTagsSectionView.m
//  TalentTribe
//
//  Created by Asi Givati on 11/2/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "StoryTagsSectionView.h"
#import "GeneralMethods.h"
#import "CreateStoryViewController.h"
#define ST_ANIMATION_DURATION 0.15

@interface StoryTagsSectionView()

@property UIView *tagsAreaView;
@property NSMutableArray *tagsArray;
@property UILabel *hashTagLabel;
@property UIButton *addButton;
@property CGFloat tagsHeight;
@property CGFloat tagsMinWidth;
@property CGFloat distanceBetweenTags;

/// Return the height of the StoryTagsSectionView obj durnig the init process
@property CGFloat selfInitialHeight;

@end

@implementation StoryTagsSectionView

-(instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:color];
        self.selfInitialHeight = CGRectGetHeight(frame);
        [self setGeneralProperties];
        [self setViews];
//        [self setBackgroundColor:[UIColor redColor]];
    }
    
    return self;
}

-(void)setGeneralProperties
{
    self.tagsHeight = CGRectGetHeight(self.frame) * 0.8;
    self.tagsMinWidth = self.tagsHeight * 1.8;
    self.distanceBetweenTags = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTagsFromNotification:) name:TAGS_SIZE_CHANGED object:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

-(void)reloadTagsFromNotification:(NSNotification *)notification
{
    TagsTextView *currentTag = self.tagsArray[[[notification object]intValue]];
    [self checkCurrentTagFitSize:currentTag];
    [self reloadTagViewsFromIndex:[[notification object]intValue] + 1]; // currentTag.tag + 1
}

-(void)checkCurrentTagFitSize:(TagsTextView *)currentTag
{
    // this method should check get the best position for the current tag while we typing
    
    CGFloat lineLimit;
    
    bool firstLine = (currentTag.frame.origin.y == self.distanceBetweenTags);
    
    if(firstLine)
    {
        lineLimit = self.addButton.frame.origin.x;
    }
    else
    {
        lineLimit = CGRectGetWidth(self.frame);
    }
    
    // check if the current tag we typing in (maxWidth) is bigger than addButton xPos
    if (CGRectGetMaxX(currentTag.frame) + self.distanceBetweenTags >= lineLimit)
    {
        CGFloat newYpos = CGRectGetMaxY(currentTag.frame) + self.distanceBetweenTags;
        
        [UIView animateWithDuration:ST_ANIMATION_DURATION animations:^{
           [GeneralMethods setNew_origin_WithXpos:self.distanceBetweenTags andYpos:newYpos ToView:currentTag];
        }];
    }
    // check if the current tag we typing in can go up to prev line
    else if (((int)currentTag.frame.origin.x == (int)self.distanceBetweenTags) && currentTag.tag > 0)
    {
        TagsTextView *prevTag = self.tagsArray[currentTag.tag - 1];
        bool prevIsInFirstLine = (prevTag.frame.origin.y == self.distanceBetweenTags);
        CGFloat prevLineLimit;
        
        if (prevIsInFirstLine)
        {
            prevLineLimit = self.addButton.frame.origin.x;
        }
        else
        {
            prevLineLimit = CGRectGetWidth(self.frame);
        }
        
        if ((CGRectGetMaxX(prevTag.frame) + self.distanceBetweenTags + CGRectGetWidth(currentTag.frame) + self.distanceBetweenTags) < prevLineLimit)
        {
            CGFloat newXpos = CGRectGetMaxX(prevTag.frame) + self.distanceBetweenTags;
            CGFloat newYpos = prevTag.frame.origin.y;
            
            [UIView animateWithDuration:ST_ANIMATION_DURATION animations:^{
                [GeneralMethods setNew_origin_WithXpos:newXpos andYpos:newYpos ToView:currentTag];
            }];
        }
    }
}

-(void)setViews
{
    [self setHashTagLabelToTagsSectionView];
    [self setAddTagButton];
    [self setTagsAreaView];
    [self reloadTagViewsFromIndex:0];
}

-(void)setAddTagButton
{
    CGFloat buttonSize = CGRectGetHeight(self.frame);
    CGFloat xPos = CGRectGetWidth(self.frame) - buttonSize;
    CGFloat yPos = 0;
    CGFloat fontSize = [GeneralMethods getCalculateSizeWithScreenSize:screenHeight AndElementSize:15];
    
    self.addButton = [[UIButton alloc]initWithFrame:CGRectMake(xPos, yPos, buttonSize, buttonSize)];
    self.addButton.titleLabel.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:fontSize];
    [self.addButton setTitle:@"+" forState:UIControlStateNormal];
    [self.addButton setTitleColor:CS_PAGE_TEXT_COLOR forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addTagButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];
    
//    // Left Border
//    UIView *leftBorder = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.7, CGRectGetHeight(self.addButton.frame))];
//    [leftBorder setBackgroundColor:CS_BORDER_COLOR];
//    [self.addButton addSubview:leftBorder];
//    
//    
//    // Bottom Border
//    UIView *bottomBorder = [[UIView alloc]initWithFrame:CGRectMake(self.addButton.frame.origin.x, CGRectGetMaxY(self.addButton.frame), CGRectGetWidth(self.addButton.frame), CS_BORDER_THICKNESS)];
//    [bottomBorder setBackgroundColor:CS_BORDER_COLOR];
//    [self addSubview:bottomBorder];
}


#pragma mark TagTextView Delegate

-(void)tagTextViewDidClose:(TagsTextView *)tagTextView
{
    if([self.tagsArray count] == 1)
    {
        return;
    }
    
    [self.tagsArray removeObjectAtIndex:tagTextView.tag];
    [tagTextView removeFromSuperview];
    
    for (int i = 0; i< [self.tagsArray count] ; i++)
    {
        ((TagsTextView *)self.tagsArray[i]).tag = i;
    }
    
    [self reloadTagViewsFromIndex:0];
}

-(void)tagTextViewDidBeginEditing:(TagsTextView *)tagTextView
{    
    if ([self.delegate respondsToSelector:@selector(tagTextViewDidBeginEditing:)])
    {
        [self.delegate tagTextViewDidBeginEditing:tagTextView];
    }
}


-(void)addTagButtonClicked
{
    if ([self newTagAllowed] == NO)
    {
        return;
    }
    
    TagsTextView *tag = [[TagsTextView alloc]initWithSize:CGSizeMake(self.tagsMinWidth, self.tagsHeight) tagNum:(int)[self.tagsArray count]];
    tag.delegate = self;
    
    if ([self.tagsArray count] > 0)
    {
        [tag.contentTextView becomeFirstResponder];
    }
    
    [self.tagsArray addObject:tag];
    [self.tagsAreaView addSubview:tag];
    [self reloadTagViewsFromIndex:0];
}

-(BOOL)newTagAllowed
{
    BOOL allowd = YES;
    
    for (TagsTextView *tag in self.tagsArray)
    {
        if ([tag.contentTextView.text isEqualToString:@""])
        {
            [tag markTag];
            allowd = NO;
        }
    }
    
    return allowd;
}

-(void)reloadTagViewsFromIndex:(int)index
{
    if (!self.tagsArray)
    {
        self.tagsArray = [NSMutableArray new];
        [self addTagButtonClicked];
        return;
    }

//    for (int i = index; i < [self.tagsArray count]; i++)
//    {
//        [self.tagsArray[i] removeFromSuperview];
//    }
    
    CGFloat currentXpos;
    CGFloat currentYpos;
    BOOL firstLine; // will tell if the current line we working on is the first line (shorter line)
    
    if (index == 0)
    {
        currentXpos = CGRectGetMaxX(self.hashTagLabel.frame);
        currentYpos = self.distanceBetweenTags;
        firstLine = YES;
    }
    else
    {
        TagsTextView *lastTag = self.tagsArray[index-1];
        currentXpos = CGRectGetMaxX(lastTag.frame) + self.distanceBetweenTags;
        currentYpos = lastTag.frame.origin.y;
        firstLine = (self.distanceBetweenTags == 0);
    }
    
    for (int i = index; i < [self.tagsArray count]; i++)
    {
        TagsTextView *tag = self.tagsArray[i];
        if (self.distanceBetweenTags == 0)
        {
            self.distanceBetweenTags = (self.selfInitialHeight / 2) - (CGRectGetHeight(tag.frame) / 2);
            currentYpos = self.distanceBetweenTags;
        }
        
        if (((currentYpos == self.distanceBetweenTags) && (currentXpos + CGRectGetWidth(tag.frame) + self.distanceBetweenTags) > self.addButton.frame.origin.x) ||
            ((currentYpos == self.distanceBetweenTags) == NO && (currentXpos + CGRectGetWidth(tag.frame) + self.distanceBetweenTags) > CGRectGetMaxX(self.tagsAreaView.frame)))
            // breakline needed
        {
            firstLine = NO;
            currentXpos = self.distanceBetweenTags;
            currentYpos += (CGRectGetHeight(tag.frame) + self.distanceBetweenTags);
        }
        
        [UIView animateWithDuration:ST_ANIMATION_DURATION animations:^
        {
            [tag setFrame:CGRectMake(currentXpos, currentYpos, CGRectGetWidth(tag.frame), CGRectGetHeight(tag.frame))];
        }];
        
        
        currentXpos += CGRectGetWidth(tag.frame) + self.distanceBetweenTags;
    }
    
    [self updateWholeViewFrame];
}

-(void)updateWholeViewFrame
{
//    [self setBackgroundColor:[UIColor redColor]];
    if ([self.tagsArray count] > 0)
    {
        TagsTextView *lastTag = [self.tagsArray lastObject];
        CGFloat tagMaxHeight = CGRectGetMaxY(lastTag.frame) + self.distanceBetweenTags;

        if (CGRectGetHeight(self.frame) != tagMaxHeight || CGRectGetHeight(self.tagsAreaView.frame) != tagMaxHeight)
        {
            [UIView animateWithDuration:ST_ANIMATION_DURATION animations:^
             {
                 [GeneralMethods setNew_height:tagMaxHeight ToView:self.tagsAreaView];
                 [GeneralMethods setNew_height:tagMaxHeight ToView:self];
                 if ([self.delegate respondsToSelector:@selector(tagSectionWholeViewFrameDidChange)])
                 {
                     [self.delegate tagSectionWholeViewFrameDidChange];
                 }
             }];
        }
    }
}

-(void)setHashTagLabelToTagsSectionView
{
    CGFloat fontSize = [GeneralMethods getCalculateSizeWithScreenSize:CS_PAGE_BODY_FONT_SIZE AndElementSize:screenHeight];
    CGFloat xPos = CS_PAGE_BORDERS;
    CGFloat height = [GeneralMethods getCalculateSizeWithScreenSize:fontSize + 6 AndElementSize:screenHeight];
    CGFloat yPos = (CGRectGetHeight(self.frame) / 2) - (height / 2);
    CGFloat width = height; // square
    
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    
    self.hashTagLabel = [GeneralMethods createLableWithText:@" #" withFrame:frame withTextColor:CS_PAGE_TEXT_COLOR withFontSize:fontSize withAlignmentCenter:NO boldText:NO fromCharNumber:0 length:0 withFontName:@"TitilliumWeb-SemiBold" addToView:self];
}

-(void)setTagsAreaView
{
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    
    self.tagsAreaView = [[UIView alloc]initWithFrame:frame];
    [self insertSubview:self.tagsAreaView belowSubview:self.addButton];
}

@end
