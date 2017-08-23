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

typedef enum {
    VibeStateNone,
    VibeStateRunning,
    VibeStateSuccess,
    VibeStateFailed
} VibeState;

NSInteger circleViewTag = 999;
NSInteger imageViewTag = 998;

@interface TTDragVibeView () <DNDDragSourceDelegate, DNDDropTargetDelegate, TTTouchImageViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *dragContainer;

@property (nonatomic, weak) IBOutlet UIView *dragTargetView;

@property (nonatomic, weak) IBOutlet UIImageView *rotationView;

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) DNDDragAndDropController *dragController;

@property BOOL animating;
@property BOOL dragging;
@property BOOL dragActionStarted;

@property VibeState vibeState;
@property (nonatomic, strong) DNDDragOperation *dragOperation;

@end

@implementation TTDragVibeView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.vibeState = VibeStateNone;
        self.dragging = NO;
        self.dragActionStarted = NO;
        self.animating = NO;
        self.dragController = [[DNDDragAndDropController alloc] initWithView:self];
        self.enabled = YES;
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.dragContainer insertSubview:self.blurView atIndex:0];
    [self.vibeButton setDelegate:self];
    
    [self.dragController registerDragSource:self.vibeButton withDelegate:self];
    [self.dragController registerDropTarget:self.dragTargetView withDelegate:self];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.blurView.frame = self.bounds;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.dragging || self.dragActionStarted || CGRectContainsPoint(self.vibeButton.frame, point)) {
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
    [self.vibeButton setImage:[UIImage imageNamed:vibed ? @"vibe_company_s" : @"vibe_company"]];
    [self setEnabled:!vibed];
}

#pragma mark TTTouchImageView delegate

- (void)touchedTTTouchImageView:(TTTouchImageView *)imageView {
    if (self.dragging) {
        [self endDragging];
    } else {
        [self beginDragging];
    }
}

- (void)touchEndedTTTouchImageView:(TTTouchImageView *)imageView {
    if (!self.dragActionStarted) {
        [self endDragging];
    }
}

#pragma mark Dragging

- (void)beginDragging {
    @synchronized(self) {
        if (!self.dragging) {
            self.dragging = YES;
            DLog(@"BEGIN DRAGGING");
            [self.delegate willBeginDraggingOnDragVibeView:self];
            [self showDragViewAnimated:YES completion:nil];
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
        }
    }
}

#pragma mark Show hide drag view

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

- (void)showDragViewAnimationHandlerAnimated:(BOOL)animated innerAnimations:(void(^)(void))animations completion:(void(^)(void))completion {
    if (animated) {
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

#pragma mark - Drag Source Delegate

- (UIView *)draggingViewForDragOperation:(DNDDragOperation *)operation {
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.vibeButton.bounds];
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMake((CGRectGetWidth(self.vibeButton.bounds) - self.vibeButton.image.size.width) / 2.0f + 2.0f - CGRectGetHeight(self.vibeButton.bounds) / 2.0f, 2.0f - CGRectGetHeight(self.vibeButton.bounds) / 2.0f, CGRectGetHeight(self.vibeButton.bounds) * 2.0f, CGRectGetHeight(self.vibeButton.bounds) * 2.0f))];
    circleView.layer.masksToBounds = YES;
    circleView.layer.cornerRadius = circleView.bounds.size.width / 2.0f;
    circleView.layer.backgroundColor = UIColorFromRGBA(0xffffff, 0.2f).CGColor;
    circleView.tag = circleViewTag;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.vibeButton.bounds];
    imageView.contentMode = UIViewContentModeRight;
    imageView.image = self.vibeButton.image;
    imageView.tag = imageViewTag;
    
    [containerView addSubview:circleView];
    [containerView addSubview:imageView];
    
    return containerView;
}

- (void)dragOperationWillStart:(DNDDragOperation *)operation {
    self.dragActionStarted = YES;
    [self beginDragging];
    [self.vibeButton setAlpha:0.0f];
}

- (void)dragOperationWillCancel:(DNDDragOperation *)operation {
    self.dragActionStarted = NO;
    [operation removeDraggingViewAnimatedWithDuration:0.2 animations:^(UIView *draggingView) {
        //draggingView.alpha = 0.0f;
        draggingView.center = [operation convertPoint:self.vibeButton.center fromView:self];
    } completion:^{
        self.vibeButton.alpha = 1.0f;
    }];
    [self endDragging];
}

- (void)dragOperation:(DNDDragOperation *)operation willMoveToPosition:(CGPoint)position {
    CGFloat totalDistance = fabs(self.dragTargetView.center.y - operation.dragSourceView.center.y);
    CGFloat currentDistance = fabs(self.dragTargetView.center.y - position.y);
    
    CGFloat transform = MAX(1.0f, MIN(1.25f, 1.0 + 0.25 * (totalDistance - currentDistance) / totalDistance));
    
    operation.draggingView.transform = CGAffineTransformMakeScale(transform, transform);
}

#pragma mark - Drop Target Delegate

- (void)dragOperation:(DNDDragOperation *)operation didDropInDropTarget:(UIView *)target {
    
}

- (void)dragOperation:(DNDDragOperation *)operation didEnterDropTarget:(UIView *)target {
    @synchronized(self) {
        if (!self.animating) {
            self.animating = YES;
            
            self.dragOperation = operation;
            
            [self.dragController cancelCurrentDragOperation];
            
            [UIView animateWithDuration:0.3f animations:^{
                [[operation.draggingView viewWithTag:circleViewTag] setAlpha:0.0f];
                operation.draggingView.center = CGPointMake(self.dragTargetView.center.x + 4, self.dragTargetView.center.y - 3);
            }];
            
            [UIView animateWithDuration:0.1f animations:^{
                target.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1f animations:^{
                    target.transform = CGAffineTransformIdentity;
                }];
            }];
            
            [self performRotationAnimation];
            
            self.vibeState = VibeStateRunning;
            [self.delegate vibeOnDragVibeView:self completion:^(BOOL success, NSError *error) {
                self.vibeState = success ? VibeStateSuccess : VibeStateFailed;
            }];
        }
    }
}

- (void)performRotationAnimation {
    self.rotationView.hidden = NO;
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.rotationView setTransform:CGAffineTransformRotate(self.rotationView.transform, M_PI_2)];
    } completion:^(BOOL finished) {
        if (self.vibeState == VibeStateRunning) {
            [self performRotationAnimation];
        } else {
            [self handleVibeCompletionWithOperation:self.dragOperation];
        }
    }];
}

- (void)handleVibeCompletionWithOperation:(DNDDragOperation *)operation {
    self.rotationView.hidden = YES;
    if (self.vibeState == VibeStateSuccess) {
        UIImage *vibeImage = [UIImage imageNamed:@"vibe_company_s"];
        UIImageView *imageView = (UIImageView *)[operation.draggingView viewWithTag:imageViewTag];
        [imageView setImage:vibeImage];
        operation.draggingView.center = CGPointMake(self.dragTargetView.center.x, self.dragTargetView.center.y - 2);
        [self.vibeButton setImage:vibeImage];
    }
    [self hideDragViewAnimationHandlerAnimated:YES innerAnimations:^{
        operation.draggingView.center = self.vibeButton.center;
        operation.draggingView.transform = CGAffineTransformIdentity;
    } completion:^{
        [operation removeDraggingView];
        [self.delegate willEndDraggingOnDragVibeView:self];
        self.vibeButton.alpha = 1.0f;
        self.animating = NO;
        self.dragging = NO;
        self.dragActionStarted = NO;
    }];
}

#pragma mark Dealloc

- (void)dealloc {
    self.dragOperation = nil;
    self.vibeState = VibeStateNone;
    [self.layer removeAllAnimations];
    [self.rotationView.layer removeAllAnimations];
    [self removeAllObservations];
}

@end
