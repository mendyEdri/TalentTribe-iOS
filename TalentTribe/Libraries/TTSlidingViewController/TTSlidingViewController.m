//
//  TTSlidingViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/5/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTSlidingViewController.h"

CGFloat selectionViewHeight = 3.0f;

@interface TTSlidingModel : NSObject

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UIView <TTSlidingView> *menuView;

@end

@implementation TTSlidingModel

@end

@interface NSArray(TTSlidingModel)

- (TTSlidingModel *)modelForMenuView:(UIView *)menuView;
- (TTSlidingModel *)modelForMenuView:(UIView *)menuView index:(NSInteger *)index;

@end

@implementation NSArray(TTSlidingModel)

- (TTSlidingModel *)modelForMenuView:(UIView *)menuView {
    return [self modelForMenuView:menuView index:nil];
}

- (TTSlidingModel *)modelForMenuView:(UIView *)menuView index:(NSInteger *)index {
    NSInteger idx = 0;
    for (TTSlidingModel *model in self) {
        if ([model.menuView isEqual:menuView]) {
            *index = idx;
            return model;
        }
        idx++;
    }
    return nil;
}

@end

@interface TTSlidingCollectionViewMenuCell : UICollectionViewCell

@property (nonatomic, strong) UIView *menuView;

@end

@implementation TTSlidingCollectionViewMenuCell

- (void)setMenuView:(UIView *)menuView {
    if (_menuView) {
        [_menuView removeFromSuperview];
        _menuView = nil;
    }
    _menuView = menuView;
    
    [menuView removeConstraints:menuView.constraints];
    
    UIView *parent = self.contentView;
    UIView *child = menuView;
    [child setTranslatesAutoresizingMaskIntoConstraints:NO];
    [parent addSubview:child];
    
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[child]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(child)]];
    [parent layoutIfNeeded];
}

@end

@interface TTSlidingCollectionViewContentCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController *viewController;

- (void)setChildViewController:(UIViewController *)child parent:(UIViewController *)parent;

@end

@implementation TTSlidingCollectionViewContentCell

- (void)setChildViewController:(UIViewController *)child parent:(UIViewController *)parent {
    if (self.viewController && [self.viewController isEqual:child]) {
        // do nothing
    } else {
        if (self.viewController) {
            [self.viewController willMoveToParentViewController:nil];
            [self.viewController.view removeFromSuperview];
            [self.viewController removeFromParentViewController];
            self.viewController = nil;
        }
        UIView *childView = child.view;

        childView.frame = self.contentView.bounds;
        
        void (^append)(void) = ^{
            [child willMoveToParentViewController:parent];
            [parent addChildViewController:child];
            [self.contentView addSubview:childView];
            [child didMoveToParentViewController:parent];
        };
        
        if (child.isViewLoaded && child.view.window) {
            append();
        } else {
            [child viewWillAppear:YES];
            append();
            [child viewDidAppear:YES];
        }
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(childView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(childView)]];
        [self.contentView layoutIfNeeded];
        
        self.viewController = child;
    }
}

@end

@interface TTSlidingViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *menuCollectionView;
@property (nonatomic, strong) UICollectionView *contentCollectionView;

@property (nonatomic, strong) UIView *selectionView;

@property (nonatomic, strong) NSMutableArray *models;

@property (nonatomic, strong) NSLayoutConstraint *menuHeightConstraint;

@property BOOL didTapMenu;
@property BOOL dragging;
@property CGPoint lastContentOffset;

@end

@implementation TTSlidingViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self.menuCollectionView addSubview:self.selectionView];
    self.menuEdgeInsets = UIEdgeInsetsZero;
    self.menuSpacing = 10.0f;
    self.currentSelectedIndex = NSNotFound;
    self.didTapMenu = NO;
    self.dragging = NO;
    self.lastContentOffset = CGPointZero;
    self.maxNumberOfMenuItemsOnScreen = 0;
}

#pragma mark Custom getters

- (UICollectionView *)menuCollectionView {
    if (!_menuCollectionView) {
        UICollectionView *collectionView = [self defaultCollectionView];
        [collectionView registerClass:[TTSlidingCollectionViewMenuCell class] forCellWithReuseIdentifier:@"cell"];
        _menuCollectionView = collectionView;
    }
    return _menuCollectionView;
}

- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionView *collectionView = [self defaultCollectionView];
        [collectionView setPagingEnabled:YES];
        [collectionView registerClass:[TTSlidingCollectionViewContentCell class] forCellWithReuseIdentifier:@"cell"];
        _contentCollectionView = collectionView;
    }
    return _contentCollectionView;
}

- (UICollectionView *)defaultCollectionView {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setSectionInset:UIEdgeInsetsZero];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [collectionView setShowsHorizontalScrollIndicator:NO];
    [collectionView setShowsVerticalScrollIndicator:NO];
    return collectionView;
}

- (UIView *)selectionView {
    if (!_selectionView) {
        UIView *selectionView = [[UIView alloc] init];
        [selectionView setBackgroundColor:[UIColor whiteColor]];
        _selectionView = selectionView;
    }
    return _selectionView;
}

#pragma mark Custom setters

- (void)setMenuEdgeInsets:(UIEdgeInsets)menuEdgeInsets {
    _menuEdgeInsets = menuEdgeInsets;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self.menuCollectionView collectionViewLayout];
    [flowLayout setSectionInset:menuEdgeInsets];
    [flowLayout invalidateLayout];
}

#pragma mark Data reloading

- (void)reloadData {
    if ([self.dataSource respondsToSelector:@selector(heightForMenuInSlidingViewController:)]) {
        self.menuHeightConstraint.constant = [self.dataSource heightForMenuInSlidingViewController:self];
        [self.view layoutIfNeeded];
    }
    
    NSMutableArray *models = [NSMutableArray new];
    NSInteger numberOfItems = [self.dataSource numberOfItemsInSlidingViewController:self];
    
    CGFloat sumItemsWidth = 0.0;
    
    for (NSInteger index = 0; index < numberOfItems; index++) {
        TTSlidingModel *model = [TTSlidingModel new];
        model.viewController = [self.dataSource slidingViewController:self viewControllerAtIndex:index];
        model.menuView = [self.dataSource slidingViewController:self viewForMenuItemAtIndex:index];
        [model.menuView setSelected:NO];
        CGFloat vInset = self.menuEdgeInsets.bottom +  self.menuEdgeInsets.top;
        if ((vInset + model.menuView.frame.size.height) < self.menuHeightConstraint.constant) {
            model.menuView.frame = CGRectMake(0, 0, CGRectGetWidth(model.menuView.frame), self.menuHeightConstraint.constant - vInset);
            sumItemsWidth += CGRectGetWidth(model.menuView.frame);
        }
        [models addObject:model];
    }
    
    self.models = models;
    
    if (self.maxNumberOfMenuItemsOnScreen != 0) {
        CGFloat width = self.menuCollectionView.frame.size.width;
        if (width - self.menuEdgeInsets.left - self.menuEdgeInsets.right < sumItemsWidth + self.menuSpacing * (numberOfItems - 1)) {
            self.maxNumberOfMenuItemsOnScreen = 0;
        } else {
            CGFloat spacing = floor((width - sumItemsWidth - self.menuEdgeInsets.left - self.menuEdgeInsets.right) / (numberOfItems - 1));
            self.menuSpacing = spacing;
        }
    }
    
    [self.contentCollectionView reloadData];
    [self.menuCollectionView reloadData];
    
    [self selectItemAtIndex:self.currentSelectedIndex animated:NO completion:nil];
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.menuCollectionView]) {
        TTSlidingCollectionViewMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        return cell;
    } else {
        TTSlidingCollectionViewContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark UICollectionViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    TTSlidingModel *model = [self.models objectAtIndex:indexPath.row];
    if ([collectionView isEqual:self.menuCollectionView]) {
        CGRect frame = model.menuView.frame;
        return CGSizeMake(floor(frame.size.width), floor(MIN(collectionView.frame.size.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom - flowLayout.minimumInteritemSpacing, frame.size.height)));
    } else {
        return CGSizeMake(floor(collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumLineSpacing), floor(collectionView.frame.size.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom - flowLayout.minimumInteritemSpacing));
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([collectionView isEqual:self.menuCollectionView]) {
        return self.menuSpacing;
    } else {
        return 0.0f;
    }
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.menuCollectionView]) {
        TTSlidingModel *model = [self.models objectAtIndex:indexPath.row];
        [model.menuView setSelected:NO];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.menuCollectionView]) {
        BOOL shouldSelect = YES;
        if ([self.delegate respondsToSelector:@selector(slidingViewController:shouldSelectItemAtIndex:)]) {
            shouldSelect = [self.delegate slidingViewController:self shouldSelectItemAtIndex:indexPath.row];
        }
        return shouldSelect;
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TTSlidingModel *model = [self.models objectAtIndex:indexPath.row];
    if ([collectionView isEqual:self.menuCollectionView]) {
        TTSlidingCollectionViewMenuCell *menuCell = (TTSlidingCollectionViewMenuCell *)cell;
        [menuCell setMenuView:model.menuView];
    } else {
        TTSlidingCollectionViewContentCell *contentCell = (TTSlidingCollectionViewContentCell *)cell;
        [contentCell setChildViewController:model.viewController parent:self];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.menuCollectionView]) {
        self.didTapMenu = YES;
        [self.view setUserInteractionEnabled:NO];
        [self selectItemAtIndex:indexPath.row animated:YES completion:^{
            [self.view setUserInteractionEnabled:YES];
            self.didTapMenu = NO;
            if (self.delegate) {
                [self.delegate slidingViewController:self didSelectItemAtIndex:indexPath.row];
            }
        }];
    }
}

#pragma mark Content size updating

- (void)updateContentSize {
    [self.menuCollectionView.collectionViewLayout invalidateLayout];
    [self.contentCollectionView.collectionViewLayout invalidateLayout];
}

#pragma mark UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.contentCollectionView]) {
        self.dragging = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:self.contentCollectionView]) {
        if (!decelerate) {
            self.dragging = NO;
            if (!self.didTapMenu) {
                [self updateCurrentIndex];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.contentCollectionView]) {
        self.dragging = NO;
        if (!self.didTapMenu) {
            [self updateCurrentIndex];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.contentCollectionView]) {
        if (!self.didTapMenu) {
            [self syncContentWithMenu];
        }
    }
}

- (void)updateCurrentIndex {
    @synchronized(self) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentSelectedIndex inSection:0];
        UICollectionViewLayoutAttributes *contentAttributes = [self.contentCollectionView layoutAttributesForItemAtIndexPath:indexPath];
        NSInteger index = self.contentCollectionView.contentOffset.x / contentAttributes.frame.size.width;
        [self.view setUserInteractionEnabled:NO];
        [self selectItemAtIndex:index animated:YES completion:^{
            [self.view setUserInteractionEnabled:YES];
        }];
    }
}

- (void)syncContentWithMenu {
    UICollectionView *ccv = self.contentCollectionView;
    UICollectionView *mcv = self.menuCollectionView;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentSelectedIndex inSection:0];
    
    UICollectionViewLayoutAttributes *contentAttributes = [ccv layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *menuAttributes = [mcv layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect menuFrame = menuAttributes.frame;
    
    CGFloat progress = (ccv.contentOffset.x - contentAttributes.frame.size.width * self.currentSelectedIndex) / ccv.frame.size.width;
    
    if ((ccv.contentOffset.x <= ccv.contentSize.width - ccv.frame.size.width) && (ccv.contentOffset.x >= 0)) {
        NSInteger nextMenuIndex = self.currentSelectedIndex;
        if (ccv.contentOffset.x >= self.lastContentOffset.x) {
            if (progress > 0) {
                nextMenuIndex = self.currentSelectedIndex + 1;
            } else if (progress < 0) {
                nextMenuIndex = self.currentSelectedIndex;
            }
        } else {
            if (progress > 0) {
                nextMenuIndex = self.currentSelectedIndex;
            } else if (progress < 0) {
                nextMenuIndex = self.currentSelectedIndex - 1;
            }
        }
        
        UICollectionViewLayoutAttributes *nextMenuAttributes = [mcv layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:nextMenuIndex inSection:0]];
        CGRect nextMenuFrame = nextMenuAttributes.frame;
        
        CGFloat newOrigin;
        CGFloat newWidth;
        
        static CGFloat lastDeltaOrigin = 0.0f;
        static CGFloat lastDeltaWidth = 0.0f;
        
        if (!CGRectEqualToRect(nextMenuFrame, menuFrame)) {
            lastDeltaOrigin = nextMenuFrame.origin.x - menuFrame.origin.x;
            lastDeltaWidth = nextMenuFrame.size.width - menuFrame.size.width;
            newOrigin = menuFrame.origin.x + lastDeltaOrigin * fabs(progress);
            newWidth = menuFrame.size.width + lastDeltaWidth * fabs(progress);
        } else {
            newOrigin = nextMenuFrame.origin.x + lastDeltaOrigin * fabs(progress);
            newWidth = nextMenuFrame.size.width + lastDeltaWidth * fabs(progress);
        }
        
        [self.selectionView setFrame:CGRectIntegral(CGRectMake(newOrigin, self.selectionView.frame.origin.y, newWidth, self.selectionView.frame.size.height))];
    }
    self.lastContentOffset = self.contentCollectionView.contentOffset;
}

#pragma mark Selection

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void(^)(void))completion {
    if (index >= 0 && index < self.models.count) {
        TTSlidingModel *model = [self.models objectAtIndex:index];
        [model.menuView setSelected:YES];
        
        if (self.currentSelectedIndex != NSNotFound && (self.currentSelectedIndex != index)) {
            TTSlidingModel *currentModel = [self.models objectAtIndex:self.currentSelectedIndex];
            [currentModel.menuView setSelected:NO];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        void (^animationBlock)(void) = ^{
            UICollectionViewLayoutAttributes *attributes = [self.menuCollectionView layoutAttributesForItemAtIndexPath:indexPath];
            CGRect frame = [attributes frame];
            [self.selectionView setFrame:CGRectMake(frame.origin.x, CGRectGetMaxY(frame) - selectionViewHeight, frame.size.width, selectionViewHeight)];
            if (!animated) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.menuCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
                    [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
                });
            } else {
                [self.menuCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
                [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f animations:^{
                animationBlock();
            } completion:^(BOOL finished) {
                self.currentSelectedIndex = index;
                if (completion) {
                    completion();
                }
            }];
        } else {
            animationBlock();
            self.currentSelectedIndex = index;
            if (completion) {
                completion();
            }
        }
    } else {
        if (completion) {
            completion();
        }
    }
}

#pragma mark Constraints

- (void)setupConstraints {
    UIView *parentView = self.view;
    UIView *menuView = self.menuCollectionView;
    UIView *contentView = self.contentCollectionView;
    
    [self.view addSubview:self.menuCollectionView];
    [self.view addSubview:self.contentCollectionView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(parentView, menuView, contentView);

    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[menuView]|" options:0 metrics:nil views:views]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[menuView]-(0)-[contentView]|" options:0 metrics:nil views:views]];
    
    self.menuHeightConstraint = [NSLayoutConstraint constraintWithItem:menuView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
    [menuView addConstraint:self.menuHeightConstraint];
    
    [parentView layoutIfNeeded];
}

#pragma mark View lifeCycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateContentSize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setupConstraints];
}

@end
