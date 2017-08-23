//
//  TTTagList.h
//  TTTagListTest
//
//  Created by Bogdan Andresyuk on 6/23/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTagListCell : UICollectionViewCell

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) void (^deleteCellAction)();

+ (UIImage *)defaultBackgroudImageForState:(UIControlState)state;
+ (UIEdgeInsets)insets;
+ (UIFont *)font;

@end

@class TTTagList;

@protocol TTTagListDelegate <NSObject>

@optional

- (Class)classForCellInTagList:(TTTagList *)tagList;

- (void)tagList:(TTTagList *)tagList didAddTag:(NSString *)tag;
- (void)tagList:(TTTagList *)tagList didRemovedTag:(NSString *)tag atIndex:(NSInteger)index;

@optional

- (void)tagList:(TTTagList *)tagList shouldChangeHeight:(CGFloat)height;

- (void)tagListDidBeginEditing:(TTTagList *)tagList;
- (void)tagListDidEndEditing:(TTTagList *)tagList;
- (void)tagListDidChange:(TTTagList *)tagList;

- (BOOL)tagListShouldBeginEditing:(TTTagList *)tagList;

@end

@interface TTTagList : UIView

@property (nonatomic, weak) id <TTTagListDelegate> delegate;

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, strong) UIView *inputAccessoryView;

@property (nonatomic, strong) NSString *inputString;

@property (nonatomic) BOOL removeOnTap;
@property (nonatomic) BOOL showsTagButton;
@property (nonatomic) BOOL editingEnabled;

- (NSArray *)tags;
- (NSArray *)getAllTags;
- (void)setTags:(NSArray *)tags;

- (void)addTag:(NSString *)tag;
- (void)removeTagAtIndex:(NSInteger)tagIndex;
- (void)removeAllTags;

- (void)setCurrentTag:(NSString *)tag;

- (void)setScrollDirection:(UICollectionViewScrollDirection)direction;
- (void)setScrollEnabled:(BOOL)enabled;
- (void)setEdgeInsets:(UIEdgeInsets)insets;

- (void)reloadData;

- (void)beginEditing;
- (void)endEditing;
- (id)initWithFrame:(CGRect)frame;

- (void)scrollToLastItem;

@end
