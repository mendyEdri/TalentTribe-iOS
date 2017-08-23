//
//  StoryFeedTableViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryFeedTableViewCell.h"
#import "UIView+Additions.h"
#import "TTDragVibeView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Story.h"
#import "ColoredTextView.h"

@interface StoryFeedTableViewCell () <TTDragVibeViewDelegate, UIScrollViewDelegate>

@end

@implementation StoryFeedTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dragVibeView = [TTDragVibeView loadFromXib];
        self.dragVibeView.delegate = self;
        [self setNotifications];
    }
    return self;
}

-(void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSideScroll:) name:kScrollingMode object:nil];
}

-(void)enableSideScroll:(NSNotification *)notification
{
    BOOL enable = [[notification object]boolValue];
    self.userInteractionEnabled = enable;
}

- (IBAction)leftButtonPressed:(id)sender {
    [self.delegate leftButtonPressedOnStoryFeedTableViewCell:self];
}

- (IBAction)rightButtonPressed:(id)sender {
    [self.delegate rightButtonPressedOnStoryFeedTableViewCell:self];
}

#pragma mark Drag view handling

- (void)updateButtonsState {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    if (indexPath) {
        self.leftButton.hidden = indexPath.row <= 0;
        self.rightButton.hidden = indexPath.row >= ([self.collectionView numberOfItemsInSection:indexPath.section] - 1);
        [self updateLikeButtonState];
    }
}

- (void)updateLikeButtonState {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    if (indexPath) {
        Story *story = [self.company.stories objectAtIndex:indexPath.row];
        if (story.storyType == StoryTypeHardFacts) {
            [self.company setWannaWork:self.company.userVibed];
            [self setUserVibedStory:self.company.userVibed];
        } else {
            [self setUserVibedStory:story.userLike];
        }
    }
}

- (void)unlikeVibeOnDragView:(TTDragVibeView *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    if (!indexPath) {
        return;
    }
    Story *story = [self.company.stories objectAtIndex:indexPath.row];
    [[DataManager sharedManager] likeStory:story like:NO completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            [self setUserVibedStory:NO];
        }
    }];
}

-(void)blinkCellWithColor:(UIColor *)color interval:(CGFloat)interval firstAlpha:(CGFloat)alpha parent:(UITableView *)parent
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [view setAlpha:alpha];
    [view setBackgroundColor:color];
    view.userInteractionEnabled = NO;
    [self.collectionView addSubview:view];
    [UIView animateWithDuration:interval animations:^{
        [view setAlpha:0];
    }
     completion:^(BOOL finished)
    {
        [view removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(collectionViewCellShouldClick:)])
        {
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            StoryFeedCollectionViewCell *selectedCell = (StoryFeedCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:path];
            [self.delegate collectionViewCellShouldClick:selectedCell];
        }
    }];
}

- (void)setupDragView {
    [self.contentView addSubview:self.dragVibeView];
    UIView *parent = self.contentView;
    UIView *child = self.dragVibeView;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    
     // mendy [parent layoutIfNeeded];
    
    [self.dragVibeView setCurrentCompany:self.company];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewStoryCell" bundle:nil] forCellWithReuseIdentifier:@"storyCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewQuestionCell" bundle:nil] forCellWithReuseIdentifier:@"questionCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewLinkCell" bundle:nil] forCellWithReuseIdentifier:@"linkCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewMultimediaCell" bundle:nil] forCellWithReuseIdentifier:@"multimediaCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewOfficesCell" bundle:nil] forCellWithReuseIdentifier:@"officesCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCollectionViewHardFactsCell" bundle:nil] forCellWithReuseIdentifier:@"hardFactsCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCreateUserProfileCell" bundle:nil] forCellWithReuseIdentifier:@"createProfileCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedCreateUserProfileCell" bundle:nil] forCellWithReuseIdentifier:@"vibeCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedJoinCompanyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"joinCompanyCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryFeedPrivacyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"privacyCell"];
    [self setupDragView];
}

- (void)setCompany:(Company *)company {
    _company = company;
    [self setUserVibedCompany:company.userVibed];
    [self.dragVibeView setCurrentCompany:company];
    [self.companyImageView sd_cancelCurrentImageLoad];
    if (self.company.companyLogo) {
        [self.companyImageView sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo]];
    } else {
        self.companyImageView.image = nil;
    }
}

- (void)setCollectionViewDataSource:(id <UICollectionViewDataSource>)dataSource delegate:(id <UICollectionViewDelegate>)delegate {
    self.collectionView.dataSource = dataSource;
    self.collectionView.delegate = delegate;
    [self.collectionView reloadData];
    [self updateButtonsState];
}

- (void)setUserVibedCompany:(BOOL)userVibed {
    [self.companyLiked setHidden:!userVibed];
}

- (void)setUserVibedStory:(BOOL)userVibed {
    [self.dragVibeView setUserVibed:userVibed];
}

#pragma mark TTDragVibeView delegate

- (void)willBeginDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    [self.collectionView setScrollEnabled:NO];
    [self.dragVibeView.superview bringSubviewToFront:self.dragVibeView];
    [self.delegate willBeginDraggingOnStoryFeedTableViewCell:self];
}

- (void)willEndDraggingOnDragVibeView:(TTDragVibeView *)dragVibeView {
    [self.collectionView setScrollEnabled:YES];
    [self.delegate willEndDraggingOnStoryFeedTableViewCell:self];
}

- (void)profileOnDragVibeView:(TTDragVibeView *)cell {
    [self.delegate profileOnStoryFeedTableViewCell:self];
}

- (void)signupOnDragVibeView:(TTDragVibeView *)cell {
    [self.delegate signupOnStoryFeedTableViewCell:self];
}

- (void)vibeOnDragVibeView:(TTDragVibeView *)cell completion:(SimpleCompletionBlock)completion {
    /*if (![[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if (completion) {
            completion(NO, nil);
        }
        [[DataManager sharedManager] showLoginScreen];
    } else {
        if (![[DataManager sharedManager] isCVAvailable]) {
            if (completion) {
                completion(NO, nil);
            }
            [self.delegate storyFeedCellShouldMoveToUserProfile:self];
        } else {
            [self.delegate vibeOnStoryFeedTableViewCell:self completion:completion];
        }
    }*/
    [self.delegate vibeOnStoryFeedTableViewCell:self completion:completion];
}

- (void)didHideDragView:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideDragView)]) {
        [self.delegate didHideDragView];
    }
}

- (void)didTappedOnHiring:(TTDragVibeView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(hiringTappedOnCell:)]) {
        [self.delegate hiringTappedOnCell:self];
    }
}

- (void)dealloc {
    [self.companyImageView sd_cancelCurrentImageLoad];
}

@end
