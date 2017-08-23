//
//  TTDynamicTextView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTDynamicTextView.h"

@interface TTDynamicTextView ()

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *minHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *maxHeightConstraint;

@end

@implementation TTDynamicTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    
    self.textContainer.lineFragmentPadding = 0;
    self.textContainerInset = UIEdgeInsetsZero;
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            if (constraint.relation == NSLayoutRelationEqual) {
                self.heightConstraint = constraint;
            } else if (constraint.relation == NSLayoutRelationLessThanOrEqual) {
                self.maxHeightConstraint = constraint;
            } else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual) {
                self.minHeightConstraint = constraint;
            }
        }
    }
}

- (NSLayoutConstraint *)minHeightConstraint {
    if (!_minHeightConstraint) {
        _minHeightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:CGRectGetHeight(self.frame)];
        [self addConstraint:_minHeightConstraint];
    }
    return _minHeightConstraint;
}

- (NSLayoutConstraint *)maxHeightConstraint {
    if (!_maxHeightConstraint) {
        _maxHeightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.minHeightConstraint.constant * 3];
        [self addConstraint:_maxHeightConstraint];
    }
    return _maxHeightConstraint;
}

- (CGFloat)heightForText {
    NSDictionary *attributes = @{ NSFontAttributeName: self.font};
    CGRect size = [self.text.length ? self.text : self.attributedPlaceholder.string boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    return size.size.height;
}

- (void)layoutSubviews {
    if (self.isFirstResponder) {
        CGFloat height = [self heightForText];
        if (height != self.heightConstraint.constant) {
            CGFloat newHeight = height;
            if (self.maxHeightConstraint.constant) {
                newHeight = MIN(self.maxHeightConstraint.constant, newHeight);
            }
            if (self.minHeightConstraint.constant) {
                newHeight = MAX(self.minHeightConstraint.constant, newHeight);
            }
            self.heightConstraint.constant = newHeight;
            if (self.maxHeightConstraint && height <= self.maxHeightConstraint.constant) {
                [self setContentOffset:CGPointZero animated:NO];
            }
        }
    }
    [super layoutSubviews];
}

@end
