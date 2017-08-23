//
//  UserProfileContactViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileContactViewController.h"
#import "UserProfileTextFieldTableViewCell.h"
#import "UserProfileSectionHeaderView.h"
#import "UserProfileAccessoryView.h"

typedef enum {
    ContactItemEmail,
    ContactItemPhone,
    contactItemsCount
} ContactItem;

@interface UserProfileContactViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;

@end

@implementation UserProfileContactViewController


#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonPressed:(id)sender {
    [self.view endEditing:YES];
    [self validateInputAndContinue:NO];
}

- (IBAction)moreButtonPressed:(id)sender {
    [self.view endEditing:YES];
    [self validateInputAndContinue:YES];
}

- (void)moveToProfileScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveToMainScreen {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Input validation

- (void)validateInputAndContinue:(BOOL)moveToProfile {
    if ([self validateInput]) {
        [self updateUserProfileWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success && !error) {
                if (moveToProfile) {
                    [self moveToProfileScreen];
                } else {
                    [self moveToMainScreen];
                }
            } else {
#warning CHANGE TO SOMETHING MORE VIABLE
                if (error) {
                    [TTUtils showAlertWithText:@"Unable to update at the moment"];
                }
            }
            
        }];
    } else {
#warning CHANGE TO SOMETHING MORE VIABLE
        [self scrollToFirstEmptyField];
    }
}

- (BOOL)validateInput {
    if ([TTUtils validateEmail:self.tempUser.userContactEmail] /*&&
        [TTUtils validatePhone:self.tempUser.userPhone]*/) {
        return YES;
    }
    return NO;
}

- (BOOL)canMoveAwayFromController {
    if (![self.tempUser isEqualToUser:[[DataManager sharedManager] currentUser]]) {
        return NO;
    }
    return YES;
}

- (void)updateButtonsState {
    //[self.nextButton setEnabled:[self validateInput]];
    [self.moreButton setEnabled:[self validateInput]];
}

#pragma mark UIActionSheet delegate

#pragma mark Data reloading

- (void)reloadData {
    if (!self.tempUser.userContactEmail) {
        self.tempUser.userContactEmail = self.tempUser.userEmail;
    }
    [self.tableView reloadData];
    [self updateButtonsState];
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contactItemsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UserProfileSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderView"];
    headerView.addButton.hidden = YES;
    headerView.titleLabel.text = @"Contact Info";
    headerView.imageView.image = [UIImage imageNamed:@"user_contact"];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    cell.textField.userInteractionEnabled = YES;
    cell.textField.delegate = self;
    cell.textField.inputAccessoryView = [UserProfileAccessoryView accessoryViewWithDelegate:self];
    cell.checkMark.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSString *placeholderString;
    
    switch (indexPath.row) {
        case ContactItemEmail: {
            placeholderString = @"Email";
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.textField.text = self.tempUser.userContactEmail.length > 0 ? self.tempUser.userContactEmail : self.tempUser.userEmail;
        } break;
        case ContactItemPhone: {
            placeholderString = @"Phone number";
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textField.text = self.tempUser.userPhone;
        } break;
        default: break;
    }
    
    [cell setAttributedPlaceholder:placeholderString];
    
    return cell;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self tableViewCellFromSubview:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        if ([cell isKindOfClass:[UserProfileTextFieldTableViewCell class]]) {
            UserProfileTextFieldTableViewCell *textFieldCell = (UserProfileTextFieldTableViewCell *)cell;
            textFieldCell.highlightView.hidden = YES;
        }
        switch (indexPath.row) {
            case ContactItemEmail: {
                self.tempUser.userContactEmail = textField.text;
            } break;
            case ContactItemPhone: {
                self.tempUser.userPhone = textField.text;
            } break;
            default: {
                
            } break;
        }
    }
    [self updateButtonsState];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self textFieldDidChange:textField];
}

#pragma mark Scrolling to next

- (void)scrollToNextField {
    NSIndexPath *indexPath = [self indexPathForFirstResponder];
    NSIndexPath *nextIndexPath;
    if (indexPath) {
        if (indexPath.row < contactItemsCount - 1) {
            nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        } else {
            [self.view endEditing:YES];
            [self validateInputAndContinue:NO];
        }
    } else {
        nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self scrollToIndexPath:nextIndexPath highlight:NO];
}

- (void)scrollToFirstEmptyField {
    NSIndexPath *indexPath;
    if (![TTUtils validateEmail:self.tempUser.userContactEmail]) {
        indexPath = [NSIndexPath indexPathForRow:ContactItemEmail inSection:0];
    } else if (![TTUtils validatePhone:self.tempUser.userPhone]) {
        indexPath = [NSIndexPath indexPathForRow:ContactItemPhone inSection:0];
    }
    if (indexPath) {
        [self scrollToIndexPath:indexPath highlight:YES];
    }
}

#pragma mark UserProfileAccessoryView delegate

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
}

- (void)dealloc {
    
}

@end
