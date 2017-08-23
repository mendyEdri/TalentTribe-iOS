//
//  StrokeLogoWhiteIndicator.m
//  TalentTribe
//
//  Created by Mendy on 16/03/2016.
//  Copyright © 2016 TalentTribe. All rights reserved.
//

#import "StrokeColoredLogoIndicator.h"
#import "UIView+Additions.h"
#import "JTMaterialSpinner.h"

#define APPEARING_DURATION 0.4f
#define ANIMATION_DURATION 0.6f
#define ANIMATION_WIDTH 70.0f

@interface StrokeColoredLogoIndicator ()
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet JTMaterialSpinner *sppinerView;
@property (nonatomic, strong) NSLayoutConstraint *centerConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (getter=isAnimating) BOOL animating;
@end

@implementation StrokeColoredLogoIndicator

+ (StrokeColoredLogoIndicator *)strokeColoredLogoIndicator {
    static StrokeColoredLogoIndicator *strokeColoredLogoIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strokeColoredLogoIndicator = [StrokeColoredLogoIndicator loadFromXibNamed:@"StrokeColoredLogoIndicator"];
    });
    return strokeColoredLogoIndicator;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.layer.zPosition = MAXFLOAT;
    
    self.sppinerView.circleLayer.lineWidth = 1.0;
    self.sppinerView.circleLayer.strokeColor = [UIColor colorWithRed:(0.0/255.0) green:(179.0/255.0) blue:(234.0) alpha:1.0].CGColor;
    [self bringSubviewToFront:self.sppinerView];
}

#pragma mark Appearance Controls

+ (void)showOnMainWindow {
    [StrokeColoredLogoIndicator showOnMainWindowAnimated:YES];
}

+ (void)showOnMainWindowOnTop {
    [StrokeColoredLogoIndicator showOnView:[[[UIApplication sharedApplication] delegate] window] animated:YES top:YES];
}

+ (void)showOnMainWindowAnimated:(BOOL)animated {
    [StrokeColoredLogoIndicator showOnView:[[[UIApplication sharedApplication] delegate] window] animated:animated];
}

+ (void)showOnView:(UIView *)view {
    [StrokeColoredLogoIndicator showOnView:view animated:YES];
}

+ (void)showOnView:(UIView *)view animated:(BOOL)animated {
    [StrokeColoredLogoIndicator showOnView:view animated:animated top:NO];
}

+ (void)showOnView:(UIView *)view animated:(BOOL)animated top:(BOOL)top {
    [self.strokeColoredLogoIndicator setTopMode:top];
    if (self.strokeColoredLogoIndicator.superview) {
        if (![self.strokeColoredLogoIndicator.superview isEqual:view]) {
            self.strokeColoredLogoIndicator.frame = view.frame;
            [view addSubview:self.strokeColoredLogoIndicator];
        } else {
            [view bringSubviewToFront:self.strokeColoredLogoIndicator];
        }
    } else {
        self.strokeColoredLogoIndicator.frame = view.frame;
        self.strokeColoredLogoIndicator.alpha =  1.0;
        [view addSubview:self.strokeColoredLogoIndicator];
        [UIView animateWithDuration:animated ? APPEARING_DURATION : 0.0f animations:^{
            self.strokeColoredLogoIndicator.alpha = 1;
        } completion:^(BOOL finished) {
            [self.strokeColoredLogoIndicator startAnimating];
        }];
    }
}

+ (void)dismiss {
    [StrokeColoredLogoIndicator dismiss:YES];
}

+ (void)dismiss:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.5f : 0.0f animations:^{
        [self.strokeColoredLogoIndicator setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.strokeColoredLogoIndicator removeFromSuperview];
        [self.strokeColoredLogoIndicator stopAnimating];
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
