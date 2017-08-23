//
//  InsetTableView.m
//  SlideTest
//
//  Created by Bogdan Andresyuk on 5/5/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "InsetTableView.h"
#import <objc/runtime.h>

@interface InsetTableView () {
    BOOL shouldManuallyLayoutHeaderViews;
}

- (void) layoutHeaderViews;

@end

@implementation InsetTableView

@synthesize headerViewInsets;

#pragma mark -
#pragma mark Super

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if(shouldManuallyLayoutHeaderViews)
        [self layoutHeaderViews];
}

#pragma mark -
#pragma mark Self

- (void) setHeaderViewInsets:(UIEdgeInsets)_headerViewInsets
{
    headerViewInsets = _headerViewInsets;
    
    shouldManuallyLayoutHeaderViews = !UIEdgeInsetsEqualToEdgeInsets(headerViewInsets, UIEdgeInsetsZero);
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Private

- (void) layoutHeaderViews
{
    const NSUInteger numberOfSections = self.numberOfSections;
    const UIEdgeInsets contentInset = self.contentInset;
    const CGPoint contentOffset = self.contentOffset;
    
    const CGFloat sectionViewMinimumOriginY = contentOffset.y + contentInset.top + headerViewInsets.top;
    
    //	Layout each header view
    for(NSUInteger section = 0; section < numberOfSections; section++)
    {
        UIView* sectionView = [self headerViewForSection:section];
        
        if(sectionView == nil)
            continue;
        
        const CGRect sectionFrame = [self rectForSection:section];
        
        CGRect sectionViewFrame = sectionView.frame;
        
        sectionViewFrame.origin.y = ((sectionFrame.origin.y < sectionViewMinimumOriginY) ? sectionViewMinimumOriginY : sectionFrame.origin.y);
        
        //	If it's not last section, manually 'stick' it to the below section if needed
        if(section < numberOfSections - 1)
        {
            const CGRect nextSectionFrame = [self rectForSection:section + 1];
            
            if(CGRectGetMaxY(sectionViewFrame) > CGRectGetMinY(nextSectionFrame))
                sectionViewFrame.origin.y = nextSectionFrame.origin.y - sectionViewFrame.size.height;
        }
        
        [sectionView setFrame:sectionViewFrame];
    }
 }

@end
