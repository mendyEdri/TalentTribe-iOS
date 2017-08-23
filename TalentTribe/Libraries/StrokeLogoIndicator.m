//
//  StrokeLogoIndicator.m
//  TalentTribe
//
//  Created by Mendy on 15/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "StrokeLogoIndicator.h"
#import "UIView+Additions.h"
#import "JTMaterialSpinner.h"

#define APPEARING_DURATION 0.4f
#define ANIMATION_DURATION 0.6f
#define ANIMATION_WIDTH 70.0f

@interface StrokeLogoIndicator ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet JTMaterialSpinner *sppinerView;
@property (nonatomic, strong) NSLayoutConstraint *centerConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;

@property (getter=isAnimating) BOOL animating;
@end

@implementation StrokeLogoIndicator

+ (StrokeLogoIndicator *)strokeIndicator {
    static StrokeLogoIndicator *strokeIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strokeIndicator = [StrokeLogoIndicator loadFromXibNamed:@"StrokeLogoIndicator"];
    });
    return strokeIndicator;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.layer.zPosition = MAXFLOAT;
    
    self.sppinerView.circleLayer.lineWidth = 1.0;
    self.sppinerView.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self bringSubviewToFront:self.sppinerView];
}

#pragma mark Appearance Controls

+ (void)showOnMainWindow {
    [StrokeLogoIndicator showOnMainWindowAnimated:YES];
}

+ (void)showOnMainWindowOnTop {
    [StrokeLogoIndicator showOnView:[[[UIApplication sharedApplication] delegate] window] animated:YES top:YES];
}

+ (void)showOnMainWindowAnimated:(BOOL)animated {
    [StrokeLogoIndicator showOnView:[[[UIApplication sharedApplication] delegate] window] animated:animated];
}

+ (void)showOnView:(UIView *)view {
    [StrokeLogoIndicator showOnView:view animated:YES];
}

+ (void)showOnView:(UIView *)view animated:(BOOL)animated {
    [StrokeLogoIndicator showOnView:view animated:animated top:NO];
}

+ (void)showOnView:(UIView *)view animated:(BOOL)animated top:(BOOL)top {
    [self.strokeIndicator setTopMode:top];
    if (self.strokeIndicator.superview) {
        if (![self.strokeIndicator.superview isEqual:view]) {
            self.strokeIndicator.frame = view.frame;
            [view addSubview:self.strokeIndicator];
        } else {
            [view bringSubviewToFront:self.strokeIndicator];
        }
    } else {
        self.strokeIndicator.frame = view.frame;
        self.strokeIndicator.alpha =  1.0;
        [view addSubview:self.strokeIndicator];
        [UIView animateWithDuration:animated ? APPEARING_DURATION : 0.0f animations:^{
            self.strokeIndicator.alpha = 1;
        } completion:^(BOOL finished) {
            [self.strokeIndicator startAnimating];
        }];
    }
}

+ (void)dismiss {
    [StrokeLogoIndicator dismiss:YES];
}

+ (void)dismiss:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.5f : 0.0f animations:^{
        [self.strokeIndicator setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.strokeIndicator removeFromSuperview];
        [self.strokeIndicator stopAnimating];
    }];
}

#pragma mark Animation Controls

- (void)startAnimating {
    @synchronized(self) {
        if (!_animating) {
            _animating = YES;
            [self.sppinerView beginRefreshing];
        }
    }
}

- (void)stopAnimating {
    _animating = NO;
    [self.layer removeAllAnimations];
    [self.sppinerView endRefreshing];
}

- (void)setTopMode:(BOOL)top {
//    if (top) {
//        [self addConstraint:self.topConstraint];
//        [self removeConstraint:self.centerConstraint];
//    } else {
//        [self removeConstraint:self.topConstraint];
//        [self addConstraint:self.centerConstraint];
//    }
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
