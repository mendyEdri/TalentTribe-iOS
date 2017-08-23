//
//  UserProfileEducationViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/5/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileEducationViewController.h"
#import "UserProfileTextFieldTableViewCell.h"
#import "UserProfilePositionsTableViewCell.h"
#import "UserProfileSectionHeaderView.h"
#import "UserprofileAccessoryView.h"
#import "Education.h"
#import "SRMonthPicker.h"

typedef enum {
    SectionItemEducations,
    SectionItemInput,
    sectionitemsCount
} SectionItem;

typedef enum {
    EducationItemSchool,
    EducationItemStartDate,
    EducationItemEndDate,
    EducationItemDegree,
    EducationItemField,
    educationItemsCount
} EducationItem;

@interface UserProfileEducationViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SRMonthPickerDelegate>

@property (nonatomic, strong) Education *tempEducation;

@property (nonatomic, strong) UITextField *currentTextField;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, weak) IBOutlet UIView *sectionContainer;
@property (nonatomic, weak) IBOutlet UIButton *addButton;

@end

@implementation UserProfileEducationViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)addButtonPressed:(UIButton *)sender {
    if ([self validateInput]) {
        [self.tempUser.educations addObject:self.tempEducation];
        self.tempEducation = [[Education alloc] init];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionitemsCount)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateButtonsState];
    }
}

#pragma mark Input validation

- (void)validateInputAndContinue:(BOOL)back {
    if ([self validateInput]) {
        if (self.delegate) {
            if (self.currentEducation) {
                [self.delegate educationViewController:self replaceEducation:self.currentEducation withEducation:self.tempEducation];
            } else {
                [self.tempUser.educations addObject:self.tempEducation];
                [self.delegate educationViewController:self shouldUpdateEducations:self.tempUser.educations];
            }
            self.tempEducation = [[Education alloc] init];
            [self moveToPreviousScreen];
        } else {
            if (self.currentEducation) {
                User *currentUser = [[DataManager sharedManager] currentUser];
                NSInteger index = [currentUser.educations indexOfObject:self.currentEducation];
                if (index != NSNotFound) {
                    [self.tempUser.educations replaceObjectAtIndex:index withObject:self.tempEducation];
                }
            } else {
                if ([self.tempEducation isFilled]) {
                    [self.tempUser.educations addObject:self.tempEducation];
                }
            }
            if (self.positions) {
                [self.tempUser.positions setArray:self.positions];
            }
            self.tempEducation = [[Education alloc] init];
            [self updateUserProfileWithCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    if (self.currentEducation || back) {
                        [self moveToPreviousScreen];
                    } else {
                        [self moveToSkillsScreen];
                    }
                } else {
#warning CHANGE TO SOMETHING MORE VIABLE
                    if (error) {
                        [TTUtils showAlertWithText:@"Unable to update at the moment"];
                    }
                }
                
            }];
        }
    } else {
#warning CHANGE TO SOMETHING MORE VIABLE
        [self scrollToFirstEmptyField];
    }
}

- (BOOL)validateInput {
    if (self.tempUser.educations.count > 0) {
        if (![self.tempEducation isPartiallyFilled]) {
            return YES;
        }
    }
    if (self.tempEducation.educationDegree.length > 0 &&
        self.tempEducation.educationField.length > 0 &&
        self.tempEducation.educationSchool.length > 0 &&
        self.tempEducation.educationStartDate &&
        self.tempEducation.educationEndDate) {
        if (self.tempEducation.educationStartDate && self.tempEducation.educationEndDate) {
            if ([self.tempEducation.educationStartDate compare:self.tempEducation.educationEndDate] == NSOrderedDescending) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)canMoveAwayFromController {
    if (self.currentEducation) {
        if (![self.tempEducation isEqualToEducation:self.currentEducation]) {
            return NO;
        }
    }
    if (![self.tempUser isEqualToUser:[[DataManager sharedManager] currentUser]]) {
        return NO;
    }
    if (self.tempUser.educations.count > 0 && [self.tempEducation isPartiallyFilled]  && ![self.tempEducation isFilled]) {
        return NO;
    }
    if ([self.tempEducation isPartiallyFilled] && ![self.tempEducation isFilled]) {
        return NO;
    }
    return YES;
}

- (void)updateButtonsState {
    //[self.headerView.nextButton  setEnabled:[self validateInput]];
    
    if ([self validateInput]) {
        if ([self.tempEducation isFilled]) {
            self.addButton.hidden = NO;
        } else {
            self.addButton.hidden = YES;
        }
    } else {
        self.addButton.hidden = YES;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemEducations] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Navigation

- (void)moveToSkillsScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileSkillsViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UIActionSheet delegate

#pragma mark Data reloading

- (void)reloadData {
    
    if (self.currentEducation) {
        [self.headerView.nextButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
    
    [self updateButtonsState];
}

#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionitemsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemEducations: {
            return self.tempUser.educations.count;
        } break;
        case SectionItemInput: {
            return educationItemsCount;
        }  break;
        default: {
            return 0;
        } break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemEducations: {
            return 80.0f;
        } break;
        default:{
        } break;
    }
    return 50.0f;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.currentEducation) {
        return section == SectionItemEducations ? 0.0f : 50.0f;
    } else {
        if (self.tempUser.educations.count > 0) {
            return section == SectionItemEducations ? 50.0f : 0.0f;
        } else {
            return section == SectionItemEducations ? 0.0f : 50.0f;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *(^createHeaderView)(void) = ^UIView*{
        UserProfileSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderView"];
        if (self.currentEducation) {
            headerView.addButton.hidden = YES;
        } else {
            if ([self validateInput]) {
                if ([self.tempEducation isFilled]) {
                    headerView.addButton.hidden = NO;
                } else {
                    headerView.addButton.hidden = YES;
                }
            } else {
                headerView.addButton.hidden = YES;
            }
        }
        [headerView.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        headerView.titleLabel.text = @"Education";
        headerView.imageView.image = [UIImage imageNamed:@"user_education"];
        return headerView;
    };
    if (self.currentEducation) {
        return section == SectionItemEducations ? nil : createHeaderView();
    } else {
        if (self.tempUser.educations.count > 0) {
            return section == SectionItemEducations ? createHeaderView() : nil;
        } else {
            return section == SectionItemEducations ? nil : createHeaderView();
        }
    }
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemEducations: {
            UserProfilePositionsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"educationCell"];
            
            Education *education = [self.tempUser.educations objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = education.educationSchool;
            cell.dateLabel.text = [NSString stringWithFormat:@"%@   %@ - %@", education.educationDegree, [self.dateFormatter stringFromDate:education.educationStartDate],  [self.dateFormatter stringFromDate:education.educationEndDate] ?: @"Present"];
            cell.summaryLabel.text = education.educationField;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } break;
        case SectionItemInput: {
            UserProfileTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfieldCell"];
            cell.textField.userInteractionEnabled = YES;
            cell.textField.delegate = self;
            cell.textField.inputView = nil;
            cell.textField.inputAccessoryView = [UserProfileAccessoryView accessoryViewWithDelegate:self];
            cell.checkMark.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            NSString *placeholderString;
            NSString *contentString;
            
            switch (indexPath.row) {
                case EducationItemSchool: {
                    placeholderString = @"School or College";
                    contentString = self.tempEducation.educationSchool;
                } break;
                case EducationItemStartDate: {
                    placeholderString = @"Start year";
                    contentString = self.tempEducation.educationStartDate ? [self.dateFormatter stringFromDate:self.tempEducation.educationStartDate]: nil;
                    cell.textField.inputView = [self datePickerInput];
                } break;
                case EducationItemEndDate: {
                    placeholderString = @"End year";
                    contentString = self.tempEducation.educationEndDate ? [self.dateFormatter stringFromDate:self.tempEducation.educationEndDate]: nil;
                    cell.textField.inputView = [self datePickerInput];
                } break;
                case EducationItemDegree: {
                    placeholderString = @"Degree";
                    contentString = self.tempEducation.educationDegree;
                } break;
                case EducationItemField: {
                    placeholderString = @"Field of study";
                    contentString = self.tempEducation.educationField;
                } break;
                default: break;
            }
            
            [cell setAttributedPlaceholder:placeholderString];
            [cell.textField setText:contentString];
            return cell;
        } break;
        default: {
            return nil;
        } break;
    }
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionItemEducations) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Education *itemToRemove = [self.tempUser.educations objectAtIndex:indexPath.row];
        [self.tempUser.educations removeObjectAtIndex:indexPath.row];
        [self.tempUser.removedEducations addObject:itemToRemove];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark Scrolling to next

- (void)scrollToNextField {
    NSIndexPath *indexPath = [self indexPathForFirstResponder];
    NSIndexPath *nextIndexPath;
    if (indexPath) {
        switch (indexPath.section) {
            case SectionItemInput: {
                if (indexPath.row < educationItemsCount - 1) {
                    nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:SectionItemInput];
                } else {
                    [self.view endEditing:YES];
                    [self validateInputAndContinue:NO];
                }
            } break;
            default:
                break;
        }
    } else {
        nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:SectionItemInput];
    }
    [self scrollToIndexPath:nextIndexPath highlight:NO];
}

- (void)scrollToFirstEmptyField {
    NSIndexPath *indexPath;
    if (self.tempEducation.educationSchool.length <= 0) {
        indexPath = [NSIndexPath indexPathForRow:EducationItemSchool inSection:SectionItemInput];
    } else if (!self.tempEducation.educationStartDate) {
        indexPath = [NSIndexPath indexPathForRow:EducationItemStartDate inSection:SectionItemInput];
    } else if (!self.tempEducation.educationEndDate  || (self.tempEducation.educationEndDate && [self.tempEducation.educationStartDate compare:self.tempEducation.educationEndDate] == NSOrderedDescending)) {
        indexPath = [NSIndexPath indexPathForRow:EducationItemEndDate inSection:SectionItemInput];
        if (self.tempEducation.educationEndDate) {
            [TTUtils showAlertWithText:@"Education end date can`t be earlier that start date"];
        }
    } else if (self.tempEducation.educationDegree.length <= 0) {
        indexPath = [NSIndexPath indexPathForRow:EducationItemDegree inSection:SectionItemInput];
    } else if (self.tempEducation.educationField.length <= 0) {
        indexPath = [NSIndexPath indexPathForRow:EducationItemField inSection:SectionItemInput];
    }
    if (indexPath) {
        [self scrollToIndexPath:indexPath highlight:YES];
    }
}

#pragma mark Month picker delegate

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker {
    [self.currentTextField setText:[self.dateFormatter stringFromDate:monthPicker.date]];
    [self textFieldDidChange:self.currentTextField];
}

#pragma mark Misc

- (UIPickerView *)datePickerInput {
    SRMonthPicker *picker = [[SRMonthPicker alloc] init];
    [picker setMinimumYear:1900];
    [picker setMaximumYear:[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]].year];
    [picker setMonthPickerDelegate:self];
    return picker;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy"];
    }
    return _dateFormatter;
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self tableViewCellFromSubview:textField]];
    if (indexPath) {
        switch (indexPath.row) {
            case EducationItemStartDate:
            case EducationItemEndDate: {
                UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                textField.text = [self.dateFormatter stringFromDate:datePicker.date];
            } break;
            default: {
                
            } break;
        }
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self tableViewCellFromSubview:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        if ([cell isKindOfClass:[UserProfileTextFieldTableViewCell class]]) {
            UserProfileTextFieldTableViewCell *textFieldCell = (UserProfileTextFieldTableViewCell *)cell;
            textFieldCell.highlightView.hidden = YES;
        }
        switch (indexPath.row) {
            case EducationItemStartDate: {
                UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                self.tempEducation.educationStartDate = datePicker.date;
            } break;
            case EducationItemEndDate: {
                UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                self.tempEducation.educationEndDate = datePicker.date;
            } break;
            case EducationItemDegree: {
                self.tempEducation.educationDegree = textField.text;
            } break;
            case EducationItemField: {
                self.tempEducation.educationField = textField.text;
            } break;
            case EducationItemSchool: {
                self.tempEducation.educationSchool = textField.text;
            } break;
            default: {
                
            } break;
        }
    }
    [self updateButtonsState];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
    [self textFieldDidChange:textField];
}

#pragma mark - Keyboard Notifications

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
    if (self.currentEducation) {
        self.tempEducation = [self.currentEducation copy];
    } else {
        self.tempEducation = [[Education alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
