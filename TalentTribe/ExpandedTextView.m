//
//  ExpandedTextView.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/10/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ExpandedTextView.h"

@implementation ExpandedTextView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void) awakeFromNib
{
    [self commonInit];

}

-(void) commonInit {
    // If we are using auto layouts, than get a handler to the height constraint.
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
            self.heightConstraint = constraint;
            _minHeight = self.heightConstraint.constant;
            _maxHeight = 600;
            break;
        }
    }
}


- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.scrollEnabled = NO;
    
    CGSize intrinsicSize = self.intrinsicContentSize;
    
    if (self.minHeight) {
        intrinsicSize.height = MAX(intrinsicSize.height, self.minHeight);
    }
    if (self.maxHeight) {
        intrinsicSize.height = MIN(intrinsicSize.height, self.maxHeight);
    }
    

    self.heightConstraint.constant = intrinsicSize.height;
}


- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.contentSize;
    
        CGFloat fixedWidth = self.frame.size.width;
        CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = self.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        self.frame = newFrame;
    
    intrinsicContentSize = newFrame.size;
    
    return intrinsicContentSize;

}


@end
