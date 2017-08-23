//
//  TTDragVibeView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/20/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTDragVibeView.h"
#import "TTTouchImageView.h"
#import <DNDDragAndDrop/DNDDragAndDrop.h>
#import "NSObject+MTKObserving.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataManager.h"
#import "User.h"
#import "Mixpanel.h"

#define kFirstVibeDate @"vibeDate"

typedef enum {
    VibeStateNone,
    VibeStateRunning,
    VibeStateSuccess,
    VibeStateFailed
} VibeState;

NSInteger circleViewTag = 999;
NSInteger imageViewTag = 998;

@interface TTDragVibeView () <DNDDragSourceDelegate, DNDDropTargetDelegate, TTTouchImageViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet TTTouchImageView *vibeButton;
@property (nonatomic, weak) IBOutlet TTTouchImageView *hiringButton;
@property (nonatomic, weak) IBOutlet UIImageView *dragCompanyImageView;
@property (nonatomic, weak) IBOutlet UILabel *dragCompanyLabel;
@property (nonatomic, weak) IBOutlet UILabel *likeVibeLabel;
@property (nonatomic, weak) IBOutlet UILabel *likeHeaderTitle;

@property (nonatomic, weak) IBOutlet UIView *dragContainer;

@property (nonatomic, weak) IBOutlet UIView *dragTargetView;

@property (nonatomic, weak) IBOutlet UIImageView *rotationView;

@property (nonatomic, weak) IBOutlet UILabel *hereLabel;

@property (nonatomic, weak) IBOutlet UIImageView *arrowView;

@property (nonatomic, weak) IBOutlet UIView *infoContainer;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *insideHolderView;

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) DNDDragAndDropController *dragController;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topMarginConstraint;
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIView *doneView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@property BOOL dragEnabled;
@property BOOL newDesign;
@property BOOL followViewEnabled;

@property BOOL openPositionsChecked;
@property BOOL newStoriesChecked;

@property BOOL animating;
@property BOOL dragging;
@property BOOL dragActionStarted;

@property VibeState vibeState;
@property (nonatomic, strong) DNDDragOperation *dragOperation;

@property (nonatomic, strong) NSTimer *dismissTimer;

@end

@implementation TTDragVibeView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.vibeState = VibeStateNone;
        self.dragging = NO;
        self.dragActionStarted = NO;
        self.animating = NO;
        //self.dragController = [[DNDDragAndDropController alloc] init];
        //[self.dragController registerDragSource:self withDelegate:self];
        //[self.dragController registerDropTarget:self withDelegate:self];
        
        self.emailTextField.delegate = self;
        self.enabled = YES;
        self.newDesign = NO;
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.vibeButton setDelegate:self];
    [self.hiringButton setDelegate:self];
    self.emailTextField.delegate = self;
    
    UITapGestureRecognizer *tap = self.vibeButton.gestureRecognizers[0];
    tap.numberOfTapsRequired = 5;
    [tap addTarget:self action:@selector(unlikeVibe)];
    
    
    self.infoContainer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.infoContainer.alpha = 0.0;
    
    self.doneView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.doneView.alpha = 0.0;
    
    self.followButton.layer.cornerRadius = CGRectGetHeight(self.followButton.bounds) / 2;
    self.openPositionsChecked = YES;
    self.newStoriesChecked = YES;
    
    self.vibeButton.frame = CGRectMake(CGRectGetMinX(self.vibeButton.frame), CGRectGetMinY(self.vibeButton.frame), 72, 72);
    
    self.dragEnabled = NO;
    if (self.dragEnabled) {
        [self.dragController registerDragSource:self.vibeButton withDelegate:self];
        [self.dragController registerDropTarget:self.dragTargetView withDelegate:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.blurView.frame = self.bounds;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performDismissingWithSuccess:NO completion:nil];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.followViewEnabled || self.dragging || self.dragActionStarted || CGRectContainsPoint(self.vibeButton.frame, point) || CGRectContainsPoint(self.hiringButton.frame, point)) {
        return YES;
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.userInteractionEnabled = enabled;
}

- (void)setUserVibed:(BOOL)vibed {
    _userVibed = vibed;
    [self.vibeButton setImage:[UIImage imageNamed:vibed ? @"red_heart" : @"heart"]];
    //[self setEnabled:!vibed];
    UIGestureRecognizer *gesture = [self.vibeButton.gestureRecognizers lastObject];
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        gesture.enabled = !vibed;
        return;
    }
    gesture.enabled = vibed;
}

- (void)likeVibe {
    self.containerView.hidden = !self.containerView.isHidden;
    self.insideHolderView.hidden = !self.insideHolderView.isHidden;
}

- (void)unlikeVibe {
    if (![self.delegate respondsToSelector:@selector(unlikeVibeOnDragView:)]) {
        return;
    }
    [self.delegate unlikeVibeOnDragView:self];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Interface actions

- (IBAction)cancelVibePressed:(id)sender {
    [[Mixpanel sharedInstance] track:kLikeVibeCanceled properties:@{
                                                            kUserFirstVibe : @([self isFirstVibeAction]),
                                                            @"Company" : self.currentCompany.companyName
                                                }];
    [self performDismissingWithSuccess:NO completion:nil];
    self.followViewEnabled = NO;
}

- (IBAction)continueVibePressed:(id)sender {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if ([[[DataManager sharedManager] currentUser] isProfileMinimumFilled]) {
            [self performVibeActionWithCompletion:nil];
        } else {
            [self performDismissingWithSuccess:NO completion:^{
                [self.delegate profileOnDragVibeView:self];
            }];
        }
    } else {
        [self performDismissingWithSuccess:NO completion:^{
            [self.delegate signupOnDragVibeView:self];
        }];
    }
}

- (void)setLikeTop:(BOOL)top companyProfile:(BOOL)companyProfile {
    self.topConstraint.constant = top ? companyProfile ? 24 : 4 : 40;
    self.topMarginConstraint.constant = top ? companyProfile ? 20 : 0 : 40;
}

#pragma mark Performing vibe

- (IBAction)follow:(id)sender {
    if (![DataManager validateEmail:self.emailTextField.text]) {
        [self showErrorView];
        return;
    }
    [[Mixpanel sharedInstance].people set:@{@"$user_email": self.emailTextField.text}];
    [[Mixpanel sharedInstance] track:kNewVibeTapped properties:@{
                                                                 @"Company" : self.currentCompany.companyName,
                                                                 @"UDID": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                                                                 @"UserEmail": self.emailTextField.text
                                                                 }];
    
    [[DataManager sharedManager] followCompanyWithData:@{
                                                        @"email": self.emailTextField.text,
                                                        @"companyId": self.currentCompany.companyId,
                                                        @"isNewPositions": @(self.openPositionsChecked),
                                                        @"isNewStories": @(self.newStoriesChecked)
    } completion:^(BOOL success, NSError *error) {
        if (error.code == 200) {
            DLog(@"Success: %d", success);
            [[NSUserDefaults standardUserDefaults] setObject:self.emailTextField.text forKey:@"userEmail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showDoneView];
        } else if (error) {
            [self showErrorView];
        }
    }];
}

- (void)performVibeActionManually {
    [self.delegate willBeginDraggingOnDragVibeView:self];
    [self performVibeActionWithCompletion:^{
        [self.delegate willEndDraggingOnDragVibeView:self];
    }];
}

- (void)animateManually {
    [self beginDragging];
}

- (void)performVibeActionWithCompletion:(void(^)(void))completion {
    @synchronized(self) {
        static BOOL vibe = NO;
        if (!vibe) {
            vibe = YES;
            [TTActivityIndicator showOnView:self];
            self.vibeState = VibeStateRunning;
            [self.delegate vibeOnDragVibeView:self completion:^(BOOL success, NSError *error) {
                if (success) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[NSDate date] forKey:kFirstVibeDate];
                    [defaults synchronize];
                }
                [self performDismissingWithSuccess:success completion:^{
                    [TTActivityIndicator dismiss];
                    vibe = NO;
                    if (completion) {
                        completion();
                    }
                }];
            }];
        }
    }
}

- (void)performDismissingWithSuccess:(BOOL)success completion:(void(^)(void))completion {
    self.vibeState = success ? VibeStateSuccess : VibeStateFailed;
    [self setUserVibed:success];
    [self hideInfoViewAnimated:YES completion:^{
        [self.delegate willEndDraggingOnDragVibeView:self];
        self.animating = NO;
        self.dragging = NO;
        self.dragActionStarted = NO;
        if (completion) {
            completion();
        }
    }];
    [self.emailTextField resignFirstResponder];
    self.followViewEnabled = NO;
}

- (void)showDoneView {
    self.messageLabel.text = @"You got it!";
    [self.doneView setAlpha:0.0f];
    [self.doneView setHidden:NO];
    [UIView animateWithDuration:0.3f animations:^{
        [self.doneView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.doneView setAlpha:0.0f];
            [self.doneView setHidden:YES];
            [self performDismissingWithSuccess:YES completion:nil];
        });
    }];
    [self.emailTextField resignFirstResponder];
}

- (void)showErrorView {
    self.messageLabel.text = @"Something went wrong.";
    [self.doneView setAlpha:0.0f];
    [self.doneView setHidden:NO];
    [UIView animateWithDuration:0.3f animations:^{
        [self.doneView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.doneView setAlpha:0.0f];
            [self.doneView setHidden:YES];
        });
    }];
}

- (void)showLikeTitleLabel:(BOOL)show {
    self.likeHeaderTitle.hidden = !show;
}

- (void)hideHiringButton:(BOOL)hide {
    self.hiringButton.hidden = hide;
}

#pragma mark TTTouchImageView delegate

- (void)touchedTTTouchImageView:(TTTouchImageView *)imageView {
    /*if (self.dragging) {
        [self endDragging];
    } else {
        [self beginDragging];
    }*/
    
    // check if like or hiring tapped.
    if (self.hiringButton == imageView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnHiring:)]) {
            [self.delegate didTappedOnHiring:self];
        }
        return;
    }
    
    self.followViewEnabled = YES;
    [self beginDragging];
}

- (void)touchEndedTTTouchImageView:(TTTouchImageView *)imageView {
    if (!self.dragActionStarted) {
        [[Mixpanel sharedInstance] track:kLikeVibe properties:@{
                                                                kUserFirstVibe : @([self isFirstVibeAction]),
                                                                @"Company" : self.currentCompany.companyName
                                                                }];
        
        if (self.dragEnabled) {
            [self showArrowAnimated:YES];
        }
        [self scheduleDismissTimer];
    }
}

#pragma mark Dismiss timer

- (void)scheduleDismissTimer {
    [self invalidateDismissTimer];
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(dismissTimerFired) userInfo:nil repeats:NO];
}

- (void)invalidateDismissTimer {
    if (self.dismissTimer) {
        if ([self.dismissTimer isValid]) {
            [self.dismissTimer invalidate];
        }
    }
    self.dismissTimer = nil;
}

- (void)dismissTimerFired {
    [self endDragging];
}

#pragma mark Dragging

- (void)beginDragging {
    @synchronized(self) {
        if (!self.dragging && !self.userVibed && ![DataManager sharedManager].likeOpen) {
            self.dragging = YES;
            DLog(@"BEGIN DRAGGING");
            [DataManager sharedManager].likeOpen = YES;
            [self.delegate willBeginDraggingOnDragVibeView:self];
            if (self.dragEnabled) {
                //[self showDragViewAnimated:YES completion:nil];
                [self showInfoViewAnimated:YES completion:nil];
                return;
            }
            [self showDragViewAnimated:YES completion:^{
                self.animating = YES;
                [self performRotationAnimation];
            }];
        }
    }
}

- (void)endDragging {
    @synchronized(self) {
        if (self.dragging) {
            DLog(@"END DRAGGING");
            [self.delegate willEndDraggingOnDragVibeView:self];
            [self hideDragViewAnimated:YES completion:^{
                self.dragging = NO;
            }];
            [self invalidateDismissTimer];
        }
    }
}

- (void)hideVibeView {
    [self.delegate willEndDraggingOnDragVibeView:self];
    [self hideDragViewAnimated:YES completion:^{
        [self hideInfoViewAnimated:YES completion:^{
            self.dragging = NO;
        }];
    }];
    [self invalidateDismissTimer];
}

#pragma mark Show arrow

- (void)showArrowAnimated:(BOOL)animated {
    if (self.arrowView.hidden) {
        self.arrowView.alpha = 0.0f;
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:animated ? 0.3f : 0.0f animations:^{
            self.arrowView.alpha = 1.0f;
        }];
    }
}

#pragma mark Show hide drag view

- (void)showContainerViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            [self showContainerViewAnimationHandlerAnimated:animated innerAnimations:nil completion:^{
                self.animating = NO;
                if (completion) {
                    completion();
                }
            }];
        } else {
            [self observeProperty:@"animating" withBlock:^(__weak id self, NSNumber *old, NSNumber *newVal) {
                if (newVal && !newVal.boolValue) {
                    if (self) {
                        [self removeAllObservations];
                        [self showContainerViewAnimated:animated completion:completion];
                    }
                }
            }];
        }
    }
}


- (void)showDragViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            [self showDragViewAnimationHandlerAnimated:animated innerAnimations:nil completion:^{
                self.animating = NO;
                if (completion) {
                    completion();
                }
            }];
        } else {
            [self observeProperty:@"animating" withBlock:^(__weak id self, NSNumber *old, NSNumber *newVal) {
                if (newVal && !newVal.boolValue) {
                    if (self) {
                        [self removeAllObservations];
                        [self showDragViewAnimated:animated completion:completion];
                    }
                }
            }];
        }
    }
}

- (void)showContainerViewAnimationHandlerAnimated:(BOOL)animated innerAnimations:(void(^)(void))animations completion:(void(^)(void))completion {
    if (animated) {
        [self prepareForAppearing];
        [self.infoContainer setAlpha:0.0f];
        [self.infoContainer setHidden:NO];
        [UIView animateWithDuration:0.3f animations:^{
            [self.infoContainer setAlpha:1.0f];
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [self.infoContainer setAlpha:1.0f];
        [self.infoContainer setHidden:NO];
        if (animations) {
            animations();
        }
        if (completion) {
            completion();
        }
    }
}

- (void)showDragViewAnimationHandlerAnimated:(BOOL)animated innerAnimations:(void(^)(void))animations completion:(void(^)(void))completion {
    if (animated) {
        [self prepareForAppearing];
        [self.dragContainer setAlpha:0.0f];
        [self.dragContainer setHidden:NO];
        [UIView animateWithDuration:0.3f animations:^{
            [self.dragContainer setAlpha:1.0f];
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [self.dragContainer setAlpha:1.0f];
        [self.dragContainer setHidden:NO];
        if (animations) {
            animations();
        }
        if (completion) {
            completion();
        }
    }
}

- (void)hideDragViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            [self hideDragViewAnimationHandlerAnimated:animated innerAnimations:nil completion:^{
                self.animating = NO;
                if (completion) {
                    completion();
                }
            }];
        } else {
            [self observeProperty:@"animating" withBlock:^(__weak id self, NSNumber *old, NSNumber *newVal) {
                if (newVal && !newVal.boolValue) {
                    if (self) {
                        [self removeAllObservations];
                        [self hideDragViewAnimated:animated completion:completion];
                    }
                }
            }];
        }
    }
}

- (void)hideDragViewAnimationHandlerAnimated:(BOOL)animated innerAnimations:(void(^)(void))animations completion:(void(^)(void))completion {
    if (animated) {
        [self prepareForDisappearing];
        [UIView animateWithDuration:0.3f animations:^{
            [self.dragContainer setAlpha:0.0f];
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            [self.dragContainer setHidden:YES];
            if (completion) {
                completion();
            }
        }];
    } else {
        [self.dragContainer setHidden:YES];
        if (animations) {
            animations();
        }
        if (completion) {
            completion();
        }
    }
}

#pragma mark Appearing and disappearing handling

- (void)prepareForAppearing {
    [self.dragContainer insertSubview:self.blurView atIndex:0];
    self.vibeButton.alpha = 0.0;
    [self.arrowView setHidden:![self isFirstVibeAction]];
    self.hereLabel.hidden = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"]) {
        self.emailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
    }
    
    [self.dragCompanyImageView sd_setImageWithURL:[NSURL URLWithString:self.currentCompany.companyLogo]];
    [self.dragCompanyLabel setText:self.currentCompany.companyName];
    [self.followButton setTitle:[NSString stringWithFormat:@"Follow %@", self.currentCompany.companyName.length > 0 ? self.currentCompany.companyName : @""] forState:UIControlStateNormal];
}

- (void)prepareForDisappearing {
    
}

#pragma mark - Drag Source Delegate

- (UIView *)draggingViewForDragOperation:(DNDDragOperation *)operation {
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.vibeButton.bounds];
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    //UIView *circleView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMake((CGRectGetWidth(self.vibeButton.bounds) - self.vibeButton.image.size.width) / 2.0f + 2.0f - CGRectGetHeight(self.vibeButton.bounds) / 2.0f, 2.0f - CGRectGetHeight(self.vibeButton.bounds) / 2.0f, CGRectGetHeight(self.vibeButton.bounds) * 2.0f, CGRectGetHeight(self.vibeButton.bounds) * 2.0f))];
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMake(0.0f, 0.0f, CGRectGetHeight(self.vibeButton.bounds) * 2.0f, CGRectGetHeight(self.vibeButton.bounds) * 2.0f))];
    circleView.center = CGPointMake(ceil(containerView.frame.size.width / 2.0f), ceil(containerView.frame.size.width / 2.0f));
    circleView.layer.masksToBounds = YES;
    circleView.layer.cornerRadius = circleView.bounds.size.width / 2.0f;
    circleView.layer.backgroundColor = UIColorFromRGBA(0xffffff, 0.2f).CGColor;
    circleView.tag = circleViewTag;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.vibeButton.bounds];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = self.vibeButton.image;
    imageView.tag = imageViewTag;
    
    [containerView addSubview:circleView];
    [containerView addSubview:imageView];
    
    return containerView;
}

- (void)dragOperationWillStart:(DNDDragOperation *)operation {
    [[Mixpanel sharedInstance] track:kVibeAnimateStart properties:@{
                                                                    kUserRegisterd : @([DataManager sharedManager].isCredentialsSavedInKeychain),
                                                                    kUserCompleted : @(![self isUserIncomplete]),
                                                                    @"Company" : self.currentCompany.companyName
                                                                    }];
    self.dragActionStarted = YES;
    [self beginDragging];
    [self.vibeButton setAlpha:0.0f];
    [self invalidateDismissTimer];
}

- (void)dragOperationWillCancel:(DNDDragOperation *)operation {
    [[Mixpanel sharedInstance] track:kVibeAnimateCanceld properties:@{
                                                                      kUserRegisterd : @([DataManager sharedManager].isCredentialsSavedInKeychain),
                                                                      kUserCompleted : @(![self isUserIncomplete]),
                                                                      @"Company" : self.currentCompany.companyName
                                                                      }];
    self.dragActionStarted = NO;
    [operation removeDraggingViewAnimatedWithDuration:0.2 animations:^(UIView *draggingView) {
        draggingView.center = [operation convertPoint:self.vibeButton.center fromView:self];
        self.vibeButton.alpha = 1.0f;
    }];
//    [operation removeDraggingViewAnimatedWithDuration:0.2 animations:^(UIView *draggingView) {
//        //draggingView.alpha = 0.0f;
//        draggingView.center = [operation convertPoint:self.vibeButton.center fromView:self];
//    } completion:^{
//        self.vibeButton.alpha = 1.0f;
//    }];
    [self endDragging];
}

- (void)dragOperation:(DNDDragOperation *)operation willMoveToPosition:(CGPoint)position {
    CGFloat totalDistance = fabs(self.dragTargetView.center.y - operation.dragSourceView.center.y);
    CGFloat currentDistance = fabs(self.dragTargetView.center.y - position.y);
    
    CGFloat transform = MAX(1.0f, MIN(1.25f, 1.0 + 0.25 * (totalDistance - currentDistance) / totalDistance));
    
    operation.draggingView.transform = CGAffineTransformMakeScale(transform, transform);
}

#pragma mark - UIGestureRequgnize Delegate



#pragma mark - Drop Target Delegate

- (void)dragOperation:(DNDDragOperation *)operation didDropInDropTarget:(UIView *)target {
    
}

- (void)dragOperation:(DNDDragOperation *)operation didEnterDropTarget:(UIView *)target {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            
            self.dragOperation = operation;
            
            //[self.dragController cancelCurrentDragOperation];
            
            [UIView animateWithDuration:0.3f animations:^{
                [[operation.draggingView viewWithTag:circleViewTag] setAlpha:0.0f];
                operation.draggingView.center = CGPointMake(self.dragTargetView.center.x + 20, self.dragTargetView.center.y - 3);
            }];
            
            [UIView animateWithDuration:0.1f animations:^{
                target.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1f animations:^{
                    target.transform = CGAffineTransformIdentity;
                }];
            }];
            
            [self performRotationAnimation];
        }
    }
}

- (void)performRotationAnimation {
    self.rotationView.hidden = NO;
    [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.rotationView setTransform:CGAffineTransformRotate(self.rotationView.transform, M_PI_2)];
    } completion:^(BOOL finished) {
        [self handleVibeCompletionWithOperation:self.dragOperation];
    }];
}

- (void)handleVibeCompletionWithOperation:(DNDDragOperation *)operation {
    [operation removeDraggingView];
    self.vibeButton.alpha = 1.0f;
    if ([self isFirstVibeAction] || [self isUserIncomplete]) {
        [self presentInfoViewAnimated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *vibeImage = [UIImage imageNamed:@"red_heart"];
            UIImageView *imageView = (UIImageView *)[operation.draggingView viewWithTag:imageViewTag];
            [imageView setImage:vibeImage];
            operation.draggingView.center = CGPointMake(self.dragTargetView.center.x, self.dragTargetView.center.y - 2);
            [self.vibeButton setImage:vibeImage];
        });
        [self performVibeActionWithCompletion:nil];
    }
    [self hideDragViewAnimationHandlerAnimated:YES innerAnimations:^{
        operation.draggingView.center = self.vibeButton.center;
        operation.draggingView.transform = CGAffineTransformIdentity;
    } completion:^{
        self.rotationView.hidden = YES;
    }];
}

- (void)presentInfoViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    NSString *baseString = [NSString stringWithFormat:@"Cool. Your profile will be\nshared with %@", self.currentCompany.companyName];
    NSString *additionalString;
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        if ([[[DataManager sharedManager] currentUser] isProfileMinimumFilled]) {
            [self.nextButton setTitle:@"OK" forState:UIControlStateNormal];
        } else {
            additionalString = @"Hey, your profile is empty...";
            [self.nextButton setTitle:@"Apply" forState:UIControlStateNormal];
        }
    } else {
        additionalString = @"Hey, need a bit more info...";
        [self.nextButton setTitle:@"Apply" forState:UIControlStateNormal];
    }

    if (additionalString) {
        self.infoLabel.text = [NSString stringWithFormat:@"%@\n\n%@", baseString, additionalString];
    } else {
        self.infoLabel.text = baseString;
    }
    
    //[self.infoContainer insertSubview:self.blurView atIndex:0];
    [self.infoContainer setAlpha:0.0f];
    [self.infoContainer setHidden:NO];
    [UIView animateWithDuration:0.0f animations:^{
        [self.infoContainer setAlpha:1.0f];
        if (completion) {
            completion();
        }
    }];
}

- (void)showInfoViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    [UIView animateWithDuration:0.3f animations:^{
        [self.infoContainer setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [self.infoContainer setHidden:YES];
        [DataManager sharedManager].likeOpen = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didHideDragView:)]) {
            [self.delegate didHideDragView:self];
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)hideInfoViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    [UIView animateWithDuration:0.3f animations:^{
        [self.infoContainer setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.infoContainer setHidden:YES];
        [DataManager sharedManager].likeOpen = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didHideDragView:)]) {
            [self.delegate didHideDragView:self];
        }
        if (completion) {
            completion();
        }
    }];
}

- (IBAction)jobOpeningChecked:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.openPositionsChecked = !sender.isSelected;
    
    NSLog(@"sender.selected %d", sender.selected);
    
    [[Mixpanel sharedInstance] track:kFollowPositionCheck properties:@{
                                                                       @"checked": @(!sender.selected),
                                                                       @"Company" : self.currentCompany.companyName,
                                                                       @"UDID": [[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                                    }];
}

- (IBAction)newStoriesChecked:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.newStoriesChecked = !sender.isSelected;
    
    [[Mixpanel sharedInstance] track:kFollowStoriesCheck properties:@{
                                                                       @"checked": @(!sender.selected),
                                                                       @"Company" : self.currentCompany.companyName,
                                                                       @"UDID": [[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                                    }];
}

#pragma mark Misc

- (BOOL)isFirstVibeAction {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFirstVibeDate] ? NO : YES;
}

- (BOOL)isFirstVibeActionOnCompany {
    return ![self.currentCompany userVibed];
}

- (BOOL)isUserIncomplete {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        User *currentUser = [[DataManager sharedManager] currentUser];
        return ![currentUser isProfileMinimumFilled];
    } else {
        return YES;
    }
}

#pragma mark Dealloc

- (void)dealloc {
    self.dragOperation = nil;
    self.vibeState = VibeStateNone;
    [self.layer removeAllAnimations];
    [self.rotationView.layer removeAllAnimations];
    [self.dragCompanyImageView sd_cancelCurrentImageLoad];
    [self removeAllObservations];
    [self invalidateDismissTimer];
}

@end
