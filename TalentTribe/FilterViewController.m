//
//  FilterViewController.m
//  TalentTribe
//
//  Created by Anton Vilimets on 7/20/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterCell.h"
#import "TTTagList.h"
#import "FilterTagListCell.h"
#import "FilterItem.h"
#import "FilterListViewController.h"

@interface FilterViewController () <FilterListViewDelegate, TTTagListDelegate>

@property (nonatomic, weak) IBOutlet TTTagList *tagList;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagListHeight;
@property CGFloat tagListInitialHeight;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
@property (nonatomic, weak) IBOutlet UIButton *clearBtn;

@property (nonatomic, strong) NSMutableArray *selectedFilters;

@end

@implementation FilterViewController

- (id)init {
    self = [super init];
    if (self) {
        self.selectedFilters = [NSMutableArray new];
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)clearPressed:(id)sender {
    [self.tagList removeAllTags];
    [self.selectedFilters removeAllObjects];
    [self reloadData];
}

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark Data reloading

- (void)reloadData {
    [self.view layoutIfNeeded];
    CGFloat newAlpha;
    if (self.selectedFilters.count) {
        self.tagListHeight.constant = self.tagListInitialHeight;
        newAlpha = 1.0f;
    } else {
        self.tagListHeight.constant = 0.0f;
        newAlpha = 0.0f;
    }
    [UIView animateWithDuration:0.2f animations:^{
        [self.view layoutIfNeeded];
        self.tagList.alpha = newAlpha;
    }];
    
    [self.tableView reloadData];
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filterTypesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:FilterCell.reuseIdentifier];
    cell.textLabel.text = [FilterItem titleForFilterType:(FilterType)indexPath.row];
    cell.textLabel.textColor = [self containsItemsOfType:(FilterType)indexPath.row] ? UIColorFromRGB(0x1dafed) : UIColorFromRGB(0x434242);
    return cell;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self handleListSelection:indexPath];
}

#pragma mark TTTagList delegate

- (Class)classForCellInTagList:(TTTagList *)tagList {
    return [FilterTagListCell class];
}

- (void)tagList:(TTTagList *)tagList didRemovedTag:(NSString *)tag atIndex:(NSInteger)index {
    [self.selectedFilters removeObjectAtIndex:index];
    [self reloadData];
}

#pragma mark FilterListViewController delegate

- (void)filterListView:(FilterListViewController *)controller didSelectItem:(FilterItem *)item {
    [self.selectedFilters addObject:item];
    [self.tagList addTag:item.itemTitle];
    [self reloadData];
}

#pragma mark Misc

- (void)handleListSelection:(NSIndexPath *)indexPath {
    FilterListViewController *listVC = [FilterListViewController new];
    listVC.filterType = (FilterType)indexPath.row;
    listVC.delegate = self;
    [self.navigationController pushViewController:listVC animated:YES];
}

- (BOOL)containsItemsOfType:(FilterType)type {
    for (FilterItem *item in self.selectedFilters) {
        if (item.itemType == type) {
            return YES;
        }
    }
    return NO;
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_clearBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_closeBtn];
    [self setTitle:@"Filter"];
    [_tableView registerNib:[UINib nibWithNibName:@"FilterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:FilterCell.reuseIdentifier];
    
    [self.tagList setShowsTagButton:NO];
    [self.tagList setEditingEnabled:NO];
    [self.tagList setRemoveOnTap:YES];
    [self.tagList setDelegate:self];
    
    self.tagListInitialHeight = self.tagListHeight.constant;
}



@end
