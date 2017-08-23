//
//  TTScrollableHeaderViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 11/6/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "TTScrollableHeaderViewController.h"
#import "SVPullToRefresh.h"
#import "StoryFeedCollectionViewMultimediaCell.h"

@interface TTScrollableHeaderViewController ()  <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic) CGPoint currentContentOffset;

@property CGFloat lastContentOffset;
@end

@implementation TTScrollableHeaderViewController


#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.currentContentOffset = CGPointZero;
        self.lastContentOffset = 0.0f;
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    
}

#pragma mark Scrolling header

- (UIScrollView *)tt_scrollableView {
    return nil;
}

- (CGSize)tt_contentSize {
    return [self.tt_scrollableView contentSize];
}

- (CGPoint)tt_contentOffset {
    return [self.tt_scrollableView contentOffset];
}

#pragma mark UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tt_scrollableView]) {
        self.currentContentOffset = scrollView.contentOffset;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cancelPlayingMultimediaItems];
    if ([scrollView isEqual:self.tt_scrollableView]) {
        self.currentContentOffset = scrollView.contentOffset;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self startPlayingMultimediaItems];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self startPlayingMultimediaItems];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  //  [self startPlayingMultimediaItems];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([scrollView isEqual:self.tt_scrollableView]) {
        CGFloat targetY = (*targetContentOffset).y;
        CGFloat rowHeight = self.view.frame.size.width;
        CGFloat scrollValue = rowHeight * 0.3f;
        //CGPoint newOffset = CGPointMake(0, floor(targetY / rowHeight) * rowHeight);
        DLog(@"CURRENT OFFSET %f, TARGET %f", self.currentContentOffset.y, targetY);
        
        CGPoint newOffset = *targetContentOffset;
        
        if (self.currentContentOffset.y > targetY) {
            DLog(@"SCROLLING TO TOP");
            if (self.currentContentOffset.y - scrollValue > targetY) {
                newOffset = CGPointMake(0, (roundf(self.currentContentOffset.y / rowHeight) - (velocity.y > 2 ? 2 : 1)) * rowHeight);
                DLog(@"SHOULD SCROLL TO PREV ITEM WITH OFFSET %f", newOffset.y);
                if (newOffset.y < 0) {
                    newOffset = CGPointZero;
                }
            } else {
                newOffset = CGPointMake(0, roundf(self.currentContentOffset.y / rowHeight) * rowHeight);
                DLog(@"SHOULD RETURN TO CURRENT ITEM WITH OFFSET %f", newOffset.y);
            }
        } else if (self.currentContentOffset.y < targetY) {
            DLog(@"SCROLLING TO BOTTOM");
            if (self.currentContentOffset.y + scrollValue < targetY) {
                newOffset = CGPointMake(0, (roundf(self.currentContentOffset.y / rowHeight) + (velocity.y > 2 ? 2 : 1)) * rowHeight);
                DLog(@"SHOULD SCROLL TO NEXT ITEM WITH OFFSET %f", newOffset.y);
                
                if (newOffset.y > scrollView.contentSize.height - scrollView.frame.size.height + (scrollView.infiniteScrollingView.hidden ? 0.0f : scrollView.infiniteScrollingView.frame.size.height)) {
#warning mendy
                   // newOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height + (scrollView.infiniteScrollingView.hidden ? 0.0f : scrollView.infiniteScrollingView.frame.size.height));
                }
            } else {
                newOffset = CGPointMake(0, roundf(self.currentContentOffset.y / rowHeight) * rowHeight);
                DLog(@"SHOULD RETURN TO CURRENT ITEM WITH OFFSET %f", newOffset.y);
            }
        }
        
        *targetContentOffset = newOffset;
        scrollView.decelerationRate = 10.0;
    }
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)sender {
    CGFloat height = [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|curveOption animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, height, 0);
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|curveOption animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    } completion:nil];
}

#pragma mark Playing control

- (void)cancelPlayingMultimediaItems {
    if ([self.tt_scrollableView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.tt_scrollableView;
        [self cancelPlayingMultimediaCells:collectionView.visibleCells];
    }
}

- (void)startPlayingMultimediaItems {
    if ([self.tt_scrollableView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.tt_scrollableView;
        NSArray *sortedCellsArray = [[collectionView.visibleCells copy] sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *obj1, UICollectionViewCell *obj2) {
            if (obj1.frame.origin.y < obj2.frame.origin.y) {
                return NSOrderedAscending;
            } else if (obj1.frame.origin.y > obj2.frame.origin.y) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        if (![self respondsToSelector:@selector(startPlayingMultimediaItems)]) {
            return;
        }
        //[self startPlayingMultimediaItems];
    }
}

- (void)cancelPlayingMultimediaCells:(NSArray *)cells {
    for (UICollectionViewCell *cell in cells) {
        if ([cell isKindOfClass:[StoryFeedCollectionViewMultimediaCell class]]) {
            StoryFeedCollectionViewMultimediaCell *multimediaCell = (StoryFeedCollectionViewMultimediaCell *)cell;
            [multimediaCell didEndDisplay];
        }
    }
}

#pragma mark Gesture handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:[self.tt_scrollableView superview]];
    CGFloat delta = self.lastContentOffset - translation.y;
    
    self.lastContentOffset = translation.y;
    [self.scrollDelegate scrollableView:self.tt_scrollableView scrollWithDelta:delta onController:self];
    
    if ([gesture state] == UIGestureRecognizerStateEnded || [gesture state] == UIGestureRecognizerStateCancelled) {
        [self.scrollDelegate scrollableView:self.tt_scrollableView checkForPartialScrollonController:self];
        self.lastContentOffset = 0;
    }
}

- (void)restoreContentOffset:(CGFloat)delta {
    CGPoint offset = [self tt_contentOffset];
    if (delta > 0) {
        [self.tt_scrollableView setContentOffset:(CGPoint){offset.x, offset.y - delta - 1}];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tt_scrollableView) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.panGesture setDelegate:self];
        [self.panGesture setMaximumNumberOfTouches:1];
        [self.tt_scrollableView addGestureRecognizer:self.panGesture];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
