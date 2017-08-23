//
//  UserProfileKeyboardObservingViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileKeyboardObservingViewController.h"
#import "UserProfileTextFieldTableViewCell.h"
#import "UserProfileTextViewTableViewCell.h"
#import "UserProfileSkillsTableViewCell.h"
#import "RDVTabBarController.h"
#import "UserProfileAccessoryView.h"

@interface UserProfileKeyboardObservingViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) NSLayoutConstraint *bottomTableViewConstraint;
@property CGFloat bottomSpaceInitialValue;

@end

@implementation UserProfileKeyboardObservingViewController

#pragma mark Gesture recognizer handling

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setCancelsTouchesInView:NO];
    [gestureRecognizer setDelegate:self];
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return [self viewIsSubviewOfCell:touch.view];
    } else {
        return YES;
    }
}

- (BOOL)viewIsSubviewOfCell:(UIView *)view {
    if ([view isKindOfClass:[UITableViewCell class]]) {
        return NO;
    } else {
        if (view.superview) {
            return [self viewIsSubviewOfCell:view.superview];
        } else {
            return YES;
        }
    }
}

- (void)hideKeyboard {
    [self.tableView endEditing:YES];
}

#pragma mark UITableViewCell from subview

- (UITableViewCell *)tableViewCellFromSubview:(UIView *)view {
    if ([view isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)view;
    } else {
        if (view.superview) {
            return [self tableViewCellFromSubview:view.superview];
        }
    }
    return nil;
}

#pragma mark Keyboard handling

- (void)setupKeyboardObservations {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [self.view layoutIfNeeded];
    self.bottomTableViewConstraint.constant = keyboardSize.height - [UserProfileAccessoryView height] - CGRectGetHeight(self.rdv_tabBarController.tabBar.frame);
    [UIView animateWithDuration:rate.floatValue animations:^{
        [self.view layoutIfNeeded];
        NSIndexPath *indexPath = [self indexPathForFirstResponder];
        if (indexPath) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }];
    self.keyboardVisible = YES;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[self indexPathForFirstResponder] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [self.view layoutIfNeeded];
    self.bottomTableViewConstraint.constant = self.bottomSpaceInitialValue;
    [UIView animateWithDuration:rate.floatValue animations:^{
        [self.view layoutIfNeeded];
    }];
    self.keyboardVisible = NO;
}

- (NSLayoutConstraint *)bottomTableViewConstraint {
    if (!_bottomTableViewConstraint) {
        for (NSLayoutConstraint *constraint in self.view.constraints) {
            if (constraint.relation == NSLayoutRelationEqual) {
                if ((constraint.firstItem == self.tableView  && constraint.firstAttribute == NSLayoutAttributeBottom && constraint.secondAttribute == NSLayoutAttributeTop) || (constraint.secondItem == self.tableView && constraint.firstAttribute == NSLayoutAttributeTop && constraint.secondAttribute == NSLayoutAttributeBottom)) {
                    _bottomTableViewConstraint = constraint;
                    self.bottomSpaceInitialValue = constraint.constant;
                    break;
                }
            }
        }
    }
    return _bottomTableViewConstraint;
}

- (NSIndexPath *)indexPathForFirstResponder {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([self firstResponderInSubviewOfView:cell.contentView]) {
            return [self.tableView indexPathForCell:cell];
        }
    }
    return nil;
}

- (BOOL)firstResponderInSubviewOfView:(UIView *)view {
    NSArray *subviews;
    if ([view isKindOfClass:[UICollectionView class]] || [view isKindOfClass:[UITableView class]]) {
        subviews = [(UITableView *)view visibleCells];
    } else {
        subviews = view.subviews;
    }
    for (UIView *subview in subviews) {
        if (subview.isFirstResponder) {
            return YES;
        } else {
            if (subview.subviews.count) {
                return [self firstResponderInSubviewOfView:subview];
            }
        }
    }
    return NO;
}

- (void)scrollToIndexPath:(NSIndexPath *)nextIndexPath highlight:(BOOL)highlight {
    if (nextIndexPath) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } completion:^(BOOL finished) {
            NSArray *cells = [self.tableView visibleCells];
            for (UITableViewCell *cell in cells) {
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                if (cellIndexPath) {
                    if ([cellIndexPath isEqual:nextIndexPath]) {
                        if ([cell isKindOfClass:[UserProfileTextFieldTableViewCell class]]) {
                            UserProfileTextFieldTableViewCell *textFieldCell = (UserProfileTextFieldTableViewCell *)cell;
                            [textFieldCell.textField becomeFirstResponder];
                            textFieldCell.highlightView.hidden = !highlight;
                        } else if ([cell isKindOfClass:[UserProfileTextViewTableViewCell class]]) {
                            UserProfileTextViewTableViewCell *textViewCell = (UserProfileTextViewTableViewCell *)cell;
                            [textViewCell.textView becomeFirstResponder];
                        } else if ([cell isKindOfClass:[UserProfileSkillsTableViewCell class]]) {
                            UserProfileSkillsTableViewCell *tagCell = (UserProfileSkillsTableViewCell *)cell;
                            [tagCell.tagList beginEditing];
                        }
                        break;
                    }
                }
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestureRecognizer];
    [self setupKeyboardObservations];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
