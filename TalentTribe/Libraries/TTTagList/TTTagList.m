//
//  TTTagList.m
//  TTTagListTest
//
//  Created by Bogdan Andresyuk on 6/23/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTTagList.h"

@implementation TTTagListCell

+ (UIImage *)defaultBackgroudImageForState:(UIControlState)state {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    bgView.layer.cornerRadius = 4.0f;
    bgView.layer.masksToBounds = YES;
    bgView.opaque = NO;
    UIImage *backgroundImage;
    if (state == UIControlStateNormal) {
        [bgView setBackgroundColor:[UIColor colorWithRed:237.0f / 255.0f green:240.0f / 255.0f blue:245.0f / 255.0f alpha:1.0f]];
        static UIImage *normalImage;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            normalImage = [[self imageWithView:bgView] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        });
        backgroundImage = normalImage;
    } else if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
        [bgView setBackgroundColor:[UIColor colorWithRed:217.0f / 255.0f green:220.0f / 255.0f blue:210.0f / 255.0f alpha:1.0f]];
        static UIImage *highlightedImage;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            highlightedImage = [[self imageWithView:bgView] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        });
        backgroundImage = highlightedImage;
    }
    return backgroundImage;
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return copied;
}

+ (UIFont *)font {
    return TITILLIUMWEB_LIGHT(16.0f);
}

+ (UIEdgeInsets)insets {
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        insets = UIEdgeInsetsMake(0, 5, 0, 5);
    });
    return insets;
}

@end

@interface TTTagCell : TTTagListCell

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) NSLayoutConstraint *trailingConstraint;

@end

@implementation TTTagCell

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[TTTagCell defaultBackgroudImageForState:UIControlStateNormal]];
    //self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[TTTagCell defaultBackgroudImageForState:UIControlStateHighlighted]];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor clearColor];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.font = [TTTagCell font];
    textField.textColor = UIColorFromRGB(0x8d8d8d);
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    
    self.textField = textField;
    
    [self.contentView addSubview:textField];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [deleteButton setImage:[UIImage imageNamed:@"close_tag"] forState:UIControlStateNormal];
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.translatesAutoresizingMaskIntoConstraints = YES;
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:10];
    deleteButton.hidden = NO;
    [deleteButton addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteButton = deleteButton;
    [self.contentView addSubview:deleteButton];
    
    UIEdgeInsets insets = [TTTagCell insets];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[textField]-(%f)-|", insets.top, insets.bottom] options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%f)-[textField]-(%f)-|", insets.left, insets.right] options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
    __block NSLayoutConstraint *trailingConstraint;
    
    [self.contentView.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
       if ((constraint.relation == NSLayoutRelationEqual) &&
           (constraint.firstItem == self.contentView) &&
           (constraint.secondItem == textField) &&
           (constraint.firstAttribute == NSLayoutAttributeTrailing) &&
           (constraint.secondAttribute == NSLayoutAttributeTrailing)) {
           trailingConstraint = constraint;
           *stop = YES;
       }
    }];
    
    self.trailingConstraint = trailingConstraint;
    CGFloat buttonSize = self.contentView.frame.size.height;
    self.deleteButton.frame = CGRectMake(self.contentView.frame.size.width - 20, 0, 20, buttonSize);

    self.trailingConstraint.constant = [TTTagCell insets].right + self.deleteButton.frame.size.width - 5;

    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonSize = self.contentView.frame.size.height;
    self.deleteButton.frame = CGRectMake(self.contentView.frame.size.width - buttonSize, 0, buttonSize, buttonSize);
}

- (void)deletePressed {
    if(self.deleteCellAction) self.deleteCellAction();
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    self.deleteButton.hidden = !selected;
//    self.trailingConstraint.constant = [TTTagCell insets].right + (selected ? self.deleteButton.frame.size.width : 0.0f);
//}

@end


@interface TTAddCell : UICollectionViewCell

@property (nonatomic, copy) void (^addCellAction)();

@property (nonatomic, strong) UIButton *addButton;

@end

@implementation TTAddCell

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [addButton setImage:[UIImage imageNamed:@"user_add"] forState:UIControlStateNormal];
    addButton.backgroundColor = [UIColor clearColor];
    addButton.translatesAutoresizingMaskIntoConstraints = YES;
    addButton.hidden = NO;
    [addButton.imageView setContentMode:UIViewContentModeCenter];
    [addButton addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton = addButton;
    
    [self.contentView addSubview:addButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.addButton.frame = self.contentView.bounds;
}

- (void)addPressed {
    if (self.addCellAction) self.addCellAction();
}

@end


typedef enum {
    SectionItemTag,
    SectionItemAdd,
    sectionItemsCount
} Sectionitem;

@interface TTTagList () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *tagsList;

@property BOOL editing;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) UIButton *tagButton;

@property Class cellClass;

@property CGFloat minHeight;

@property (nonatomic, strong) NSTimer *dismissTimer;

@end

@implementation TTTagList

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.editing = NO;
    
    self.editingEnabled = YES;
    self.showsTagButton = YES;
    self.removeOnTap = NO;
    
    self.cellClass = [TTTagCell class];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumInteritemSpacing:5.0f];
    [layout setMinimumLineSpacing:5.0f];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    
    [collectionView registerClass:self.cellClass forCellWithReuseIdentifier:@"tagCell"];
    [collectionView registerClass:[TTAddCell class] forCellWithReuseIdentifier:@"addCell"];
    
    self.collectionView = collectionView;
    
    [self addSubview:collectionView];
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [placeholderLabel setFont:TITILLIUMWEB_SEMIBOLD(20.0f)];
    [placeholderLabel setTextColor:UIColorFromRGB(0xdddddd)];
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.placeholderLabel = placeholderLabel;
    
    [self addSubview:placeholderLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[placeholderLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholderLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[placeholderLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholderLabel)]];
    
    self.tagButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
    [self.tagButton addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_tagButton setImage:[UIImage imageNamed:@"#_disable"] forState:UIControlStateNormal];
    [_tagButton setImage:[UIImage imageNamed:@"#_"] forState:UIControlStateSelected];
    [collectionView addSubview:_tagButton];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    
    self.tagsList = [NSMutableArray new];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    tap.delegate = self;
    [tap setCancelsTouchesInView:NO];
    [self addGestureRecognizer:tap];
}

- (NSLayoutConstraint *)heightConstraint {
    if (!_heightConstraint) {
        for (NSLayoutConstraint *constraint in self.constraints) {
            if ((constraint.firstAttribute == NSLayoutAttributeHeight) && (constraint.relation == NSLayoutRelationEqual)) {
                _heightConstraint = constraint;
                _minHeight = constraint.constant;
                break;
            }
        }
        NSAssert(_heightConstraint, @"Please define height constant for tag list");
    }
    return _heightConstraint;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)direction {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    [layout setScrollDirection:direction];
    [layout invalidateLayout];
}

- (void)setScrollEnabled:(BOOL)enabled {
    [self.collectionView setScrollEnabled:enabled];
}

- (void)setShowsTagButton:(BOOL)showsTagButton {
    [self.tagButton setHidden:!showsTagButton];
}

- (void)setEdgeInsets:(UIEdgeInsets)insets {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [layout setSectionInset:insets];
    [layout invalidateLayout];
}

#pragma mark Tap handling

- (void)tapOnView:(UIGestureRecognizer *)recognizer {
    if (self.editingEnabled) {
        [self beginEditing];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.tagButton]) {
        return NO;
    }
    return YES;
}

- (void)beginEditing {
    [self invalidateTimer];
    if (!self.editing) {
        self.placeholderLabel.hidden = YES;
        self.tagButton.selected = YES;
        self.editing = YES;
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagsList.count inSection:SectionItemTag]]];
        [self scrollToLastItem];
        [self updateHeightConstraint];
        if ([self.delegate respondsToSelector:@selector(tagListDidBeginEditing:)]) {
            [self.delegate tagListDidBeginEditing:self];
        }
    }
}

- (void)endEditing {
    [self endEditing:YES];
    if (self.editing) {
        self.tagButton.selected = NO;
        self.editing = NO;
        if (self.inputString.length > 0) {
            [self.tagsList addObject:self.inputString];
            if ([self.delegate respondsToSelector:@selector(tagList:didAddTag:)]) {
                [self.delegate tagList:self didAddTag:self.inputString];
            }
            self.inputString = nil;
        } else {
            self.inputString = nil;
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagsList.count inSection:SectionItemTag]]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemAdd]];
        }
        if (self.tagsList.count == 0) {
            self.placeholderLabel.hidden = NO;
        }
        [self updateHeightConstraint];
        if ([self.delegate respondsToSelector:@selector(tagListDidEndEditing:)]) {
            [self.delegate tagListDidEndEditing:self];
        }
    }
}

- (void)tagPressed:(UIButton *)sender {
    if (self.editingEnabled) {
        if(self.editing) [self endEditing];
        else [self beginEditing];
    }
}

#pragma mark Data reloading

- (void)reloadData {
    
    Class newClass;
    if ([self.delegate respondsToSelector:@selector(classForCellInTagList:)]) {
        newClass = [self.delegate classForCellInTagList:self];
    } else {
        newClass = [TTTagCell class];
    }
    
    if (newClass != self.cellClass) {
        self.cellClass = newClass;
        [self.collectionView registerClass:newClass forCellWithReuseIdentifier:@"tagCell"];
    }
    
    [self.collectionView reloadData];
    /*if (self.tagsList.count || self.editing) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.tagsList.count - 1 + (self.editing ? 1 : 0) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }*/
    [self updateHeightConstraint];
    [self scrollToLastItem];
}

- (void)updateHeightConstraint {
    if (self.collectionView.frame.size.height != self.collectionView.collectionViewLayout.collectionViewContentSize.height) {
        if ([self.delegate respondsToSelector:@selector(tagList:shouldChangeHeight:)]) {
            [self.delegate tagList:self shouldChangeHeight:self.collectionView.collectionViewLayout.collectionViewContentSize.height];
        }
    }
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(tagListShouldBeginEditing:)]) {
            return [self.delegate tagListShouldBeginEditing:self];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self invalidateTimer];
    if ([self.delegate respondsToSelector:@selector(tagListDidBeginEditing:)]) {
        [self.delegate tagListDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setupDismissTimer];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultString;
    if (textField.text) {
        resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    } else {
        resultString = string;
    }
    return resultString.length < [self maxCharactersCount];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self addTagButtonPressed];
    return NO;
}

- (void)textDidChange:(UITextField *)textField {
    NSString *prevString = self.inputString;
    self.inputString = textField.text;
    if ((self.inputString.length == 0 && prevString.length > 0) ||
        (self.inputString.length > 0 && prevString.length == 0)) {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemAdd]];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagsList.count inSection:SectionItemTag]]];
    [self scrollToLastItem];
    [self updateHeightConstraint];
    if ([self.delegate respondsToSelector:@selector(tagListDidChange:)]) {
        [self.delegate tagListDidChange:self];
    }
}

#pragma mark UICollectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sectionItemsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == SectionItemTag) {
        return self.tagsList.count + (self.editing ? 1 : 0);
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionItemTag) {
        TTTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
        cell.textField.inputAccessoryView = self.inputAccessoryView;
        if (indexPath.item < self.tagsList.count) {
            [cell.textField setText:[self.tagsList objectAtIndex:indexPath.item]];
            [cell.textField setUserInteractionEnabled:NO];
        }
        else if(indexPath.item == self.tagsList.count)
        {
            [cell.textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell.textField setDelegate:self];
            [cell.textField setText:self.inputString];
            [cell.textField setUserInteractionEnabled:YES];
        }
        else
        {
            [cell.textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell.textField setDelegate:self];
            [cell.textField setUserInteractionEnabled:NO];
            cell.textField.text = @"";
        }
        __weak TTTagCell *weakCell = cell;
        [cell setDeleteCellAction:^{
            NSIndexPath *changedPath = [collectionView indexPathForCell:weakCell];
            [self deleteTagAtIndexPath:changedPath];
        }];
        static BOOL scrollToEnd = YES;
        if (scrollToEnd) {
            [self scrollToLastItem];
            scrollToEnd = NO;
        }
        
        return cell;
    } else {
        TTAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addCell" forIndexPath:indexPath];
        cell.addButton.hidden = YES;
        if (self.editing) {
            if (self.inputString.length > 0) {
                cell.addButton.hidden = NO;
            }
        } else {
            if (self.tagsList.count > 0 && self.editingEnabled) {
                cell.addButton.hidden = NO;;
            }
        }
        [cell setAddCellAction:^{
            [self addTagButtonPressed];
        }];
        return cell;
    }
}

- (void)deleteTagAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(indexPath.item < self.tagsList.count) {
            NSString *tag = [self.tagsList objectAtIndex:indexPath.item];
            [self.tagsList removeObjectAtIndex:indexPath.item];
            
            if ([self.delegate respondsToSelector:@selector(tagList:didRemovedTag:atIndex:)]) {
                [self.delegate tagList:self didRemovedTag:tag atIndex:indexPath.item];
            }

            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
            if (self.tagsList.count > 0) {
                [self scrollToLastItem];
            }
            [self updateHeightConstraint];
        } else {
            [self endEditing];
        }
    });
}

- (void)addTagButtonPressed {
    if (self.inputString.length) {
        [self.tagsList addObject:self.inputString];
        
        if ([self.delegate respondsToSelector:@selector(tagList:didAddTag:)]) {
            [self.delegate tagList:self didAddTag:self.inputString];
        }
        self.inputString = nil;
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagsList.count - 1 inSection:SectionItemTag]]];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tagsList.count inSection:SectionItemTag], [NSIndexPath indexPathForItem:0 inSection:SectionItemAdd]]];
        [self scrollToLastItem];
        [self updateHeightConstraint];
    }
}

- (void)scrollToLastItem {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionItemAdd] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionItemTag) {
        if ([cell isKindOfClass:[TTTagCell class]] && indexPath.item < _tagsList.count+1) {
            TTTagCell *textCell = (TTTagCell *)cell;
            [textCell.textField becomeFirstResponder];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionItemTag) {
        NSString *stringToMeasure;
        if (indexPath.item < self.tagsList.count) {
            stringToMeasure = [self.tagsList objectAtIndex:indexPath.item];
        } else if (indexPath.item == self.tagsList.count)
        {
            stringToMeasure = self.inputString;
        }

        if (stringToMeasure && stringToMeasure.length) {
            CGSize size = CGRectIntegral([stringToMeasure boundingRectWithSize:CGSizeMake(MAXFLOAT, [self cellHeight]) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [self.cellClass font]} context:nil]).size;
            UIEdgeInsets insets = [self.cellClass insets];
            return CGSizeMake(size.width + insets.left + insets.right + 20, MAX([self cellHeight], size.height + insets.top + insets.bottom));
        } else {
            return CGSizeMake([self cellWidth], [self cellHeight]);
        }
    } else {
        return CGSizeMake([self cellWidth], [self cellHeight]);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == SectionItemTag) {
        return UIEdgeInsetsMake(0, 20, 0, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 20);
    }
}

#pragma mark Size handling

- (NSInteger)maxCharactersCount {
    return 40;
}

- (CGFloat)cellHeight {
    return 30.0f;
}

- (CGFloat)cellWidth {
    return 60.0f;
}

#pragma mark Timer handling

- (void)invalidateTimer {
    if (self.dismissTimer) {
        if ([self.dismissTimer isValid]) {
            [self.dismissTimer invalidate];
        }
    }
    self.dismissTimer = nil;
}

- (void)setupDismissTimer {
    [self invalidateTimer];
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(dismissTimerFired) userInfo:nil repeats:NO];
}

- (void)dismissTimerFired {
    [self invalidateTimer];
    [self endEditing];
}

#pragma mark Tags handling

- (void)setTags:(NSArray *)tags {
    if (tags) {
        [self.tagsList setArray:tags];
    } else {
        [self.tagsList removeAllObjects];
    }
    self.placeholderLabel.hidden = tags.count > 0;
    [self reloadData];
    [self scrollToLastItem];
}

- (NSArray *)tags
{
    if (self.inputString.length > 0) // for adding the last tag (current first responder) if not added yet
    {
        [self addTagButtonPressed];
    }
    
    return self.tagsList;
}

- (void)addTag:(NSString *)tag {
    [self.tagsList addObject:tag];
    [self reloadData];
    [self scrollToLastItem];
}

- (void)setCurrentTag:(NSString *)tag {
    [self.tagsList addObject:tag];
    self.inputString = nil;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemTag]];
}

- (void)removeTagAtIndex:(NSInteger)tagIndex {
    if (tagIndex < self.tagsList.count) {
        [self.tagsList removeObjectAtIndex:tagIndex];
        [self reloadData];
    }
}

- (void)removeAllTags {
    [self.tagsList removeAllObjects];
    [self reloadData];
}

- (void)dealloc {
    [self invalidateTimer];
}

@end
