//
//  FilterListTableViewController.m
//  TalentTribe
//
//  Created by Anton Vilimets on 7/21/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "FilterListViewController.h"
#import "FilterCell.h"
#import "FilterItem.h"
#import "StoryCategory.h"
#import "Company.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "TTActivityIndicator.h"

@interface FilterListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataContainer;
@property NSInteger currentPage;

@end

@implementation FilterListViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnView:self.view];
            self.currentPage = 0;
            self.dataContainer = [NSMutableArray new];
            [self loadPage:self.currentPage completion:^{
                loading = NO;
                [TTActivityIndicator dismiss];
            }];
        }
    }
}

- (void)loadPage:(NSInteger)page completion:(void(^)(void))completion {
    static BOOL loading = NO;
    if (!loading) {
        loading = YES;
        
        void (^handleCompletion)(NSArray *result, NSError *error) = ^(NSArray *result, NSError *error) {
            if (result && !error) {
                self.currentPage = page;
                NSInteger count = self.dataContainer.count;
                if (count == 0) {
                    [self.dataContainer addObjectsFromArray:result];
                    [self.tableView reloadData];
                } else {
                    [self.tableView beginUpdates];
                    NSMutableArray *indexPaths = [NSMutableArray new];
                    for (NSInteger index = 0; index < result.count; index++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:count + index inSection:0]];
                    }
                    [self.dataContainer addObjectsFromArray:result];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
                [self.tableView.infiniteScrollingView setEnabled:(result.count == FILTER_DEFAULT_PAGE_SIZE)];
            }
            [[self.tableView infiniteScrollingView] stopAnimating];
            loading = NO;
                        if (completion) {
                completion();
            }
        };
        
        void (^handleResult)(id result, NSError *error) = ^(id result, NSError *error) {
            if (result && !error) {
                NSMutableArray *filterItems = [NSMutableArray new];
                NSArray *resultArray = (NSArray *)result;
                
                for (id resultItem in resultArray) {
                    FilterItem *filterItem = [[FilterItem alloc] init];
                    filterItem.itemType = self.filterType;
                    if ([resultItem isKindOfClass:[Company class]]) {
                        Company *company = (Company *)resultItem;
                        filterItem.itemTitle = company.companyName;
                    } else if ([resultItem isKindOfClass:[StoryCategory class]]) {
                        StoryCategory *category = (StoryCategory *)resultItem;
                        filterItem.itemTitle = category.categoryName;
                    } else if ([resultItem isKindOfClass:[NSString class]]) {
                        filterItem.itemTitle = resultItem;
                    }
                    [filterItems addObject:filterItem];
                }
                
                handleCompletion(filterItems, nil);
            } else {
                handleCompletion(result, error);
            }
        };
        
        switch (self.filterType) {
            case FilterTypeCategories: {
                [[DataManager sharedManager] categoriesForPage:page count:FILTER_DEFAULT_PAGE_SIZE completionHandler:handleResult];
            } break;
            case FilterTypeCompanies: {
                [[DataManager sharedManager] companiesForPage:page count:FILTER_DEFAULT_PAGE_SIZE completionHandler:handleResult];
            } break;
            case FilterTypeIndustry: {
                [[DataManager sharedManager] industryForPage:page count:FILTER_DEFAULT_PAGE_SIZE completionHandler:handleResult];
            } break;
            case FilterTypeFundingStage: {
                [[DataManager sharedManager] fundingStageForPage:page count:FILTER_DEFAULT_PAGE_SIZE completionHandler:handleResult];
            } break;
            case FilterTypeStage: {
                [[DataManager sharedManager] stageForPage:page count:FILTER_DEFAULT_PAGE_SIZE completionHandler:handleResult];
            } break;
            default: {
                handleResult(nil, nil);
            } break;
        }
        
        
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataContainer.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:FilterCell.reuseIdentifier];
    FilterItem *item = [self.dataContainer objectAtIndex:indexPath.row];
    cell.textLabel.text = item.itemTitle;
    return cell;
}

#pragma mark UITableView delgate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate filterListView:self didSelectItem:[self.dataContainer objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Misc

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeFilter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:FilterCell.reuseIdentifier];
    
    __weak typeof(self) wself = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [wself loadPage:self.currentPage + 1 completion:nil];
    }];
    
    self.title = [FilterItem titleForFilterType:self.filterType];
}

- (void)dealloc {
    [[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeFilter
     ];
}

@end
