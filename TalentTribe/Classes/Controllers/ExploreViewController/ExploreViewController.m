//
//  ExploreViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ExploreViewController.h"
#import "ExploreTableViewCell.h"
#import "ExploreCollectionViewCell.h"
#import "ExploreSearchBar.h"
#import "UIView+Additions.h"
#import "SVPullToRefresh.h"
#import "DataManager.h"
#import "StoryCategory.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "StoryFeedViewController.h"
#import "FilterViewController.h"
#import "SearchController.h"
#import "SearchResultsViewController.h"
#import "StoryFeedYAxisViewController.h"
#import "SearchResultsFeedViewController.h"

@interface ExploreViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, SearchControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *fixedViewContainer;
@property (nonatomic, weak) IBOutlet UIView *trendingView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *separatorHeight;

@property (nonatomic, strong) NSLayoutConstraint *fullAspectConstraint;
@property (nonatomic, strong) NSLayoutConstraint *halfAspectConstraint;

//@property (nonatomic, strong) ExploreSearchBar *searchBar;

//@property (nonatomic, strong) NSMutableArray *fixedContainer;
//@property (nonatomic, strong) NSMutableArray *trendingContainer;
@property (strong, nonatomic) FilterViewController *filterVC;


@property NSInteger currentCategoryPage;
@property BOOL categoryLoading;

@property (nonatomic, strong) NSOperationQueue *searchOperationQueue;

@property (nonatomic, strong) SearchController *searchController;
@end

@implementation ExploreViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.searchOperationQueue = [[NSOperationQueue alloc] init];
        [self.searchOperationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    if ([DataManager sharedManager].fixedArray.count == 0 && [DataManager sharedManager].trendingArray.count == 0) {
        [self hideViews:YES];
        [TTActivityIndicator showOnView:self.view];
        [self.tableView.infiniteScrollingView setEnabled:NO];
    } else if ([DataManager sharedManager].fixedArray.count > 2) {
        [self.fixedViewContainer removeConstraint:self.halfAspectConstraint];
        [self.fixedViewContainer addConstraint:self.fullAspectConstraint];
    } else {
        [self.fixedViewContainer removeConstraint:self.fullAspectConstraint];
        [self.fixedViewContainer addConstraint:self.halfAspectConstraint];
    }
    [self.fixedViewContainer layoutIfNeeded];
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            self.currentCategoryPage = 0;
            [self.tableView reloadData];
            [self.collectionView reloadData];
            [[DataManager sharedManager] exploreCategoriesForPage:self.currentCategoryPage count:EXPLORE_DEFAULT_PAGE_SIZE completionHandler:^(id result, NSError *error) {
                [self hideViews:NO];
                if (result && !error) {
                    NSDictionary *resultDict = (NSDictionary *)result;
                    NSArray *fixedArray = [resultDict objectForKeyOrNil:kFixedCategories];
                    if (fixedArray) {
                        if (![DataManager sharedManager].fixedArray) {
                            [DataManager sharedManager].fixedArray = [[NSMutableArray alloc] init];
                        } else {
                            [[DataManager sharedManager].fixedArray removeAllObjects];
                        }
                        [[DataManager sharedManager].fixedArray addObjectsFromArray:fixedArray];
                        if (fixedArray.count > 2) {
                            [self.fixedViewContainer removeConstraint:self.halfAspectConstraint];
                            [self.fixedViewContainer addConstraint:self.fullAspectConstraint];
                        } else {
                            [self.fixedViewContainer removeConstraint:self.fullAspectConstraint];
                            [self.fixedViewContainer addConstraint:self.halfAspectConstraint];
                        }
                        [self.fixedViewContainer layoutIfNeeded];
                    }
                    NSArray *trendingArray = [resultDict objectForKeyOrNil:kTrendingCategories];
                    if (trendingArray) {
                        if (![DataManager sharedManager].trendingArray) {
                            [DataManager sharedManager].trendingArray = [[NSMutableArray alloc] init];
                        } else {
                            [[DataManager sharedManager].trendingArray removeAllObjects];
                        }
                        [[DataManager sharedManager].trendingArray addObjectsFromArray:trendingArray];
                        [self.searchController updateTrending:trendingArray];
                    }

                    /*NSArray *trendingArray = @[[[StoryCategory alloc] initWithDictionary:@{@"categoryName" : @"Women in Tech", @"showAlways" : @(NO)}],
                                               [[StoryCategory alloc] initWithDictionary:@{@"categoryName" : @"The coolest in-house cafeterias", @"showAlways" : @(NO)}],
                                               [[StoryCategory alloc] initWithDictionary:@{@"categoryName" : @"New product releases", @"showAlways" : @(NO)}],
                                               [[StoryCategory alloc] initWithDictionary:@{@"categoryName" : @"Secondary “exits” for employees", @"showAlways" : @(NO)}],
                                               [[StoryCategory alloc] initWithDictionary:@{@"categoryName" : @"This week most popular Q&As", @"showAlways" : @(NO)}]];
                    [self.trendingContainer addObjectsFromArray:trendingArray];*/
                    
                    [self.collectionView reloadData];
                    [self.tableView reloadData];
                    self.tableView.hidden = NO;
                    [self.tableView.infiniteScrollingView setEnabled:([DataManager sharedManager].trendingArray.count == EXPLORE_DEFAULT_PAGE_SIZE)];
                } else {
                    //handle error
                }
                [TTActivityIndicator dismiss];
                loading = NO;
            }];
        }
    }
}

- (void)loadPage:(NSInteger)page {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        [[DataManager sharedManager] exploreCategoriesForPage:page count:EXPLORE_DEFAULT_PAGE_SIZE completionHandler:^(id result, NSError *error) {
            if (result && !error) {
                self.currentCategoryPage = page;
                NSDictionary *resultDict = (NSDictionary *)result;
                NSArray *trendingArray = [resultDict objectForKeyOrNil:kTrendingCategories];
                if (trendingArray) {
                    [self.tableView beginUpdates];
                    NSInteger count = [DataManager sharedManager].trendingArray.count;
                    NSMutableArray *indexPaths = [NSMutableArray new];
                    for (NSInteger index = 0; index < trendingArray.count; index++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:count + index inSection:0]];
                    }
                    [[DataManager sharedManager].trendingArray addObjectsFromArray:trendingArray];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    [self.tableView.infiniteScrollingView setEnabled:(trendingArray.count == EXPLORE_DEFAULT_PAGE_SIZE)];
                }
            } else {
                //handle error
            }
            [[self.tableView infiniteScrollingView] stopAnimating];
            loading = NO;
        }];
    }
}

- (void)filterPressed {
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:self.filterVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (FilterViewController *)filterVC {
    if(!_filterVC) {
        _filterVC = [FilterViewController new];
    }
    return _filterVC;
}

#pragma mark Appearance handling

- (NSLayoutConstraint *)fullAspectConstraint {
    if (!_fullAspectConstraint) {
        _fullAspectConstraint = [NSLayoutConstraint constraintWithItem:self.fixedViewContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.fixedViewContainer attribute:NSLayoutAttributeHeight multiplier:(32.0f / 22.0f) constant:0.0f];
    }
    return _fullAspectConstraint;
}

- (NSLayoutConstraint *)halfAspectConstraint {
    if (!_halfAspectConstraint) {
        _halfAspectConstraint = [NSLayoutConstraint constraintWithItem:self.fixedViewContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.fixedViewContainer attribute:NSLayoutAttributeHeight multiplier:(32.0f / 11.0f) constant:0.0f];
    }
    return _halfAspectConstraint;
}

#pragma mark Search handling 

- (void)searchTextChanged:(UITextField *)textField {
    @synchronized(self) {
        [self.searchOperationQueue cancelAllOperations];
        NSString *searchText = textField.text;
        if (searchText.length) {
            [self.searchOperationQueue addOperationWithBlock:^{
                [self.searchOperationQueue setSuspended:YES];
                [[DataManager sharedManager] quickSearchForText:searchText withLimit:25 andType:QuickSearchCategory completionHandler:^(id result, NSError *error) {
                    [self.searchOperationQueue setSuspended:NO];
                }];
            }];
        } else {
            
        }
    }
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataManager sharedManager].trendingArray.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExploreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    StoryCategory *category = [[DataManager sharedManager].trendingArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = category.categoryName;
    return cell;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StoryCategory *category = [[DataManager sharedManager].trendingArray objectAtIndex:indexPath.row];
    [self presentStoryFeedForStoryCategory:category];
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [DataManager sharedManager].fixedArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ExploreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    StoryCategory *category = [[DataManager sharedManager].fixedArray objectAtIndex:indexPath.row];
    
    if (category.categoryName) {
        cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:category.categoryName attributes:@{NSFontAttributeName : cell.titleLabel.font, NSForegroundColorAttributeName : cell.titleLabel.textColor}];
    }
    
    if (category.categoryLogo.length) {
        cell.backgroundImageView.backgroundColor = [UIColor clearColor];
        [cell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:category.categoryLogo]];
    } else {
        CGFloat hue = ( arc4random() % 256 / 256.0 );
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];

        cell.backgroundImageView.backgroundColor = color;
    }
       
    return cell;
}

#pragma mark UICollectionView flowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat width = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumLineSpacing) / 2;
    CGFloat height = (collectionView.bounds.size.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom - flowLayout.minimumInteritemSpacing) / (([DataManager sharedManager].fixedArray.count > 2) ? 2 : 1);
    return CGSizeMake(width, height);
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    StoryCategory *category = [[DataManager sharedManager].fixedArray objectAtIndex:indexPath.row];
    [self presentStoryFeedForStoryCategory:category];
}

#pragma mark StoryFeed presentation

- (void)presentStoryFeedForStoryCategory:(StoryCategory *)storyCategory {
    if (storyCategory) {
        SearchResultsFeedViewController *results = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsFeedViewController"];
        [results setSelectedCategory:storyCategory];
        [self.navigationController pushViewController:results animated:YES];
        
        /*
        StoryFeedViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"storyFeedViewController"];
        [controller setSelectedCategory:storyCategory];
        [self.navigationController pushViewController:controller animated:YES];
        */
        
        /*
        StoryFeedYAxisViewController *storyFeed = [self.storyboard instantiateViewControllerWithIdentifier:@"storyFeedYAxisViewController"];
        storyFeed.selectedCategory = storyCategory;
        [self.navigationController pushViewController:storyFeed animated:YES];
         */
    }
}

/*- (void)updateSearchBarAlpha:(CGFloat)alpha animated:(BOOL)animated {
    if (alpha > 0.0f) {
        self.searchBar.alpha = 0.0f;
        [self.navigationController.navigationBar addSubview:self.searchBar];
    }
    [UIView animateWithDuration:animated ? 0.3f : 0.0f animations:^{
        self.searchBar.alpha = alpha;
    } completion:^(BOOL finished) {
        if (alpha == 0.0f) {
            [self.searchBar removeFromSuperview];
        }
    }];
}*/

- (void)hideViews:(BOOL)hide {
    self.trendingView.hidden = hide;
    self.tableView.hidden = hide;
    self.fixedViewContainer.hidden = hide;
    self.searchController.customSearchBar.hidden = hide;
}

#pragma mark - SearchContoller Delegate

- (void)didStartSearching {
    NSLog(@"didStartSearching");
}

- (void)didTapOnSearchButton {
    NSLog(@"didTapOnSearchButton");
}

- (void)didTapOnCancelButton {
    NSLog(@"didTapOnCancelButton");
}

- (void)didChangeSearchText:(NSString *)searchText {
    NSLog(@"** UPDATED ** %@", searchText);
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.separatorHeight.constant = 1.0f / [[UIScreen mainScreen] scale];
    //self.searchBar.frame = self.navigationController.navigationBar.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kLogedInNotification object:nil];
    
    /*self.searchBar = [ExploreSearchBar loadFromXib];
    [self.searchBar.searchField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.searchBar.filterButton addTarget:self action:@selector(filterPressed) forControlEvents:UIControlEventTouchUpInside];
    */
    
    [self reloadData];
    
    [self.fixedViewContainer addConstraint:self.halfAspectConstraint];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self loadPage:self.currentCategoryPage + 1];
    }];

    SearchResultsViewController *resultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsViewController"];
    [SearchController searchControllerWithSearchResult:resultViewController onController:self withCompletion:^(id result, NSError *error) {
        self.searchController = result;
        self.searchController.searchDelegate = self;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (void)dealloc {
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeExplore];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
