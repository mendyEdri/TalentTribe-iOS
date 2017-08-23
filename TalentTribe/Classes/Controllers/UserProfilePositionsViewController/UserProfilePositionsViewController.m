//
//  UserProfilePositionsViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfilePositionsViewController.h"
#import "UserProfileTextFieldTableViewCell.h"
#import "UserProfilePositionsTableViewCell.h"
#import "UserProfileEducationViewController.h"
#import "UserProfileSectionHeaderView.h"
#import "UserProfileAccessoryView.h"
#import "User.h"
#import "Company.h"
#import "SRMonthPicker.h"

typedef enum {
    SectionItemPositions,
    SectionItemInput,
    sectionitemsCount
} SectionItem;

typedef enum {
    PositionItemCompany,
    PositionItemPosition,
    PositionItemDescription,
    PositionItemStart,
    PositionItemEnd,
    PositionItemCurrent,
    PositionItemStudent,
    positionItemsCount
} PositionItem;

@interface UserProfilePositionsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SRMonthPickerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) Position *tempPosition;

@property (nonatomic, strong) UITextField *currentTextField;

@property (nonatomic, weak) IBOutlet UIView *sectionContainer;
@property (nonatomic, weak) IBOutlet UIButton *addButton;

@end

@implementation UserProfilePositionsViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    }
    return self;
}

- (IBAction)addButtonPressed:(UIButton *)sender {
    if ([self validateInput]) {
        [self.tempUser.positions addObject:self.tempPosition];
        self.tempPosition = [[Position alloc] init];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionitemsCount)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateButtonsState];
    }
}

#pragma mark Input validation

- (void)validateInputAndContinue:(BOOL)back {
    if ([self validateInput]) {
        if (self.delegate) {
            if (self.currentPosition) {
                [self.delegate positionsViewController:self replacePosition:self.currentPosition withPosition:self.tempPosition];
            } else {
                [self.tempUser.positions addObject:self.tempPosition];
                [self.delegate positionsViewController:self shouldUpdatePositions:self.tempUser.positions];
            }
            self.tempPosition = [Position new];
            [self moveToPreviousScreen];
        } else {
            if (self.currentPosition) {
                User *currentUser = [[DataManager sharedManager] currentUser];
                NSInteger index = [currentUser.positions indexOfObject:self.currentPosition];
                if (index != NSNotFound) {
                    [self.tempUser.positions replaceObjectAtIndex:index withObject:self.tempPosition];
                }
            } else {
                if ([self.tempPosition isFilled]) {
                    [self.tempUser.positions addObject:self.tempPosition];
                }
            }
            self.tempPosition = [Position new];
            [self updateUserProfileWithCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    if (self.currentPosition || back) {
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
    if (self.tempUser.positions.count > 0) {
        if (![self.tempPosition isPartiallyFilled]) {
            return YES;
        }
    }
    if (self.tempPosition.positionCompany &&
        /*self.tempPosition.positionSummary.length > 0 &&*/
        self.tempPosition.positionTitle.length > 0 &&
        self.tempPosition.positionStartDate &&
        (self.tempPosition.positionEndDate || self.tempPosition.currentPosition)) {
        if (self.tempPosition.positionStartDate && self.tempPosition.positionEndDate) {
            if ([self.tempPosition.positionStartDate compare:self.tempPosition.positionEndDate] == NSOrderedDescending) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)canMoveAwayFromController {
    if (self.currentPosition) {
        if (![self.tempPosition isEqualToPosition:self.currentPosition]) {
            return NO;
        }
    }
    if (![self.tempUser isEqualToUser:[[DataManager sharedManager] currentUser]]) {
        return NO;
    }
    if (self.tempUser.positions.count > 0 && [self.tempPosition isPartiallyFilled] && ![self.tempPosition isFilled]) {
        return NO;
    }
    if ([self.tempPosition isPartiallyFilled] && ![self.tempPosition isFilled]) {
        return NO;
    }
    return YES;
}

- (void)updateButtonsState {
    if (self.currentPosition) {
        [self.headerView.nextButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    //[self.headerView.nextButton  setEnabled:[self validateInput]];
    
    if (self.currentPosition) {
        self.addButton.hidden = YES;
    } else {
        if ([self validateInput]) {
            if ([self.tempPosition isFilled]) {
                self.addButton.hidden = NO;
            } else {
                self.addButton.hidden = YES;
            }
        } else {
            self.addButton.hidden = YES;
        }
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemPositions] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark UIActionSheet delegate

#pragma mark Data reloading

- (void)reloadData {
    
    if (self.currentPosition) {
        self.tempPosition = [self.currentPosition copy];
    } else {
        self.tempPosition = [[Position alloc] init];
    }
    
    if (self.currentPosition) {
        [self.headerView.nextButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero];
    [self updateButtonsState];
}

- (void)moveToEducationScreen {
    self.reloadUser = NO;
    UserProfileEducationViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileEducationViewController"];
    if ([self validateInput] && self.tempPosition) {
        [self.tempUser.positions addObject:self.tempPosition];
        self.tempPosition = [Position new];
    }
    [controller setPositions:self.tempUser.positions];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveToSkillsScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileSkillsViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveToContactScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileContactViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionitemsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemPositions: {
            if (self.currentPosition) {
                return 0;
            } else {
                return self.tempUser.positions.count;
            }
        } break;
        case SectionItemInput: {
            return positionItemsCount;
        }  break;
        default: {
            return 0;
        } break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemPositions: {
            return 80.0f;
        } break;
        case SectionItemInput: {
            if ((indexPath.row == PositionItemEnd && self.tempPosition.currentPosition) ||
                (indexPath.row == PositionItemStudent && (self.currentPosition || self.delegate))) {
                return 0.0f;
            }
        } break;
        default:{
        } break;
    }
    return 50.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemPositions: {
            UserProfilePositionsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"positionsCell"];
            
            Position *position = [self.tempUser.positions objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = position.positionTitle;
            cell.dateLabel.text = [NSString stringWithFormat:@"%@   %@ - %@", position.positionCompany.companyName, [self.dateFormatter stringFromDate:position.positionStartDate], position.positionEndDate ? [self.dateFormatter stringFromDate:position.positionEndDate] : @"Present"];
            cell.summaryLabel.text = position.positionSummary;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } break;
        case SectionItemInput: {
            UserProfileTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfieldCell"];
            cell.textField.userInteractionEnabled = YES;
            cell.textField.delegate = self;
            cell.checkMark.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.inputView = nil;
            cell.textField.inputAccessoryView = [UserProfileAccessoryView accessoryViewWithDelegate:self];
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            NSString *placeholderString;
            NSString *contentString;
            NSDictionary *attributes;
            
            switch (indexPath.row) {
                case PositionItemCompany: {
                    placeholderString = @"Company";
                    contentString = self.tempPosition.positionCompany.companyName;
                } break;
                case PositionItemPosition: {
                    placeholderString = @"Position";
                    contentString = self.tempPosition.positionTitle;
                } break;
                case PositionItemDescription: {
                    placeholderString = @"Description";
                    contentString = self.tempPosition.positionSummary;
                } break;
                case PositionItemStart: {
                    placeholderString = @"Start";
                    contentString = self.tempPosition.positionStartDate ? [[self dateFormatter] stringFromDate:self.tempPosition.positionStartDate] : nil;
                    cell.textField.inputView = [self datePickerInput];
                } break;
                case PositionItemEnd: {
                    placeholderString = @"End";
                    contentString = self.tempPosition.positionEndDate ? [[self dateFormatter] stringFromDate:self.tempPosition.positionEndDate] : nil;
                    cell.textField.userInteractionEnabled = !self.tempPosition.currentPosition;
                    cell.textField.inputView = [self datePickerInput];
                } break;
                case PositionItemCurrent: {
                    cell.checkMark.hidden = !self.tempPosition.currentPosition;
                    cell.textField.userInteractionEnabled = NO;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    placeholderString = @"Current job";
                } break;
                case PositionItemStudent: {
                     placeholderString = @"I`m a student";
                     cell.textField.userInteractionEnabled = NO;
                     attributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x13b9fc), NSFontAttributeName : TITILLIUMWEB_SEMIBOLD(20.0f)};
                     cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                } break;
                default:
                    break;
            }
            
            [cell setAttributedPlaceholder:placeholderString attributes:attributes];
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
    switch (indexPath.section) {
        case SectionItemPositions: {
        } break;
        case SectionItemInput: {
            switch (indexPath.row) {
                case PositionItemCurrent: {
                    self.tempPosition.currentPosition = !self.tempPosition.currentPosition;
                    [tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemInput] withRowAnimation:UITableViewRowAnimationAutomatic];
                } break;
                case PositionItemStudent: {
                    if (!self.currentPosition) {
                        [self.view endEditing:YES];
                        [self moveToEducationScreen];
                    }
                } break;
                default: break;
            }

        }  break;
        default: {
        } break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionItemPositions) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Position *itemToRemove = [self.tempUser.positions objectAtIndex:indexPath.row];
        [self.tempUser.positions removeObjectAtIndex:indexPath.row];
        [self.tempUser.removedPositions addObject:itemToRemove];
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
                if (indexPath.row < positionItemsCount - 3) {
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
    if (self.tempPosition.positionCompany.companyName.length <= 0) {
        indexPath = [NSIndexPath indexPathForRow:PositionItemCompany inSection:SectionItemInput];
    } else if (self.tempPosition.positionTitle.length <= 0) {
        indexPath = [NSIndexPath indexPathForRow:PositionItemPosition inSection:SectionItemInput];
    } /*else if (self.tempPosition.positionSummary.length <= 0) {
        indexPath = [NSIndexPath indexPathForRow:PositionItemDescription inSection:SectionItemInput];
    } */else if (!self.tempPosition.positionStartDate) {
        indexPath = [NSIndexPath indexPathForRow:PositionItemStart inSection:SectionItemInput];
    } else if ((!self.tempPosition.positionEndDate && !self.tempPosition.currentPosition) || (self.tempPosition.positionEndDate && [self.tempPosition.positionStartDate compare:self.tempPosition.positionEndDate] == NSOrderedDescending)) {
        indexPath = [NSIndexPath indexPathForRow:PositionItemEnd inSection:SectionItemInput];
        if (self.tempPosition.positionEndDate) {
            [TTUtils showAlertWithText:@"Position end date can`t be earlier that start date"];
        }
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
        [_dateFormatter setDateFormat:@"MMM yyyy"];
    }
    return _dateFormatter;
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    UITableViewCell *cell = [self tableViewCellFromSubview:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        if (indexPath.section == SectionItemInput) {
            switch (indexPath.row) {
                case PositionItemStart: {
                    UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                    self.tempPosition.positionStartDate = datePicker.date;
                    textField.text = [self.dateFormatter stringFromDate:datePicker.date];
                } break;
                case PositionItemEnd: {
                    UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                    self.tempPosition.positionEndDate = datePicker.date;
                    textField.text = [self.dateFormatter stringFromDate:datePicker.date];
                } break;
                default: {
                    
                } break;
            }
        }
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self tableViewCellFromSubview:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        if (indexPath.section == SectionItemInput) {
            if ([cell isKindOfClass:[UserProfileTextFieldTableViewCell class]]) {
                UserProfileTextFieldTableViewCell *textFieldCell = (UserProfileTextFieldTableViewCell *)cell;
                textFieldCell.highlightView.hidden = YES;
            }
            switch (indexPath.row) {
                case PositionItemStart: {
                    UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                    self.tempPosition.positionStartDate = datePicker.date;
                } break;
                case PositionItemEnd: {
                    UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                    self.tempPosition.positionEndDate = datePicker.date;
                } break;
                case PositionItemCompany: {
                    if (!self.tempPosition.positionCompany) {
                        self.tempPosition.positionCompany = [[Company alloc] init];
                    }
                    self.tempPosition.positionCompany.companyName = textField.text;
                } break;
                case PositionItemDescription: {
                    self.tempPosition.positionSummary = textField.text;
                } break;
                case PositionItemPosition: {
                    self.tempPosition.positionTitle = textField.text;
                } break;
                default: {
                    
                } break;
            }
        }
    }
    [self updateButtonsState];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
    [self textFieldDidChange:textField];
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
}

- (void)dealloc {
    
}

@end
