//
//  CreateQuestionViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/19/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateQuestionViewController.h"
#import "CreateChangeColorsView.h"
#import "TTGradientHandler.h"
#import "ReferQuestionViewController.h"
#import "SZTextView.h"
#import "TTTabBarController.h"
#import "UIView+Additions.h"
#import "QuickSearch.h"
#import "User.h"
#import "Company.h"

@interface CreateQuestionViewController ()

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIView *questionView;
@property (strong, nonatomic) IBOutlet UIButton *referButton;

@property (nonatomic, weak) IBOutlet TTCustomGradientView *questionGradientView;
@property (nonatomic, weak) IBOutlet CreateChangeColorsView *changeColorsView;

@property (nonatomic, weak) IBOutlet SZTextView *textView;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewBottomSpace;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (nonatomic, weak) IBOutlet UIView *changeColorsButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *colorsButtonBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *colorsButtonLeftSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *colorsButtonRightSpace;

@property (weak, nonatomic) IBOutlet UILabel *lblReferQuestion;

@property (nonatomic) TTGradientType currentGradientType;

@end

@implementation CreateQuestionViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.currentGradientType = TTGradientType1;
        self.anonymously = NO;
        if(![[DataManager sharedManager] isCredentialsSavedInKeychain]) {
            self.anonymously = YES;
            _avatarImageView.hidden = YES;
        }
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    [self.questionGradientView setGradientType:_currentGradientType];
}

#pragma mark Interface Actions

- (IBAction)referButtonPressed:(id)sender {
    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"referQuestionViewController"] animated:YES];
}
- (IBAction)userModePressed:(id)sender
{
    _avatarImageView.hidden = !_avatarImageView.hidden;
    self.anonymously = _avatarImageView.hidden;
    if(![[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        self.anonymously = YES;
        _avatarImageView.hidden = YES;
    }
    
}

- (IBAction)changeColorPressed:(UIButton *)sender {
    self.currentGradientType = (TTGradientType)(sender.tag % gradientTypeCount);
    [self.questionGradientView setGradientType:self.currentGradientType animated:YES];
}

- (IBAction)openColorWindowPressed:(id)sender {
    [self.changeColorsView showViewAnimated:YES completion:nil];
}

- (IBAction)closeColorWindowPressed:(id)sender {
    [self.changeColorsView hideViewAnimated:YES completion:nil];
}

#pragma mark Input validation

- (BOOL)validateInput {
    if (self.textView.text.length > 0) {
        return YES;
    } else {
        [self.textView becomeFirstResponder];
        [self showInputAlertWithText:@"Question content can`t be empty"];
    }
    return NO;
}

- (Story *)story {
    Story *story = [[Story alloc] init];
    story.storyContent = self.textView.text;
    story.storyType = StoryTypeQuestion;
    if (self.company) {
        story.companyId = self.company.companyId;
    }
    return story;
}

#pragma mark Keyboard handling

- (void)keyboardWillShow {
    [self.view layoutIfNeeded];
    self.scrollViewBottomSpace.constant = CGRectGetHeight(self.keyboardFrame) - CGRectGetHeight(self.rdv_tabBarController.tabBar.frame);
    
    [UIView animateWithDuration:self.keyboardTransitionDuration delay:0.0f options:self.keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
        [self updateContentSize];
        [self updateColorsButtonPosition];
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.frame))];
    } completion:^(BOOL finished){
        
    }];
}

- (void)keyboardWillHide {
    [self.view layoutIfNeeded];
    self.scrollViewBottomSpace.constant = 0.0f;
    
    [UIView animateWithDuration:self.keyboardTransitionDuration delay:0.0f options:self.keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
        [self updateContentSize];
        [self updateColorsButtonPosition];
        [self.scrollView setContentOffset:CGPointZero];
    } completion:^(BOOL finished){
        
    }];
}

#pragma mark Misc

- (void)setupTextPlaceholder {
    NSDictionary *attributes = @{NSFontAttributeName : self.textView.font, NSForegroundColorAttributeName : self.textView.textColor};
    self.textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Ask your question" attributes:attributes];
}

- (void)updateContentSize {
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.contentView.frame), CGRectGetMaxY(self.contentView.frame))];
}

- (void)updateColorsButtonPosition {
    if (!self.keyboardShown) {
        self.colorsButtonLeftSpace.constant = CGRectGetMinX(self.questionView.frame);
        self.colorsButtonRightSpace.constant = CGRectGetWidth(self.view.frame) - CGRectGetMaxX(self.questionView.frame);
        self.colorsButtonBottomSpace.constant = CGRectGetHeight(self.view.frame) - self.scrollView.contentSize.height;
        [self.changeColorsButton setRoundedCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight radius:self.questionView.layer.cornerRadius];
    } else {
        self.colorsButtonLeftSpace.constant = 0.0f;
        self.colorsButtonRightSpace.constant = 0.0f;
        self.colorsButtonBottomSpace.constant = CGRectGetHeight(self.keyboardFrame) - CGRectGetHeight(self.rdv_tabBarController.tabBar.frame);
        [self.changeColorsButton removeRoundedCorners];
    }
}

#pragma mark - Set the Refer question label

- (void)setTheRefereQuestionLabel {
    NSMutableAttributedString *boldString = [[NSMutableAttributedString alloc] initWithString:self.lblReferQuestion.text];
    NSRange boldedRange = NSMakeRange(18, self.lblReferQuestion.text.length-18);
    [boldString addAttribute:NSFontAttributeName value:TITILLIUMWEB_BOLD([self.lblReferQuestion font].pointSize) range:boldedRange];
    self.lblReferQuestion.attributedText = boldString;
}

#pragma mark View lifeCycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateContentSize];
    [self updateColorsButtonPosition];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //_avatarImageView.image = [DataManager sharedManager].currentUser.userAvatar;
    QuickSearch *quickSearch = [DataManager sharedManager].companySelectedArray.lastObject;
    if(quickSearch || self.company)
    {
        self.lblReferQuestion.text = [NSString stringWithFormat:@"refer question to %@", quickSearch ? quickSearch.quickSearchName : self.company.companyName];
    }
    [self setTheRefereQuestionLabel];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextPlaceholder];
}

@end
