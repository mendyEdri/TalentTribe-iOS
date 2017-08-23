//
//  SearchController.m
//  Testing
//
//  Created by Mendy on 07/02/2016.
//  Copyright © 2016 Mendy. All rights reserved.
//

#import "SearchController.h"
#import "SearchResultsViewController.h"
#import "Story.h"
#import "Company.h"
#import "DataManager.h"

@interface SearchController () <UISearchBarDelegate, SearchBarDelegate>
@property (strong, nonatomic) SearchResultsViewController *list;
@property (nonatomic, strong) NSOperationQueue *searchOperationQueue;
@property (nonatomic, strong) UIViewController *parent;
@property (nonatomic, strong) UIViewController *searchController;
@end

static CGFloat const searchHeight = 44.0;
static CGFloat const statusBar = 20.0;
static CGFloat const searchPadding = 10.0;
#define kCompanies @"Companies"
#define kStories @"Stories"
#define kCategoriesTags @"Categories"

@implementation SearchController

+ (void)searchControllerWithSearchResult:(UIViewController *)searchResultsController onController:(UIViewController *)viewController withCompletion:(SimpleResultBlock)completion {
    static SearchController *searchController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        searchController = [[SearchController alloc] initWithSearchResultsController:searchResultsController onController:viewController];
    });
    if (completion) {
        completion(searchController, nil);
    }
}

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController onController:(UIViewController *)viewController {
    self = [super initWithSearchResultsController:searchResultsController];
    if (self) {
        self.customSearchBar = [[SearchBar alloc] init];
        self.customSearchBar.placeholder = @"Search";
        self.customSearchBar.delegate = self;
        self.customSearchBar.searchBarDelegate = self;
        
        self.parent = viewController;
        self.searchController = searchResultsController;
        
        self.list = (SearchResultsViewController *)self.searchController;
        [self.parent addChildViewController:self.searchController];
        self.list.view.frame = CGRectMake(0, searchHeight + statusBar + searchPadding, CGRectGetWidth(self.searchController.view.bounds), CGRectGetHeight(self.searchController.view.bounds) - (searchHeight + statusBar + searchPadding));
        [self.parent.view addSubview:self.list.view];
        [self.parent.view addSubview:self.customSearchBar];
        [self.customSearchBar sizeToFit];
        self.list.view.hidden = YES;
        
        self.searchOperationQueue = [[NSOperationQueue alloc] init];
        [self.searchOperationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.customSearchBar resignFirstResponder];
    [self.customSearchBar becomeFirstResponder];
}

- (void)searchTextChanged:(NSString *)searchString completion:(SimpleResultBlock)completion {
    @synchronized(self) {
        [self.searchOperationQueue cancelAllOperations];
        if (searchString.length) {
            [self showIndicator:YES];
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            DLog(@"Start %f", time);
            [self.searchOperationQueue addOperationWithBlock:^{
                [self.searchOperationQueue setSuspended:YES];
                [[DataManager sharedManager] quickSearchWithText:searchString completion:^(id result, NSError *error) {
                    [self.searchOperationQueue setSuspended:NO];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        double end = [[NSDate date] timeIntervalSince1970] - time;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(end < 1.0 ? 1.0 - (end) : 0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self showIndicator:NO];
                        });
                    });
                    if (completion) {
                        completion(result, error);
                    }
                }];
            }];
        } else {
            completion(nil, [NSError errorWithDomain:@"com.talenttribe" code:200 userInfo:@{NSLocalizedDescriptionKey : @"Can't search without text"}]);
        }
    }
}

#pragma mark - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!self.searchDelegate || ![self.searchDelegate respondsToSelector:@selector(didStartSearching)]) {
        return;
    }
    
    NSLog(@"Result View Controller %@", self.searchResultsController);
    self.list.view.hidden = NO;
    [self.list showInitialData:searchBar.text.length ? NO : YES];
    [self.list reloadData];
    [self.list hideTableView:NO];
    [self.searchDelegate didStartSearching];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.customSearchBar resignFirstResponder];
    if (!self.searchDelegate || ![self.searchDelegate respondsToSelector:@selector(didTapOnSearchButton)]) {
        return;
    }
    [self.searchDelegate didTapOnSearchButton];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.customSearchBar resignFirstResponder];
    if (!self.searchDelegate || ![self.searchDelegate respondsToSelector:@selector(didTapOnCancelButton)]) {
        return;
    }
    [self.list hideTableView:YES];
    self.list.view.hidden = YES;
    [self.searchDelegate didTapOnCancelButton];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    DLog(@"");
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
}

#pragma mark - SearchBar Custome Delegate

- (void)searchBarDidClear {
    self.list.showInitialData = YES;
    [self.list updateStories:nil companies:nil categories:nil];
}

- (void)searchBarDidChangeTextWithText:(NSString *)searchText {
    if (!self.searchDelegate || ![self.searchDelegate respondsToSelector:@selector(didChangeSearchText:)]) {
        return;
    }
    [self.list showInitialData:searchText.length ? NO : YES];
    [self.list reloadData];
    [self searchTextChanged:searchText completion:^(id result, NSError *error) {
        if (result && !error) {
            [self.list updateStories:result[kStories] companies:result[kCompanies] categories:result[kCategoriesTags]];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.list updateStories:nil companies:nil categories:nil];
                [self.list reloadData];
            });
        }
    }];
    [self.searchDelegate didChangeSearchText:searchText];
}

- (void)updateTrending:(NSArray *)trending {
    self.list.initialDataContiner = trending;
}

- (void)showIndicator:(BOOL)show {
    [self.customSearchBar showIndicator:show];
}

- (void)dismissSearchController {
    [self searchBarCancelButtonClicked:self.customSearchBar];
}

@end
