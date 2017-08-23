//
//  UserProfileTabProfileViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileTabProfileViewController.h"
#import "UserProfilePositionsViewController.h"
#import "UserProfileEducationViewController.h"
#import "UserProfileCVViewController.h"
#import "UserProfileSkillsTableViewCell.h"
#import "UserProfileTextFieldTableViewCell.h"
#import "UserProfileTextViewTableViewCell.h"
#import "UserProfilePositionsTableViewCell.h"
#import "UserProfileEditDeleteTableViewCell.h"
#import "UserProfileSectionHeaderView.h"
#import "UserProfileAccessoryView.h"
#import "RDVTabBarController.h"
#import "TTTabBarController.h"
#import "TTAlertView.h"
#import "User.h"
#import "Position.h"
#import "Company.h"
#import "Education.h"
#import "SRMonthPicker.h"

#define kMinHeight 50.0f

typedef enum {
    SectionItemSummary,
    SectionItemPositions,
    SectionItemSkills,
    SectionItemEducation,
    SectionItemLanguages,
    SectionItemContactInfo,
    sectionsCount
} SectionItem;

typedef enum {
    SummaryItemSummary,
    summaryItemsCount
} SummaryItem;

typedef enum {
    PositionItemCompany,
    PositionItemPosition,
    PositionItemDescription,
    PositionItemStart,
    PositionItemEnd,
    PositionItemCurrent,
    positionItemsCount
} PositionItem;

typedef enum {
    SkillsItemSkills,
    skillItemsCount
} SkillItem;

typedef enum {
    EducationItemSchool,
    EducationItemStartDate,
    EducationItemEndDate,
    EducationItemDegree,
    EducationItemField,
    educationItemsCount
} EducationItem;

typedef enum {
    LanguageItemLanguage,
    languageItemsCount
} LanguageItem;

typedef enum {
    ContactItemEmail,
    ContactItemPhone,
    contactItemsCount
} ContactItem;

typedef enum {
    AlertViewTypeSave = 1,
    AlertViewTypeLogin = 2
} AlertViewType;

@interface UserProfileTabProfileViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UserProfileAccessoryViewDelegate, TTTagListDelegate, UserProfilePositionsViewControllerDelegate, UserProfileEducationViewControllerDelegate, TTAlertViewDelegate, SRMonthPickerDelegate>

@property (nonatomic, strong) NSDateFormatter *myDateFormatter;
@property (nonatomic, strong) NSDateFormatter *yDateFormatter;

@property (nonatomic, strong) Position *tempPosition;
@property (nonatomic, strong) Education *tempEducation;

@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) TTTagList *currentTagList;

@property (nonatomic, weak) IBOutlet UIButton *cvButton;

@property NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UserProfileAccessoryView *inputAccessoryView;

@property BOOL moveOnSlide;
@property BOOL reloadUser;

@end

@implementation UserProfileTabProfileViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.reloadUser = YES;
        self.moveOnSlide = NO;
    }
    return self;
}

#pragma mark Interface actions

- (void)addButtonPressed:(UIButton *)sender {
    NSInteger section = sender.tag;
    switch (section) {
        case SectionItemPositions: {
            [self showPositionScreenWithPosition:nil];
        } break;
        case SectionItemEducation: {
            [self showEducationScreenWithEducation:nil];
        } break;
        default:
            break;
    }
}

- (IBAction)editButtonPressedOnTableViewCell:(UIButton *)sender {
    [self handleEditCellButton:sender action:NO];
}

- (IBAction)deleteButtonPressedOnTableViewCell:(UIButton *)sender {
    [self handleEditCellButton:sender action:YES];
}

- (IBAction)cancelButtonPressedOnTableViewCell:(UIButton *)sender {
    NSMutableArray *itemsToReload = [NSMutableArray new];
    if (self.selectedIndexPath) {
        [itemsToReload addObject:self.selectedIndexPath];
    }
    self.selectedIndexPath = nil;
    [self.tableView reloadRowsAtIndexPaths:itemsToReload withRowAnimation:UITableViewRowAnimationMiddle];
}

- (IBAction)uploadFileButtonPressed:(id)sender {
    if ([self shouldBeginEditing]) {
        if (self.tempUser.userCVURL.length > 0) {
            [self showCVFile];
        } else {
            [self performFileUploadRequest];
            //[self.tempUser setUserCVURL:@"https://www.google.com"];
            //[self reloadData];
        }
    }
}

- (void)updateCVButtonState {
    [self.cvButton setTitle:self.tempUser.userCVURL && self.tempUser.userCVURL.length > 0 ? @"VIEW CV" : @"ATTACH RESUME" forState:UIControlStateNormal];
}

- (void)handleEditCellButton:(UIButton *)sender action:(BOOL)shouldDelete {
    self.selectedIndexPath = nil;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self tableViewCellFromSubview:sender]];
    switch (indexPath.section) {
        case SectionItemPositions: {
            if (shouldDelete) {
                Position *position = [self.tempUser.positions objectAtIndex:indexPath.row];
                [self.tempUser.positions removeObjectAtIndex:indexPath.row];
                [self.tempUser.removedPositions addObject:position];
            } else {
                [self showPositionScreenWithPosition:[self.tempUser.positions objectAtIndex:indexPath.row]];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemPositions] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case SectionItemEducation: {
            if (shouldDelete) {
                Education *education = [self.tempUser.educations objectAtIndex:indexPath.row];
                [self.tempUser.educations removeObjectAtIndex:indexPath.row];
                [self.tempUser.removedEducations addObject:education];
            } else {
                [self showEducationScreenWithEducation:[self.tempUser.educations objectAtIndex:indexPath.row]];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemEducation] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        default:
            break;
    }
    [self updateSaveButtonState];
}

#pragma mark File upload request

- (void)showCVFile {
    UserProfileCVViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileCVViewController"];
    controller.urlToOpen = self.tempUser.userCVURL;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)performFileUploadRequest {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] performUploadCVRequestWithCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [self showUploadCVAlert];
                } else {
                    if (error) {
                        [TTUtils showAlertWithText:@"Unable to complete the request at the moment"];
                    }
                }
                [TTActivityIndicator dismiss];
                loading = NO;
            }];
        }
    }
}

- (void)showUploadCVAlert {
    TTAlertView *alert = [[TTAlertView alloc] initWithMessage:[NSString stringWithFormat:@"An email with instruction and link for uploading resume was sent to: %@", [[[DataManager sharedManager] currentUser] userContactEmail]] cancelTitle:@"CLOSE"];
    [alert showOnMainWindow:YES];
}

#pragma mark Data reloading

- (void)reloadData {
    if (self.reloadUser) {
        [self copyUserInfo];
    } else {
        self.reloadUser = YES;
    }
    [self.tableView reloadData];
    [self updateCVButtonState];
    [self updateSaveButtonState];
}

#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    User *currentUser = self.tempUser;
    switch (section) {
        case SectionItemSummary: {
            return summaryItemsCount;
        } break;
        case SectionItemPositions: {
            return currentUser.positions.count ? : positionItemsCount;
        } break;
        case SectionItemSkills: {
            return skillItemsCount;
        } break;
        case SectionItemEducation: {
            return currentUser.educations.count ? : educationItemsCount;
        } break;
        case SectionItemLanguages: {
            return languageItemsCount;
        } break;
        case SectionItemContactInfo: {
            return contactItemsCount;
        } break;
        default: {
            return 0;
        } break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    User *currentUser = self.tempUser;
    
    UserProfileSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderView"];
    
    headerView.addButton.hidden = YES;
    [headerView.addButton setTag:section];
    [headerView.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *headerTitle;
    NSString *headerIcon;
    
    switch (section) {
        case SectionItemSummary: {
            headerTitle = @"Summary";
            headerIcon = @"user_summary";
        } break;
        case SectionItemPositions: {
            headerTitle = @"Positions";
            headerIcon = @"user_position";
            if (currentUser.positions.count) {
                headerView.addButton.hidden = NO;
            }
        } break;
        case SectionItemSkills: {
            headerTitle = @"Skills";
            headerIcon = @"user_skills";
        } break;
        case SectionItemEducation: {
            headerTitle = @"Education";
            headerIcon = @"user_education";
            if (currentUser.educations.count) {
                headerView.addButton.hidden = NO;
            }
        } break;
        case SectionItemLanguages: {
            headerTitle = @"Languages";
            headerIcon = @"user_language";
        } break;
        case SectionItemContactInfo: {
            headerTitle = @"Contact Info";
            headerIcon = @"user_contact";
        } break;
        default: {
          return nil;
        } break;
    }
    headerView.titleLabel.text = headerTitle;
    headerView.imageView.image = [UIImage imageNamed:headerIcon];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForCellAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForCellAtIndexPath:indexPath];
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    
    switch (indexPath.section) {
        case SectionItemSummary: {
            return UITableViewAutomaticDimension;
        } break;
        case SectionItemPositions: {
            if (currentUser.positions.count > 0) {
                return 80.0f;
            } else if (indexPath.row == PositionItemEnd && self.tempPosition.currentPosition) {
                return 0.0f;
            }
        } break;
        case SectionItemSkills: {
        } break;
        case SectionItemEducation: {
            if (currentUser.educations.count > 0) {
                return 80.0f;
            }
        } break;
        case SectionItemLanguages: {
        } break;
        default: {
            return kMinHeight;
        } break;
    }
    return kMinHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemSummary: {
            return [self cellForSummarySectionAtIndexPath:indexPath];
        } break;
        case SectionItemPositions: {
            return  [self cellForPositionsSectionAtIndexPath:indexPath];
        } break;
        case SectionItemSkills: {
            return [self cellForSkillsSectionAtIndexPath:indexPath];
        } break;
        case SectionItemEducation: {
            return [self cellForEducationSectionAtIndexPath:indexPath];
        } break;
        case SectionItemLanguages: {
            return [self cellForLanguagesSectionAtIndexPath:indexPath];
        } break;
        case SectionItemContactInfo: {
            return [self cellForContactInfoSectionAtIndexPath:indexPath];
        } break;
        default: {
            return nil;
        } break;
    }
}

#pragma mark Cells

- (UITableViewCell *)cellForSummarySectionAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    
    UserProfileTextViewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"textViewCell"];
    cell.textView.userInteractionEnabled = YES;
    cell.textView.delegate = self;
    cell.textView.text = currentUser.userProfileSummary;
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

- (UITableViewCell *)cellForPositionsSectionAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    
    if (currentUser.positions.count > 0) {
        if ([self.selectedIndexPath isEqual:indexPath]) {
            UserProfileEditDeleteTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"editCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            UserProfilePositionsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"positionsCell"];
            
            Position *position = [currentUser.positions objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = position.positionTitle;
            cell.dateLabel.text = [NSString stringWithFormat:@"%@   %@ - %@", position.positionCompany.companyName, [self.myDateFormatter stringFromDate:position.positionStartDate], position.positionEndDate ? [self.myDateFormatter stringFromDate:position.positionEndDate] : @"Present"];
            cell.summaryLabel.text = position.positionSummary;
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            return cell;
        }
    } else {
        UserProfileTextFieldTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        cell.textField.userInteractionEnabled = YES;
        cell.textField.delegate = self;
        cell.textField.inputView = nil;
        cell.textField.inputAccessoryView = [self inputAccessoryView];
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.checkMark.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSString *placeholderString;
        NSString *contentString;
        
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
                contentString = self.tempPosition.positionStartDate ? [[self yDateFormatter] stringFromDate:self.tempPosition.positionStartDate] : nil;
                cell.textField.inputView = [self datePickerInput];
            } break;
            case PositionItemEnd: {
                placeholderString = @"End";
                contentString = self.tempPosition.positionEndDate ? [[self yDateFormatter] stringFromDate:self.tempPosition.positionEndDate] : nil;
                cell.textField.userInteractionEnabled = !self.tempPosition.currentPosition;
                cell.textField.inputView = [self datePickerInput];
            } break;
            case PositionItemCurrent: {
                cell.checkMark.hidden = !self.tempPosition.currentPosition;
                cell.textField.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                placeholderString = @"Current job";
            } break;
            default:
                break;
        }
        
        [cell setAttributedPlaceholder:placeholderString];
        [cell.textField setText:contentString];
        
        return cell;
    }
}

- (UITableViewCell *)cellForSkillsSectionAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    
    UserProfileSkillsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"skillsCell"];
    [cell.tagList setTags:currentUser.skills];
    [cell.tagList.placeholderLabel setText:@"Add at least 2 skills"];
    [cell.tagList setDelegate:self];
    [cell.tagList setInputAccessoryView:[self inputAccessoryView]];
    return cell;
}

- (UITableViewCell *)cellForEducationSectionAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    if (currentUser.educations.count > 0) {
        if ([self.selectedIndexPath isEqual:indexPath]) {
            UserProfileEditDeleteTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"editCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            UserProfilePositionsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"positionsCell"];
            
            Education *education = [currentUser.educations objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = education.educationSchool;
            cell.dateLabel.text = [NSString stringWithFormat:@"%@   %@ - %@", education.educationDegree, [self.yDateFormatter stringFromDate:education.educationStartDate],  [self.yDateFormatter stringFromDate:education.educationEndDate] ?: @"Present"];
            cell.summaryLabel.text = education.educationField;
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            return cell;
        }
    } else {
        UserProfileTextFieldTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        cell.textField.userInteractionEnabled = YES;
        cell.textField.delegate = self;
		cell.textField.inputView = nil;
        cell.textField.inputAccessoryView = [self inputAccessoryView];
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.checkMark.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *placeholderString;
        NSString *contentString;
        
        switch (indexPath.row) {
            case EducationItemSchool: {
                placeholderString = @"School or College";
                contentString = self.tempEducation.educationSchool;
            } break;
            case EducationItemStartDate: {
                placeholderString = @"Start year";
                contentString = self.tempEducation.educationStartDate ? [self.yDateFormatter stringFromDate:self.tempEducation.educationStartDate]: nil;
                cell.textField.inputView = [self datePickerInput];
            } break;
            case EducationItemEndDate: {
                placeholderString = @"End year";
                contentString = self.tempEducation.educationEndDate ? [self.yDateFormatter stringFromDate:self.tempEducation.educationEndDate]: nil;
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
    }
}

- (UITableViewCell *)cellForLanguagesSectionAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    UserProfileSkillsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"skillsCell"];
    [cell.tagList setTags:currentUser.languages];
    [cell.tagList.placeholderLabel setText:@"Add Languages"];
    [cell.tagList setDelegate:self];
    [cell.tagList setInputAccessoryView:[self inputAccessoryView]];
    return cell;

}

- (UITableViewCell *)cellForContactInfoSectionAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    
    UserProfileTextFieldTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
    cell.textField.userInteractionEnabled = YES;
    cell.textField.delegate = self;
    cell.textField.inputView = nil;
    cell.textField.inputAccessoryView = [self inputAccessoryView];
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    cell.checkMark.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *placeholderString;
    
    switch (indexPath.row) {
        case ContactItemEmail: {
            placeholderString = @"Email";
            cell.textField.text = currentUser.userContactEmail;
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        } break;
        case ContactItemPhone: {
            placeholderString = @"Phone number";
            cell.textField.text = currentUser.userPhone;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        } break;
        default: break;
    }
    
    [cell setAttributedPlaceholder:placeholderString];
    
    return cell;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    void (^handleCellSelection)(void) = ^{
        NSMutableArray *itemsToReload = [NSMutableArray new];
        if (self.selectedIndexPath) {
            [itemsToReload addObject:self.selectedIndexPath];
        }
        if ([self.selectedIndexPath isEqual:indexPath]) {
            self.selectedIndexPath = nil;
        } else {
            self.selectedIndexPath = indexPath;
            [itemsToReload addObject:indexPath];
        }
        [self.tableView reloadRowsAtIndexPaths:itemsToReload withRowAnimation:UITableViewRowAnimationMiddle];
    };
    
    User *currentUser = self.tempUser;
    switch (indexPath.section) {
        case SectionItemPositions: {
            if (currentUser.positions.count > 0) {
                handleCellSelection();
                //[self showPositionScreenWithPosition:[currentUser.positions objectAtIndex:indexPath.row]];
            } else {
                switch (indexPath.row) {
                    case PositionItemCurrent: {
                        if ([self shouldBeginEditing]) {
                            self.tempPosition.currentPosition = !self.tempPosition.currentPosition;
                            [tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionItemPositions] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    } break;
                    default: break;
                }
            }
        } break;
        case SectionItemEducation: {
            if (currentUser.educations.count > 0) {
                handleCellSelection();
                //[self showEducationScreenWithEducation:[currentUser.educations objectAtIndex:indexPath.row]];
            }
        } break;
        default: {
        } break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    if (indexPath.section == SectionItemPositions && (currentUser.positions.count > 0)) {
        return YES;
    } else if (indexPath.section == SectionItemEducation && (currentUser.educations.count > 0)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    User *currentUser = self.tempUser;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == SectionItemPositions) {
            [currentUser.positions removeObjectAtIndex:indexPath.row];
        } else if (indexPath.section == SectionItemEducation) {
            [currentUser.educations removeObjectAtIndex:indexPath.row];
        }
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}*/

#pragma mark - TextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return [self shouldBeginEditing];
}

- (void)updateTextViewHeight {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[UserProfileTextViewTableViewCell class]]) {
            UserProfileTextViewTableViewCell *profileCell = (UserProfileTextViewTableViewCell *)cell;
            if (profileCell.textView.isFirstResponder) {
                CGSize size = profileCell.textView.bounds.size;
                CGSize newSize = [profileCell.textView sizeThatFits:CGSizeMake(size.width, MAXFLOAT)];
                if (size.height != newSize.height) {
                    //[UIView setAnimationsEnabled:NO];
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:profileCell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    //[UIView setAnimationsEnabled:YES];
                }
                break;
            }
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (finalString.length <= kSummaryCharacterLimit || finalString.length < textView.text.length) {
        return YES;
    } else {
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self tableViewCellFromSubview:textView]];
    if (indexPath) {
        self.tempUser.userProfileSummary = textView.text;
    }
    [self updateSaveButtonState];
    [self updateTextViewHeight];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [[self inputAccessoryView] setSuggestionsEnabled:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self textViewDidChange:textView];
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self shouldBeginEditing];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    [[self inputAccessoryView] setSuggestionsEnabled:NO];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self tableViewCellFromSubview:textField]];
    if (indexPath) {
        switch (indexPath.section) {
            case SectionItemPositions: {
                switch (indexPath.row) {
                    case PositionItemStart:
                    case PositionItemEnd: {
                        UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                        textField.text = [self.yDateFormatter stringFromDate:datePicker.date];
                    } break;
                    default: {
                        
                    } break;
                }
            } break;
            case SectionItemEducation: {
                switch (indexPath.row) {
                    case EducationItemStartDate:
                    case EducationItemEndDate: {
                        UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
                        textField.text = [self.yDateFormatter stringFromDate:datePicker.date];
                    } break;
                    default: {
                        
                    } break;
                }
            } break;
            default:
                break;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
    [self textFieldDidChange:textField];
}

- (void)textFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self tableViewCellFromSubview:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        if ([cell isKindOfClass:[UserProfileTextFieldTableViewCell class]]) {
            UserProfileTextFieldTableViewCell *textFieldCell = (UserProfileTextFieldTableViewCell *)cell;
            textFieldCell.highlightView.hidden = YES;
        }
        switch (indexPath.section) {
            case SectionItemPositions: {
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
            } break;
            case SectionItemEducation: {
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
                        self.tempEducation.institution.institutionName = textField.text;
                    } break;
                    default: {
                        
                    } break;
                }
            } break;
            case SectionItemContactInfo: {
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
            } break;
            default:
                break;
        }
    }
    [self updateSaveButtonState];
}

#pragma mark TTTagList delegate 

- (BOOL)tagListShouldBeginEditing:(TTTagList *)tagList {
    return [self shouldBeginEditing];
}

- (void)tagListDidBeginEditing:(TTTagList *)tagList {
    self.currentTagList = tagList;
    [[self inputAccessoryView] setSuggestionsEnabled:YES];
}

- (void)tagListDidChange:(TTTagList *)tagList {
    [[self inputAccessoryView] filterSuggestionsByInput:tagList.inputString];
}

- (void)tagListDidEndEditing:(TTTagList *)tagList {
    self.currentTagList = nil;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self tableViewCellFromSubview:tagList]];
    if (indexPath) {
        switch (indexPath.section) {
            case SectionItemLanguages: {
                if (tagList.tags.count) {
                    [self.tempUser.languages setArray:tagList.tags];
                } else {
                    [self.tempUser.languages removeAllObjects];
                }
            } break;
            case SectionItemSkills: {
                if (tagList.tags.count) {
                    [self.tempUser.skills setArray:tagList.tags];
                } else {
                    [self.tempUser.skills removeAllObjects];
                }
            } break;
            default:
                break;
        }
    }
    [self updateSaveButtonState];
}


- (BOOL)shouldBeginEditing {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        return YES;
    } else {
        [self showLoginAlert];
    }
    return NO;
}

#pragma mark PositionsViewController delegate

- (void)positionsViewController:(UserProfilePositionsViewController *)controller replacePosition:(Position *)oldPosition withPosition:(Position *)newPosition {
    [self.tempUser.positions replaceObjectAtIndex:[self.tempUser.positions indexOfObject:oldPosition] withObject:newPosition];
    [self updateSaveButtonState];
}

- (void)positionsViewController:(UserProfilePositionsViewController *)controller shouldUpdatePositions:(NSArray *)positions {
    [self.tempUser.positions setArray:positions];
    [self updateSaveButtonState];
}

#pragma mark EducationViewController delegate

- (void)educationViewController:(UserProfileEducationViewController *)controller replaceEducation:(Education *)oldEducation withEducation:(Education *)newEducation {
    [self.tempUser.educations replaceObjectAtIndex:[self.tempUser.educations indexOfObject:oldEducation] withObject:newEducation];
    [self updateSaveButtonState];
}

- (void)educationViewController:(UserProfileEducationViewController *)controller shouldUpdateEducations:(NSArray *)educations {
    [self.tempUser.educations setArray:educations];
    [self updateSaveButtonState];
}

#pragma mark Save button handling

- (void)updateSaveButtonState {
    [self.delegate profileTabProfileViewController:self shouldChangeSaveButtonState:[self canMoveAwayFromController]];
}

- (BOOL)handleMoveAwayFromController {
    BOOL canMoveAway = [self canMoveAwayFromController];
    if (!canMoveAway) {
        //if ([self validateInputAndScrollToEmpty:YES]) {
        [self showSaveAlert];
        //} else {
        //    [self closeAlertPressed];
        //}
    }
    return canMoveAway;
}

- (BOOL)handleMoveAwayFromControllerOnSlide {
    BOOL canMoveAway = [self canMoveAwayFromController];
    if (!canMoveAway) {
        self.moveOnSlide = YES;
        //if ([self validateInputAndScrollToEmpty:YES]) {
        [self showSaveAlert];
        //} else {
        //    [self closeAlertPressed];
        //}
    }
    return canMoveAway;
}

- (BOOL)canMoveAwayFromController {
    if (self.tempUser) {
        return ([self.tempUser isEqualToUser:[[DataManager sharedManager] currentUser]] &&
                ![self.tempPosition isPartiallyFilled] &&
                ![self.tempEducation isPartiallyFilled]);
    } else {
        return YES;
    }
}

- (void)showLoginAlert {
    TTAlertView *alert = [[TTAlertView alloc] initWithMessage:@"Please log in to continue" cancelTitle:@"LOG IN"];
    [alert setDelegate:self];
    [alert setTag:AlertViewTypeLogin];
    [alert showOnMainWindow:YES];
}


#pragma mark Save Alert handling

- (void)showSaveAlert {
    TTAlertView *alert = [[TTAlertView alloc] initWithMessage:@"Do you want to save changes?" acceptTitle:@"SAVE" cancelTitle:nil];
    [alert setDelegate:self];
    [alert setTag:AlertViewTypeSave];
    [alert showOnMainWindow:YES];
}

- (void)alertView:(TTAlertView *)alertView pressedButtonWithindex:(ButtonIndex)index {
    switch (alertView.tag) {
        case AlertViewTypeSave: {
            switch (index) {
                case ButtonIndexAccept: {
                    [self saveAlertPressed];
                } break;
                case ButtonIndexCancel: {
                    [self updateUserAndMoveToTabItem:NO];
                } break;
                case ButtonIndexClose: {
                    [self closeAlertPressed];
                } break;
                default:
                    break;
            }
        } break;
        case AlertViewTypeLogin: {
            if (index != ButtonIndexClose) {
                [self moveToLoginScreen];
            }
        } break;
        default:
            break;
    }
    [alertView dismiss:YES];
}

- (void)saveButtonPressed {
    if ([self validateInputAndScrollToEmpty:YES]) {
        [self updateUserAndMoveToTabItem:NO];
    }
}

- (void)saveAlertPressed {
    if ([self validateInputAndScrollToEmpty:YES]) {
        [self updateUserAndMoveToTabItem:YES];
    }
}

- (void)updateUserAndMoveToTabItem:(BOOL)move {
    [self.view endEditing:YES];
#warning VALIDATE INPUT
    
    if ([self.tempPosition isFilled]) {
        [self.tempUser.positions addObject:self.tempPosition];
    }
    if ([self.tempEducation isFilled]) {
        [self.tempUser.educations addObject:self.tempEducation];
    }
    
    [self updateUserProfileWithCompletionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            [self.delegate reloadUserOnProfileTabProfileViewController:self];
            [self reloadData];
            if (self.moveOnSlide) {
                self.moveOnSlide = NO;
                [self.delegate moveAwayFromProfileTabProfileViewController:self];
            } else {
                if (move) {
                    TTTabBarController *tabController = (TTTabBarController *)self.rdv_tabBarController;
                    if (tabController) {
                        [tabController moveToScheduledTabItem];
                    } else {
                        [self.parentViewController.navigationController popViewControllerAnimated:YES];
                    }
                } else {
                    [self.tableView setContentOffset:CGPointZero animated:NO];
                }
            }
        } else {
            if (error) {
#warning CHANGE TO SOMETHING MORE VIABLE
                [TTUtils showAlertWithText:@"Unable to save at the moment"];
            }
        }
    }];
}

- (void)cancelAlertPressed {
    [self reloadData];
    if (self.moveOnSlide) {
        self.moveOnSlide = NO;
        [self.delegate moveAwayFromProfileTabProfileViewController:self];
    } else {
        TTTabBarController *tabController = (TTTabBarController *)self.rdv_tabBarController;
        [tabController moveToScheduledTabItem];
    }
}

- (void)closeAlertPressed {
    if (self.moveOnSlide) {
        self.moveOnSlide = NO;
        [self.delegate cancelMoveAwayFromProfileTabProfileViewController:self];
    } else {
        TTTabBarController *tabController = (TTTabBarController *)self.rdv_tabBarController;
        [tabController setScheduledTabItem:TabItemNone];
    }
}

#pragma mark Saving user

- (void)updateUserProfileWithCompletionHandler:(SimpleCompletionBlock)completion {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] updateUser:self.tempUser completionHandler:^(BOOL success, NSError *error) {
                [TTActivityIndicator dismiss];
                loading = NO;
                if (completion) {
                    completion(success, error);
                }
            }];
        }
    }
}

#pragma mark Navigation

- (void)showPositionScreenWithPosition:(Position *)position {
    self.reloadUser = NO;
    [self.delegate profileTabProfileViewController:self reloadUserState:NO];
    UserProfilePositionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfilePositionsViewController"];
    controller.delegate = self;
    controller.currentPosition = position;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showEducationScreenWithEducation:(Education *)education {
    self.reloadUser = NO;
    [self.delegate profileTabProfileViewController:self reloadUserState:NO];
    UserProfileEducationViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileEducationViewController"];
    controller.delegate = self;
    controller.currentEducation = education;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveToLoginScreen {
    [[DataManager sharedManager] showLoginScreen];
}

#pragma mark Scrolling to next field

- (void)scrollToFirstEmptyField {
    NSIndexPath *nextIndexPath;
    if (!self.tempUser.userProfileSummary.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:SummaryItemSummary inSection:SectionItemSummary];
    } else if (!self.tempUser.positions.count) {
        nextIndexPath = [self emptyIndexPathForPositionInput];
    } else if (!self.tempUser.skills.count) {
        nextIndexPath = [NSIndexPath indexPathForRow:SkillsItemSkills inSection:SectionItemSkills];
    } else if (!self.tempUser.educations.count) {
        nextIndexPath = [self emptyIndexPathForEducationInput];
    } else if (!self.tempUser.languages.count) {
        nextIndexPath = [NSIndexPath indexPathForRow:LanguageItemLanguage inSection:SectionItemLanguages];
    } else if (!self.tempUser.userEmail.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:ContactItemEmail inSection:SectionItemContactInfo];
    } else if (!self.tempUser.userPhone.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:ContactItemPhone inSection:SectionItemContactInfo];
    }
    [self scrollToIndexPath:nextIndexPath highlight:YES];
}

- (NSIndexPath *)emptyIndexPathForPositionInput {
    NSIndexPath *nextIndexPath;
    if (!self.tempPosition.positionCompany.companyName.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:PositionItemCompany inSection:SectionItemPositions];
    } else if (!self.tempPosition.positionTitle) {
        nextIndexPath = [NSIndexPath indexPathForRow:PositionItemPosition inSection:SectionItemPositions];
    } else if (!self.tempPosition.positionSummary) {
        nextIndexPath = [NSIndexPath indexPathForRow:PositionItemDescription inSection:SectionItemPositions];
    } else if (!self.tempPosition.positionStartDate) {
        nextIndexPath = [NSIndexPath indexPathForRow:PositionItemStart inSection:SectionItemPositions];
    } else if (!self.tempPosition.positionEndDate && !self.tempPosition.currentPosition) {
        nextIndexPath = [NSIndexPath indexPathForRow:PositionItemEnd inSection:SectionItemPositions];
    }
    return nextIndexPath;
}

- (NSIndexPath *)emptyIndexPathForEducationInput {
    NSIndexPath *nextIndexPath;
    if (!self.tempEducation.educationSchool.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:EducationItemSchool inSection:SectionItemEducation];
    } else if (!self.tempEducation.educationStartDate) {
        nextIndexPath = [NSIndexPath indexPathForRow:EducationItemStartDate inSection:SectionItemEducation];
    } else if (!self.tempEducation.educationEndDate) {
        nextIndexPath = [NSIndexPath indexPathForRow:EducationItemEndDate inSection:SectionItemEducation];
    } else if (!self.tempEducation.educationDegree.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:EducationItemDegree inSection:SectionItemEducation];
    } else if (!self.tempEducation.educationField.length) {
        nextIndexPath = [NSIndexPath indexPathForRow:EducationItemField inSection:SectionItemEducation];
    }
    return nextIndexPath;
}

- (void)scrollToNextField {
    NSIndexPath *indexPath = [self indexPathForFirstResponder];
    NSIndexPath *nextIndexPath;
    if (indexPath) {
        switch (indexPath.section) {
            case SectionItemSummary: {
                if (self.tempUser.positions.count > 0) {
                    nextIndexPath = [NSIndexPath indexPathForRow:SkillsItemSkills inSection:SectionItemSkills];
                } else {
                    nextIndexPath = [NSIndexPath indexPathForRow:PositionItemCompany inSection:SectionItemPositions];
                }
            } break;
            case SectionItemPositions: {
                if (indexPath.row < positionItemsCount - 2) {
                    nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:SectionItemPositions];
                } else {
                    nextIndexPath = [NSIndexPath indexPathForRow:SkillsItemSkills inSection:SectionItemSkills];
                }
            } break;
            case SectionItemSkills: {
                if (self.tempUser.educations.count > 0) {
                    nextIndexPath = [NSIndexPath indexPathForRow:LanguageItemLanguage inSection:SectionItemLanguages];
                } else {
                    nextIndexPath = [NSIndexPath indexPathForRow:EducationItemSchool inSection:SectionItemEducation];
                }
            } break;
            case SectionItemEducation: {
                if (indexPath.row < educationItemsCount - 1) {
                    nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:SectionItemEducation];
                } else {
                    nextIndexPath = [NSIndexPath indexPathForRow:LanguageItemLanguage inSection:SectionItemLanguages];
                }
            } break;
            case SectionItemLanguages: {
                nextIndexPath = [NSIndexPath indexPathForRow:ContactItemEmail inSection:SectionItemContactInfo];
            } break;
            case SectionItemContactInfo: {
                if (indexPath.row < contactItemsCount - 1) {
                    nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:SectionItemContactInfo];
                } else {
                    [self.view endEditing:YES];
                }
            } break;
            default:
                break;
        }
    }
    [self scrollToIndexPath:nextIndexPath highlight:NO];
}

#pragma mark Input validation

- (BOOL)validateInputAndScrollToEmpty:(BOOL)scroll {
    BOOL result = YES;
    NSIndexPath *indexPath;
    if (self.tempUser.userProfileSummary.length) {
        if (self.tempUser.userProfileSummary.length > kSummaryCharacterLimit) {
            indexPath = [NSIndexPath indexPathForRow:SummaryItemSummary inSection:SectionItemSummary];
            result = NO;
        }
    }
    if ((self.tempUser.positions.count == 0) && self.tempPosition.isPartiallyFilled) {
        if (!self.tempPosition.isFilled) {
            indexPath = [self emptyIndexPathForPositionInput];
            result = NO;
        }
    }
    if ((self.tempUser.educations.count == 0) && self.tempEducation.isPartiallyFilled) {
        if (!self.tempEducation.isFilled) {
            indexPath = [self emptyIndexPathForEducationInput];
            result = NO;
        }
    }
    if (self.tempUser.userContactEmail.length) {
        if (![TTUtils validateEmail:self.tempUser.userContactEmail]) {
            indexPath = [NSIndexPath indexPathForRow:ContactItemEmail inSection:SectionItemContactInfo];
            result = NO;
        }
    }
    if (self.tempUser.userPhone.length) {
        if (![TTUtils validatePhone:self.tempUser.userPhone]) {
            indexPath = [NSIndexPath indexPathForRow:ContactItemPhone inSection:SectionItemContactInfo];
            result = NO;
        }
    }
    if (scroll && indexPath) {
        [self scrollToIndexPath:indexPath highlight:YES];
    }
    return result;
}

#pragma mark UserProfileAccessoryView delegate

- (void)accessoryViewCancelButtonPressed:(UserProfileAccessoryView *)view {
    [self.currentTagList endEditing];
    [self.view endEditing:YES];
}

- (void)accessoryView:(UserProfileAccessoryView *)view didSelectItem:(NSString *)string {
    if (self.currentTagList) {
        [self.currentTagList setCurrentTag:string];
    } else {
        UITableViewCell *cell = [self tableViewCellFromSubview:self.currentTextField];
        if (cell) {
            if ([cell isKindOfClass:[UserProfileTextFieldTableViewCell class]]) {
                UserProfileTextFieldTableViewCell *textFieldCell = (UserProfileTextFieldTableViewCell *)cell;
                textFieldCell.textField.text = string;
            } else if ([cell isKindOfClass:[UserProfileTextViewTableViewCell class]]) {
                UserProfileTextViewTableViewCell *textViewCell = (UserProfileTextViewTableViewCell *)cell;
                textViewCell.textView.text = string;
            }
        }
    }
}

#pragma mark Month picker delegate

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker {
    [self.currentTextField setText:[self.yDateFormatter stringFromDate:monthPicker.date]];
}

#pragma mark Misc

- (UIPickerView *)datePickerInput {
    SRMonthPicker *picker = [[SRMonthPicker alloc] init];
    [picker setMinimumYear:1900];
    [picker setMaximumYear:[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]].year];
    [picker setMonthPickerDelegate:self];
    return picker;
}

- (UserProfileAccessoryView *)inputAccessoryView {
    @synchronized(self) {
        if (!_inputAccessoryView) {
            _inputAccessoryView = [UserProfileAccessoryView accessoryViewWithDelegate:self];
        }
        return _inputAccessoryView;
    }
}

- (NSDateFormatter *)myDateFormatter {
    if (!_myDateFormatter) {
        _myDateFormatter = [[NSDateFormatter alloc] init];
        [_myDateFormatter setDateFormat:@"MMM yyyy"];
    }
    return _myDateFormatter;
}

- (NSDateFormatter *)yDateFormatter {
    if (!_yDateFormatter) {
        _yDateFormatter = [[NSDateFormatter alloc] init];
        [_yDateFormatter setDateFormat:@"yyyy"];
    }
    return _yDateFormatter;
}

- (void)copyUserInfo {
    if (!self.tempUser) {
        self.tempUser = [[[DataManager sharedManager] currentUser] copy];
    }
    DLog(@"ProfileTab User Data: %@", [self.tempUser dictionary]);
    self.tempEducation = [Education new];
    self.tempPosition = [Position new];
}

#pragma mark TT Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.tableView;
}

#pragma mark View lifeCycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.scrollToEmptyField) {
        self.scrollToEmptyField = NO;
        [self scrollToFirstEmptyField];
    }
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserProfileSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"sectionHeaderView"];
    
}

@end
