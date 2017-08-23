//
//  UserProfileHeaderViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileHeaderViewController.h"
#import "User.h"
#import "Position.h"
#import "Company.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "UserProfileHeaderView.h"
#import "UIView+Additions.h"
#import "TTActivityIndicator.h"
#import "UIImage+Crop.h"
#import "TTAlertView.h"
#import "NSObject+MTKObserving.h"
#import "UserProfileAccessoryView.h"

#define kDefaultImageWidth 320.0f

@interface UserProfileHeaderViewController () <UserProfileHeaderViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TTAlertViewDelegate>

@end

@implementation UserProfileHeaderViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.reloadUser = YES;
        self.setupObservations = YES;
    }
    return self;
}

- (BOOL)canMoveAwayFromController {
    if (self.tempUser) {
        return ([self.tempUser isEqualToUser:[[DataManager sharedManager] currentUser]]);
    } else {
        return YES;
    }
}

- (BOOL)handleMoveAwayFromController {
    BOOL canMoveAway = [self canMoveAwayFromController];
    if (!canMoveAway) {
        [self showSaveAlert];
    }
    return canMoveAway;
}

- (BOOL)validateInput {
    return YES;
}

- (void)validateInputAndContinue:(BOOL)back {
    
}

- (void)updateSaveButtonState {
    
}

- (void)scrollToFirstEmptyField {
    
}

- (void)scrollToNextField {

}

- (void)endEditingView {
    [self.view endEditing:YES];
}

#pragma mark Alert handling

#pragma mark Save Alert handling

- (void)showSaveAlert {
    TTAlertView *alert = [[TTAlertView alloc] initWithMessage:@"Do you want to save changes?" acceptTitle:@"SAVE" cancelTitle:@"DISCARD"];
    [alert setDelegate:self];
    [alert showOnMainWindow:YES];
}

- (void)alertView:(TTAlertView *)alertView pressedButtonWithindex:(ButtonIndex)index {
    switch (index) {
        case ButtonIndexAccept:{
            [self saveAlertPressed];
        } break;
        case ButtonIndexCancel: {
            [self cancelAlertPressed];
        } break;
        case ButtonIndexClose: {
        } break;
        default:
            break;
    }
    [alertView dismiss:YES];
}

- (void)saveAlertPressed {
    if ([self validateInput]) {
        [self validateInputAndContinue:YES];
    } else {
        [self scrollToFirstEmptyField];
    }
}

- (void)cancelAlertPressed {
   [self moveToPreviousScreen];
}

#pragma mark UserProfileAccessoryView delegate

- (void)accessoryViewCancelButtonPressed:(UserProfileAccessoryView *)view {
    [self endEditingView];
}

#pragma mark UserProfileHeaderView delegate

- (void)backButtonPressedOnProfileHeaderView:(UserProfileHeaderView *)headerView {
    [self endEditingView];
    if ([self handleMoveAwayFromController]) {
        [self moveToPreviousScreen];
    }
}

- (void)nextButtonPressedOnProfileHeaderView:(UserProfileHeaderView *)headerView {
    [self endEditingView];
    [self validateInputAndContinue:NO];
}

- (void)userFirstNameUpdatedOnProfileHeaderView:(UserProfileHeaderView *)headerView {
    self.tempUser.userFirstName = headerView.inputFirstNameField.text;
    [self updateSaveButtonState];
}

- (void)userLastNameUpdatedOnProfileHeaderView:(UserProfileHeaderView *)headerView {
    self.tempUser.userLastName = headerView.inputLastNameField.text;
    [self updateSaveButtonState];
}

- (void)moveToPreviousScreen {
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)imageButtonPressedOnProfileHeaderView:(UserProfileHeaderView *)headerView {
    [self endEditingView];
    UIActionSheet *selectSource = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"CANCEL" destructiveButtonTitle:nil otherButtonTitles:@"CAMERA", @"GALLERY", nil];
    [selectSource showInView:self.view];
}

#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (buttonIndex) {
        case 0: {
            [self choosePhotoIsFromCamera:YES];
        }
            break;
        case 1: {
            [self choosePhotoIsFromCamera:NO];
        }
            break;
    }
}

- (void)choosePhotoIsFromCamera:(BOOL)isFromCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) || ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && isFromCamera)) {
        [imagePicker setSourceType:(([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && isFromCamera)?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary)];
        [imagePicker setDelegate:self];
        imagePicker.allowsEditing = YES;
        self.reloadUser = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *imageToAdd;
    
    if (editedImage) {
        imageToAdd = editedImage;
    } else {
        imageToAdd = originalImage;
    }
//    self.tempUser.userProfileImage = [imageToAdd resizedImageToWidth:kDefaultImageWidth];
    [imageToAdd resizedImageToWidth:kDefaultImageWidth withCompletion:^(id result, NSError *error) {
        if (result && !error) {
            self.tempUser.userProfileImage = result;
        }
        [self dismissViewControllerAnimated: YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateSaveButtonState];
            });
        }];
    }];
}

#pragma mark User updating

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

#pragma mark Data reloading

- (void)reloadHeaderData {
    if (self.reloadUser) {
        self.tempUser = [[[DataManager sharedManager] currentUser] copy];
    } else {
        self.reloadUser = YES;
    }
    if (self.tempUser.userFirstName && self.tempUser.userLastName) {
        if (self.tempUser.linkedInToken) {
            self.headerView.nameContainer.hidden = NO;
            self.headerView.inputContainer.hidden = YES;
            self.headerView.userTitleLabel.text = [NSString stringWithFormat:@"%@ %@", self.tempUser.userFirstName, self.tempUser.userLastName];
        } else {
            self.headerView.nameContainer.hidden = YES;
            self.headerView.inputContainer.hidden = NO;
            
            self.headerView.userTitleLabel.text = nil;
            
            self.headerView.inputFirstNameField.text = self.tempUser.userFirstName;
            self.headerView.inputLastNameField.text = self.tempUser.userLastName;
        }
    } else {
        self.headerView.nameContainer.hidden = YES;
        self.headerView.inputContainer.hidden = NO;

        self.headerView.userTitleLabel.text = nil;
    }
    
    if (self.tempUser.positions.firstObject) {
        Position *position = (Position *)self.tempUser.positions.firstObject;
        if (position.positionCompany && position.positionTitle) {
            self.headerView.userPositionLabel.text = [NSString stringWithFormat:@"%@ at %@", position.positionTitle, position.positionCompany.companyName];
        } else {
            self.headerView.userPositionLabel.text = nil;
        }
    } else {
        self.headerView.userPositionLabel.text = nil;
    }
    
    UIImage *placeholderImage = [UIImage imageNamed:@"user_avatar_large"];
    
    [self.headerView.userImageButton sd_cancelBackgroundImageLoadForState:UIControlStateNormal];
    if (self.tempUser.userProfileImage) {
        [self.headerView.userImageButton setBackgroundImage:self.tempUser.userProfileImage forState:UIControlStateNormal];
    } else if (self.tempUser.userProfileImageURL) {
        [self.headerView.userImageButton sd_setBackgroundImageWithURL:[NSURL URLWithString:self.tempUser.userProfileImageURL] forState:UIControlStateNormal placeholderImage:placeholderImage];
    } else {
        [self.headerView.userImageButton setBackgroundImage:placeholderImage forState:UIControlStateNormal];
    }
}

- (void)setupHeaderView {
    if (self.headerContainer) {
        UserProfileHeaderView *headerView = self.headerView;
        headerView.delegate = self;
        
        UserProfileAccessoryView *accessoryView = [UserProfileAccessoryView accessoryViewWithDelegate:self];
        [headerView.inputFirstNameField setInputAccessoryView:accessoryView];
        [headerView.inputLastNameField setInputAccessoryView:accessoryView];
        
        if (self.headerContainer.subviews.count > 0) {
            [self.headerContainer insertSubview:headerView atIndex:0];
        } else {
            [self.headerContainer addSubview:headerView];
        }
        [self.headerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerView)]];
        [self.headerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerView)]];
        [headerView layoutIfNeeded];
        [self.headerContainer layoutIfNeeded];
    }
}

- (UserProfileHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [UserProfileHeaderView loadFromXib];
        [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _headerView;
}

- (void)setBackButtonHidden:(BOOL)hidden {
    [self.headerView.backButton setHidden:hidden];
}

- (void)setupTableViewItems {
    [self.tableView registerNib:[UINib nibWithNibName:@"UserProfileSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"sectionHeaderView"];
}

#pragma mark Misc

- (void)setupKeyboardVisibilityObservations {
    if (self.setupObservations) {
        /*[self observeProperty:@"keyboardVisible" withBlock:^(__weak UserProfileHeaderViewController *wself, id old, id newVal) {
            if (newVal) {
                bool visible = [newVal boolValue];
                wself.headerView.nextButton.hidden = !visible;
            }
        }];*/
        self.headerView.nextButton.hidden = NO;
    } else {
        self.headerView.nextButton.hidden = YES;
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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reloadHeaderData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupKeyboardVisibilityObservations];
    [self setupHeaderView];
    [self setupTableViewItems];
}

- (void)dealloc {
    [self removeAllObservations];
    [self.headerView.userImageButton sd_cancelBackgroundImageLoadForState:UIControlStateNormal];
}

@end
