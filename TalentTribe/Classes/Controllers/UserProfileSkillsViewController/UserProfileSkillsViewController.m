//
//  UserProfileSkillsViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileSkillsViewController.h"
#import "UserProfileSkillsTableViewCell.h"
#import "UserProfileSectionHeaderView.h"
#import "UserProfileAccessoryView.h"
#import "TTTagList.h"
#import "User.h"

@interface UserProfileSkillsViewController () <UITableViewDataSource, UITableViewDelegate, TTTagListDelegate>

@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) UserProfileAccessoryView *inputAccessory;

@end

@implementation UserProfileSkillsViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        
    }
    return self;
}

- (void)endEditingView {
    [self.view endEditing:YES];
    [[[self skillsCell] tagList] endEditing];
    [self populateTags];
}

- (void)populateTags {
    UserProfileSkillsTableViewCell *skillsCell = [self skillsCell];
    NSArray *tags = skillsCell.tagList.tags;
    [self.tempUser.skills setArray:tags];
}

#pragma mark Input validation

- (void)validateInputAndContinue:(BOOL)back {
    [self endEditingView];
    if ([self validateInput]) {
        [self populateTags];
        [self updateUserProfileWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success && !error) {
                [self moveToContactScreen];
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
    UserProfileSkillsTableViewCell *skillsCell = [self skillsCell];
    if (skillsCell.tagList.tags.count > 0) {
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

- (UserProfileSkillsTableViewCell *)skillsCell {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[UserProfileSkillsTableViewCell class]]) {
            return (UserProfileSkillsTableViewCell *)cell;
        }
    }
    return nil;
}

- (void)updateButtonsState {
    //[self.nextButton setEnabled:[self validateInput]];
}

- (void)moveToContactScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileContactViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark TTTagList delegate

- (void)tagList:(TTTagList *)tagList didAddTag:(NSString *)tag {
    [self updateButtonsState];
}

- (void)tagList:(TTTagList *)tagList didRemovedTag:(NSString *)tag atIndex:(NSInteger)index {
    [self updateButtonsState];
}

- (void)tagListDidChange:(TTTagList *)tagList {
    [[self inputAccessory] filterSuggestionsByInput:tagList.inputString];
}

- (void)accessoryView:(UserProfileAccessoryView *)view didSelectItem:(NSString *)string {
    [[[self skillsCell] tagList] setCurrentTag:string];
    [self updateButtonsState];
}

- (UserProfileAccessoryView *)inputAccessory {
    if (!_inputAccessory) {
        _inputAccessory = [UserProfileAccessoryView accessoryViewWithDelegate:self];
        [_inputAccessory setSuggestionsEnabled:YES];
    }
    return _inputAccessory;
}

#pragma mark Data reloading

- (void)reloadData {
    [self.tableView reloadData];
    [self updateButtonsState];
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UserProfileSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderView"];
    headerView.addButton.hidden = YES;
    headerView.titleLabel.text = @"Skills";
    headerView.imageView.image = [UIImage imageNamed:@"user_skills"];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileSkillsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"skillsCell"];
    [cell.tagList setTags:self.tempUser.skills];
    [cell.tagList.placeholderLabel setText:@"Add at least 2 skills"];
    [cell.tagList setInputAccessoryView:[self inputAccessory]];
    [cell.tagList setDelegate:self];
    return cell;
}

#pragma mark UITableView delegate

- (void)scrollToFirstEmptyField {
    if (!self.tempUser.skills.count) {
        [[[self skillsCell] tagList] beginEditing];
    }
}

#pragma mark View lifeCycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
    //[self scrollToFirstEmptyField];
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
