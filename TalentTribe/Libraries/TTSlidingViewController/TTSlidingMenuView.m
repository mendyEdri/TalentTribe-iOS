//
//  CompanyProfileMenuView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/10/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTSlidingMenuView.h"

@implementation TTSlidingMenuView

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        [self setUserInteractionEnabled:NO];
        [self setSelected:YES];
        [self setupTitleLabel];
        [self setTitle:title];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _titleLabel;
}

- (void)setupTitleLabel {
    UIView *child = self.titleLabel;
    [self addSubview:child];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
    [self setFrame:CGRectIntegral([title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0f) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil])];
}

- (void)setSelected:(BOOL)selected {
    [self.titleLabel setTextColor:selected ? [UIColor whiteColor] : UIColorFromRGB(0xb9e0f7)];
    [self.titleLabel setFont: [UIFont fontWithName:selected ? @"TitilliumWeb-SemiBold" : @"TitilliumWeb-Light" size:15.0f]];
}

@end
