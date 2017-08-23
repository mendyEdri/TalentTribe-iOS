//
//  UserProfileSummaryViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileSummaryViewController.h"
#import "TTGradientHandler.h"
#import "UIViewController+RootNavigationController.h"
#import "RootNavigationController.h"
#import "UIViewController+Modal.h"

#import "User.h"
#import "UserProfileTextViewTableViewCell.h"
#import "UserProfileSectionHeaderView.h"
#import "UserProfileAccessoryView.h"
#import "UserProfileHeaderView.h"

#define kMinCellHeight 50.0f

typedef enum {
    SummaryItemSummary,
    summaryItemsCount
} SummaryItem;

@interface UserProfileSummaryViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@end

@implementation UserProfileSummaryViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        
    }
    return self;
}

- (void)moveToMainScreen {
    if (self.isModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.rootNavigationController moveToTabBar:false];
    }
}

- (void)moveToPositionsScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfilePositionsViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.tableView];
    CGPoint contentOffset = self.tableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    
    NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
    [self.tableView setContentOffset:contentOffset animated:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]]) {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}

#pragma mark Input validation

- (void)validateInputAndContinue:(BOOL)back {
    if ([self validateInput]) {
        [self updateUserProfileWithCompletionHandler:^(BOOL success, NSError *error){
            if (success && !error) {
                if (back) {
                    [self moveToPreviousScreen];
                } else {
                    [self moveToPositionsScreen];
                }
            } else {
                if (error) {
                    [TTUtils showAlertWithText:@"Unable to complete the request at the moment"];
                }
            }
        }];
    } else {
#warning CHANGE TO SOMETHING MORE VIABLE
        [self scrollToFirstEmptyField];
    }
}

- (void)updateUserProfileWithCompletionHandler:(SimpleCompletionBlock)completion {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] updateUser:self.tempUser completionHandler:^(BOOL success, NSError *error) {
                void (^innerCompletion)(BOOL success, NSError *error) = ^(BOOL success, NSError *error){
                    [TTActivityIndicator dismiss];
                    loading = NO;
                    if (completion) {
                        completion(success, error);
                    }
                };
                if (success && !error) {
                    [[DataManager sharedManager] performUploadCVRequestWithCompletionHandler:^(BOOL success, NSError *error) {
                        innerCompletion(success, error);
                    }];
                } else {
                    innerCompletion(success, error);
                }
            }];
        }
    }
}

- (BOOL)validateInput {
    if (self.tempUser.userFirstName.length > 0 && self.tempUser.userLastName.length > 0) {
        if (self.tempUser.userProfileSummary.length > 0) {
            if (self.tempUser.userProfileSummary.length > kSummaryCharacterLimit) {
                return NO;
            }
        } else if (!self.tempUser.userProfileSummary || self.tempUser.userProfileSummary.length == 0) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (void)scrollToFirstEmptyField {
    if (self.tempUser.userFirstName.length <= 0) {
        [self.headerView.inputFirstNameField becomeFirstResponder];
        self.headerView.inputFirstNameUnderline.backgroundColor = [UIColor redColor];
    } else if (self.tempUser.userLastName.length <= 0) {
        [self.headerView.inputLastNameField becomeFirstResponder];
        self.headerView.inputLastNameUnderline.backgroundColor = [UIColor redColor];
    } else if (self.tempUser.userProfileSummary.length > 0) {
        if (self.tempUser.userProfileSummary.length > kSummaryCharacterLimit) {
            [self scrollToIndexPath:[NSIndexPath indexPathForRow:SummaryItemSummary inSection:0]];
        }
    } else if (self.tempUser.userProfileSummary.length <= 0) {
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:SummaryItemSummary inSection:0]];
    }
}

- (void)scrollToNextField {
    NSIndexPath *indexPath = [self indexPathForFirstResponder];
    if (indexPath) {
        switch (indexPath.row) {
            case SummaryItemSummary: {
                [self.view endEditing:YES];
                [self validateInputAndContinue:NO];
            } break;
            default:
                break;
        }
    } else {
        if ([self.headerView.inputFirstNameField isFirstResponder]) {
            [self.headerView.inputLastNameField becomeFirstResponder];
        } else if ([self.headerView.inputLastNameField isFirstResponder]) {
            [self scrollToIndexPath:[NSIndexPath indexPathForRow:SummaryItemSummary inSection:0]];
        } else {
            [self.headerView.inputFirstNameField becomeFirstResponder];
        }
    }
}

- (void)scrollToIndexPath:(NSIndexPath *)nextIndexPath {
    if (nextIndexPath) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } completion:^(BOOL finished) {
            NSArray *cells = [self.tableView visibleCells];
            for (UITableViewCell *cell in cells) {
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                if (cellIndexPath) {
                    if ([cellIndexPath isEqual:nextIndexPath]) {
                        if ([cell isKindOfClass:[UserProfileTextViewTableViewCell class]]) {
                            UserProfileTextViewTableViewCell *textViewCell = (UserProfileTextViewTableViewCell *)cell;
                            [textViewCell.textView becomeFirstResponder];
                        }
                        break;
                    }
                }
            }
        }];
    }
}

- (void)updateButtonsState {
    [self.nextButton  setEnabled:[self validateInput]];
}

#pragma mark Data reloading

- (void)reloadData {
    [self.tableView reloadData];
    [self updateButtonsState];
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return summaryItemsCount;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMinCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self textViewOnCell].text.length > 0 ? UITableViewAutomaticDimension : 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UserProfileSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderView"];
    headerView.addButton.hidden = YES;
    headerView.titleLabel.text = @"Summary";
    headerView.imageView.image = [UIImage imageNamed:@"user_summary"];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"summaryTextViewCell"];
    cell.textView.userInteractionEnabled = YES;
    cell.textView.delegate = self;
    cell.textView.text = self.tempUser.userProfileSummary;
    cell.textView.inputAccessoryView = [UserProfileAccessoryView accessoryViewWithDelegate:self];
    //cell.checkMark.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *placeholderString;
    
    switch (indexPath.row) {
        case SummaryItemSummary: {
            placeholderString = @"Does your profile have a summary line? Put it here!";
        } break;
        default: break;
    }
    
    [cell setAttributedPlaceholder:placeholderString];
    
    return cell;
}

- (void)keyboardWillShow:(NSNotification *)sender {
    CGFloat height = [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|curveOption animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, height, 0);
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;

    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|curveOption animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    } completion:nil];
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TextViewDelegate

- (void)updateTextViewHeight {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[UserProfileTextViewTableViewCell class]]) {
            UserProfileTextViewTableViewCell *profileCell = (UserProfileTextViewTableViewCell *)cell;
            if (profileCell.textView.isFirstResponder) {
                CGSize size = profileCell.textView.bounds.size;
                CGSize newSize = [profileCell.textView sizeThatFits:CGSizeMake(size.width, MAXFLOAT)];
                if (size.height != newSize.height) {
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:profileCell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                break;
            }
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self updateButtonsState];
    if (finalString.length == 0) {
     //   [self reloadData];
    }
    if (finalString.length < kSummaryCharacterLimit) {
        return YES;
    } else {
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateButtonsState];
    [self updateTextViewHeight];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self tableViewCellFromSubview:textView]];
    if (indexPath) {
        self.tempUser.userProfileSummary = textView.text;
    }
    [self updateButtonsState];
}

- (UITextView *)textViewOnCell {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[UserProfileTextViewTableViewCell class]]) {
            UserProfileTextViewTableViewCell *textFieldCell = (UserProfileTextViewTableViewCell *)cell;
            return textFieldCell.textView;
        }
    }
    return nil;
}

#pragma mark View lifeCycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToNextField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
