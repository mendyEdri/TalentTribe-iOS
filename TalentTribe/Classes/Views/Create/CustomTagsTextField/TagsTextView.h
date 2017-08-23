//
//  TagsTextView.h
//  TalentTribe
//
//  Created by Asi Givati on 11/1/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TT_FOCUS_COLOR [GeneralMethods colorWithRed:176 green:192 blue:222]
#define TT_UNFOCUS_COLOR [UIColor lightGrayColor]

@class TagsTextView;

@protocol TagsTextViewDelegate <NSObject>

-(void)tagTextViewDidBeginEditing:(TagsTextView *)tagTextView;

@optional

-(void)tagTextViewDidClose:(TagsTextView *)tagTextView;

@end

@interface TagsTextView : UIView <UITextViewDelegate>

@property UITextView *contentTextView;

-(instancetype)initWithSize:(CGSize)size tagNum:(int)tagNum;
-(void)markTag;

@property (weak, nonatomic) id <TagsTextViewDelegate> delegate;

@end