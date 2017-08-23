//
//  TTActivityIndicator.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/29/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTActivityIndicator.h"
#import "UIView+Additions.h"
#import "JTMaterialSpinner.h"

#define APPEARING_DURATION 0.4f
#define ANIMATION_DURATION 0.6f
#define ANIMATION_WIDTH 70.0f

@interface TTActivityIndicator ()

@property (nonatomic, weak) IBOutlet UIView *containerView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *animationWidthConstraint;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerCenterConstraint;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerTopConstraint;
@property (nonatomic, weak) IBOutlet JTMaterialSpinner *sppinerView;
@property (nonatomic, strong) NSLayoutConstraint *centerConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;


@property (getter=isAnimating) BOOL animating;

@end

@implementation TTActivityIndicator

#pragma mark Initialization

+ (TTActivityIndicator *)activityIndicator {
    static TTActivityIndicator *activityIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activityIndicator = [TTActivityIndicator loadFromXibNamed:@"TTActivityIndicator"];
    });
    return activityIndicator;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.layer.zPosition = MAXFLOAT;
    
    self.sppinerView.circleLayer.lineWidth = 1.0;
    self.sppinerView.circleLayer.strokeColor = [UIColor colorWithRed:(0.0/255.0) green:(179.0/255.0) blue:(234.0/255.0) alpha:1.0].CGColor;
    [self bringSubviewToFront:self.sppinerView];
}

#pragma mark Appearance Controls

+ (void)showOnMainWindow {
    [TTActivityIndicator showOnMainWindowAnimated:YES];
}

+ (void)showOnMainWindowOnTop {
    [TTActivityIndicator showOnView:[[[UIApplication sharedApplication] delegate] window] animated:YES top:YES];
}

+ (void)showOnMainWindowAnimated:(BOOL)animated {
    [TTActivityIndicator showOnView:[[[UIApplication sharedApplication] delegate] window] animated:animated];
}

+ (void)showOnView:(UIView *)view {
    [TTActivityIndicator showOnView:view animated:YES];
}

+ (void)showOnView:(UIView *)view animated:(BOOL)animated {
    [TTActivityIndicator showOnView:view animated:animated top:NO];
}

+ (void)showOnView:(UIView *)view animated:(BOOL)animated top:(BOOL)top {
    [self.activityIndicator setTopMode:top];
    if (self.activityIndicator.superview) {
        if (![self.activityIndicator.superview isEqual:view]) {
            self.activityIndicator.frame = view.frame;
            [view addSubview:self.activityIndicator];
        } else {
            [view bringSubviewToFront:self.activityIndicator];
        }
    } else {
        self.activityIndicator.frame = view.frame;
        self.activityIndicator.alpha =  1.0;
        [view addSubview:self.activityIndicator];
        [UIView animateWithDuration:animated ? APPEARING_DURATION : 0.0f animations:^{
            self.activityIndicator.alpha = 1;
        } completion:^(BOOL finished) {
            [self.activityIndicator startAnimating];
        }];
    }
}

+ (void)dismiss {
    [TTActivityIndicator dismiss:YES];
}

+ (void)dismiss:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.5f : 0.0f animations:^{
        [self.activityIndicator setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.activityIndicator removeFromSuperview];
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark Animation Controls

- (void)startAnimating {
    @synchronized(self) {
        if (!_animating) {
            _animating = YES;
            [self.sppinerView beginRefreshing];
            
//            self.animationWidthConstraint.constant = ANIMATION_WIDTH;
//            [self layoutIfNeeded];
//            [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
//                self.animationWidthConstraint.constant = 0.0f;
//                [self layoutIfNeeded];
//            } completion:^(BOOL finished) {
//                
//            }];
        }
    }
}

- (void)stopAnimating {
    _animating = NO;
    [self.layer removeAllAnimations];
    [self.sppinerView endRefreshing];
}

- (void)setTopMode:(BOOL)top {
    if (top) {
        [self addConstraint:self.topConstraint];
        [self removeConstraint:self.centerConstraint];
    } else {
        [self removeConstraint:self.topConstraint];
        [self addConstraint:self.centerConstraint];
    }
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (NSLayoutConstraint *)topConstraint {
    if (!_topConstraint) {
        _topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:-32.0f];
    }
    return _topConstraint;
}

- (NSLayoutConstraint *)centerConstraint {
    if (!_centerConstraint) {
        _centerConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    }
    return _centerConstraint;
}

- (void)dealloc {
    [self stopAnimating];
}

@end
