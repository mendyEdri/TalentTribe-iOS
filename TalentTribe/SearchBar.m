//
//  SearchBar.m
//  Testing
//
//  Created by Mendy on 07/02/2016.
//  Copyright © 2016 Mendy. All rights reserved.
//

#import "SearchBar.h"
#import "JTMaterialSpinner.h"

@interface SearchBar () <UITextFieldDelegate, UISearchBarDelegate>
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIImageView *searchIcon;
@property (strong, nonatomic) JTMaterialSpinner *spinnerView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *searchCancelButton;
@property (nonatomic, strong) UIView *iconContainer;
@end

@implementation SearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 27, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    if (self) {
        self.searchBarStyle = UISearchBarStyleProminent;
        self.translucent = YES;
        self.barTintColor = [UIColor clearColor];
        [self setBackgroundImage:[[UIImage alloc] init]];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.searchBarStyle = UISearchBarStyleProminent;
        self.translucent = YES;
        self.barTintColor = [UIColor clearColor];
        [self setBackgroundImage:[[UIImage alloc] init]];
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (void)drawRect:(CGRect)rect {
    if (!self.subviews || self.subviews.count == 0) {
        return;
    }
    UIView *containerView = self.subviews[0];
    for (UIView *view in containerView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.frame = CGRectMake(5.0, 0, CGRectGetWidth(self.bounds) - 10.0, CGRectGetHeight(self.bounds));
            textField.font = [UIFont fontWithName:@"Futura" size:18.0];
            textField.textColor = [UIColor grayColor];
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.textField = textField;
            [self setTextFieldView];
        }
    }

    [super drawRect:rect];
}

- (void)setTextFieldView {
    CGFloat containerViewWidth = 30;
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.placeholder = @"Search";
    self.textField.layer.cornerRadius = 5.0;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.backgroundColor = [UIColor colorWithRed:(240.0/255.0) green:(240.0/255.0) blue:(240.0/255.0) alpha:1.0];
    self.textField.font = [UIFont fontWithName:@"Futura" size:18];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.returnKeyType = UIReturnKeyDefault;
    
    self.textField.layer.masksToBounds = NO;
    [self showCancelButton:NO];
    
    if (!self.iconContainer) {
        self.iconContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerViewWidth, CGRectGetHeight(self.textField.bounds))];
    }
    self.iconContainer.backgroundColor = self.textField.backgroundColor;
    self.iconContainer.layer.cornerRadius = 0.0;
    
    if (!self.searchIcon) {
        self.searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon"]];
        [self.iconContainer addSubview:self.searchIcon];
    }
    self.searchIcon.frame = CGRectMake(5, CGRectGetMidY(self.textField.bounds) - (20/2), 20, 20);

    if (!self.spinnerView) {
        self.spinnerView = [[JTMaterialSpinner alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.textField.bounds) - (20/2), 20, 20)];
        self.spinnerView.circleLayer.lineWidth = 2.0;
        [self.iconContainer addSubview:self.spinnerView];
    }
    self.spinnerView.circleLayer.strokeColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0].CGColor;
    
    self.textField.leftView = self.iconContainer;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self animateSearchForCancelButton:YES];
    //[self drawLine:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //[self drawLine:NO];
    [self showIndicator:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate searchBarSearchButtonClicked:self];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    //[self.delegate searchBar:self textDidChange:finalString];
    if (self.searchBarDelegate && [self.searchBarDelegate respondsToSelector:@selector(searchBarDidChangeTextWithText:)]) {
        [self.searchBarDelegate searchBarDidChangeTextWithText:finalString];
    }
    [self showIndicator:finalString.length >= 2];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self showIndicator:NO];
    if (self.searchBarDelegate && [self.searchBarDelegate respondsToSelector:@selector(searchBarDidClear)]) {
        [self.searchBarDelegate searchBarDidClear];
    }
    return YES;
}

- (void)dismissSearchKeyboard {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
    self.text = nil;
    [self animateSearchForCancelButton:NO];
    [self.textField resignFirstResponder];
}

- (void)drawLine:(BOOL)draw {
    if (!self.line) {
        self.line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.textField.frame), CGRectGetMaxY(self.textField.frame), 1, 2)];
        [self addSubview:self.line];
    }
    self.line.backgroundColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0];
    self.line.hidden = NO;
    
    [UIView animateWithDuration:draw ? 0.38 : 0.3 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:12 options:kNilOptions animations:^{
        self.line.transform = CGAffineTransformMakeScale(draw ? CGRectGetWidth(self.textField.bounds) : 1.0, 1.0);
    } completion:^(BOOL finished) {
        if (!draw) {
            self.line.hidden = YES;
        }
    }];
}

- (void)animateSearchForCancelButton:(BOOL)show {
    [UIView animateWithDuration:0.38 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:12 options:kNilOptions animations:^{
        CGSize actualSize = [self.searchCancelButton.titleLabel sizeThatFits:CGSizeMake(100, MAXFLOAT)];
        self.textField.frame = CGRectMake(CGRectGetMinX(self.textField.frame), CGRectGetMinY(self.textField.frame), show ? CGRectGetWidth([UIScreen mainScreen].bounds) - (actualSize.width + 16) : CGRectGetWidth(self.bounds) - 10.0, CGRectGetHeight(self.textField.bounds));
        [self showCancelButton:show];
    } completion:nil];
}

- (void)showCancelButton:(BOOL)show {
    if (!self.searchCancelButton) {
        self.searchCancelButton = [[UIButton alloc] init];
        [self.searchCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.searchCancelButton addTarget:self action:@selector(dismissSearchKeyboard) forControlEvents:UIControlEventTouchUpInside];
        self.searchCancelButton.titleLabel.font = [UIFont fontWithName:@"Futura" /*@"TitilliumWeb-Light"*/ size:18];
        [self.searchCancelButton setTitleColor:[UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0] forState:UIControlStateNormal];
        CGSize actualSize = [self.searchCancelButton.titleLabel sizeThatFits:CGSizeMake(100, MAXFLOAT)];
        self.searchCancelButton.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + 8, CGRectGetMidY(self.textField.frame) - actualSize.height/2, actualSize.width, actualSize.height);
        [self addSubview:self.searchCancelButton];
    }
    
    CGSize actualSize = [self.searchCancelButton.titleLabel sizeThatFits:CGSizeMake(100, MAXFLOAT)];
    [UIView animateWithDuration:0.4 animations:^{
        self.searchCancelButton.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + 8, CGRectGetMidY(self.textField.frame) - actualSize.height/2, actualSize.width, actualSize.height);
        self.searchCancelButton.alpha = show ? 1.0 : 0.0;
    } completion:nil];
}

- (void)showIndicator:(BOOL)show {
    show ? [self.spinnerView beginRefreshing] : [self.spinnerView endRefreshing];
    self.searchIcon.hidden = show;
}

@end
