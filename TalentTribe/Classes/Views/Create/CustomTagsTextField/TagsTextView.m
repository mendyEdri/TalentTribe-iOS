//
//  TagsTextField.m
//  TalentTribe
//
//  Created by Asi Givati on 11/1/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "TagsTextView.h"
#import "GeneralMethods.h"
#import "StoryTagsSectionView.h"

#define TT_TAGS_TEXT_LENGTH_LIMIT 20

@interface TagsTextView()

@property UIButton *addButton;

@property CGFloat selfInitialWidth;
@property CGFloat contentTextViewInitialWidth;
@property CGFloat distanceBetweenViews;

@end


@implementation TagsTextView

-(instancetype)initWithSize:(CGSize)size tagNum:(int)tagNum
{
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)])
    {
        self.tag = tagNum;
        [self setGeneralProperties];
        self.selfInitialWidth = size.width;
        [self setViews];
    }
    
    return self;
}

-(void)setGeneralProperties
{
    self.distanceBetweenViews = 3;
}

-(void)markTag
{
    UIColor *curentColor = self.backgroundColor;
    UIColor *newColor = [GeneralMethods colorWithRed:255 green:153 blue:153];
    CGFloat animationDuration = 1.2;
    [self setBackgroundColor:newColor];
    
    [UIView animateWithDuration:animationDuration animations:^
     {
         [self setBackgroundColor:curentColor];
     }];
}

-(void)setViews
{
    [self setBackgroundColor:TT_UNFOCUS_COLOR];
    [self.layer setCornerRadius:7];
    self.clipsToBounds = YES;
    [self setCloseButton];
    [self setContentTextField];
}

-(void)updateViewsSize
{
    CGFloat oldWidth = CGRectGetWidth(self.frame);
    
    if (CGRectGetWidth(self.contentTextView.frame) < self.contentTextViewInitialWidth)
    {
//        [GeneralMethods setNew_width:self.contentTextViewInitialWidth ToView:self.contentTextView];
        [GeneralMethods setNew_width:self.selfInitialWidth ToView:self];
    }
    else if(CGRectGetWidth(self.contentTextView.frame) > self.contentTextViewInitialWidth)
    {
        // if the width of the view should grow (width)
        CGFloat newSelfWidth = self.contentTextView.frame.origin.x + CGRectGetWidth(self.contentTextView.frame) + self.distanceBetweenViews;
        
        [GeneralMethods setNew_width:newSelfWidth ToView:self];
    }
    
    if (oldWidth != CGRectGetWidth(self.frame))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:TAGS_SIZE_CHANGED object:@(self.tag)];
    }
    
    if (self.contentTextView.frame.size.width < self.contentTextViewInitialWidth) // prevent from contentTextView to stay in small respond area
    {
        [GeneralMethods setNew_width:self.contentTextViewInitialWidth ToView:self.contentTextView];
    }
}

-(void)setContentTextField
{
    CGFloat xPos = CGRectGetMaxX(self.addButton.frame);
    CGFloat yPos = 0;
    CGFloat width = CGRectGetWidth(self.frame) - CGRectGetWidth(self.addButton.frame) - (self.distanceBetweenViews * 2);
    self.contentTextViewInitialWidth = width;
    CGFloat height = CGRectGetHeight(self.frame);
    CGRect frame = CGRectMake(xPos, yPos, width, height);
    
    self.contentTextView = [[UITextView alloc]initWithFrame:frame];
    self.contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentTextView.delegate = self;
    [self.contentTextView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.contentTextView];
}

-(void)setCloseButton
{
    self.addButton = [[UIButton alloc]init];
    [self updateCloseButtonFrame];
    [self.addButton setTitle:@"x" forState:UIControlStateNormal];
    [self.addButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];
}

-(void)updateCloseButtonFrame
{
    CGSize buttonSize = CGSizeMake(CGRectGetHeight(self.frame) * 0.6, CGRectGetHeight(self.frame));
//    CGFloat xPos = CGRectGetWidth(self.frame) - buttonSize.width;
    CGFloat xPos = self.distanceBetweenViews;
    [self.addButton setFrame:CGRectMake(xPos, 0, buttonSize.width, buttonSize.height)];
}

-(void)closeButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(tagTextViewDidClose:)])
    {
        [self.delegate tagTextViewDidClose:self];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.35 animations:^
     {
         [self setBackgroundColor:TT_FOCUS_COLOR];
     }];
    
    if ([self.delegate respondsToSelector:@selector(tagTextViewDidBeginEditing:)])
    {
        [self.delegate tagTextViewDidBeginEditing:self];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.35 animations:^
     {
         [self setBackgroundColor:TT_UNFOCUS_COLOR];
     }];
}


#pragma mark UITextView Delegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@" "])
    {
        return NO;
    }
    
    if ([text isEqualToString:@""] == NO)
    {
        [GeneralMethods setNew_width:CGRectGetWidth(textView.frame) + 25 ToView:textView]; // to prevent from "sizeToFix" to break line
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= TT_TAGS_TEXT_LENGTH_LIMIT)
    {
        return YES;
    }
    else
    {
        NSUInteger emptySpace = TT_TAGS_TEXT_LENGTH_LIMIT - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.contentTextView becomeFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    [textView sizeToFit];
    [self updateViewsSize];
}

@end
