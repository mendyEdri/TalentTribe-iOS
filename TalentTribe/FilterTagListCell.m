//
//  FilterTagListCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "FilterTagListCell.h"

@interface FilterTagListCell ()

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation FilterTagListCell

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
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[FilterTagListCell defaultBackgroudImageForState:UIControlStateNormal]];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor clearColor];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.font = [FilterTagListCell font];
    textField.textColor = UIColorFromRGB(0x1dafed);
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    
    self.textField = textField;
    
    [self.contentView addSubview:textField];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [deleteButton setImage:[UIImage imageNamed:@"close_tag"] forState:UIControlStateNormal];
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.translatesAutoresizingMaskIntoConstraints = YES;
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:10];
    deleteButton.userInteractionEnabled = NO;
    deleteButton.hidden = NO;
    
    self.deleteButton = deleteButton;
    
    [self.contentView addSubview:deleteButton];
    
    UIEdgeInsets insets = [FilterTagListCell insets];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[textField]-(%f)-|", insets.top, insets.bottom] options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%f)-[textField]-(%f)-|", insets.left, insets.right] options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonSize = self.contentView.frame.size.height;
    self.deleteButton.frame = CGRectMake(0, 0, buttonSize, buttonSize);
}

+ (UIEdgeInsets)insets {
    static UIEdgeInsets insets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        insets = UIEdgeInsetsMake(0, 30, 0, 5);
    });
    return insets;
}

@end
