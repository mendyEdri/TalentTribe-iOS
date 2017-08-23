//
//  CompanyLookingForViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyLookingForViewController.h"
#import "CompanyLookingForTableViewCell.h"
#import "Position.h"
#import "MessageTextView.h"
#import "PositionViewController.h"

typedef enum {
    SectionHeader,
    SectionPositons,
    sectionsCount
} SectionType;

@interface CompanyLookingForViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataContainer;

@property (nonatomic, weak) IBOutlet UIView *emptyContainer;
@property (nonatomic, weak) IBOutlet UILabel *emptyMessageLabel;
@property (nonatomic, weak) UITextView *message;
@end

@implementation CompanyLookingForViewController

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
            [TTActivityIndicator showOnMainWindow];
            [self.tableView setHidden:YES];
            [[DataManager sharedManager] companyPositionsForCompany:self.company completionHandler:^(NSArray *result, NSError *error) {
                if (result.count) {
                    [self.tableView setHidden:NO];
                    [self.emptyContainer setHidden:YES];
                    self.dataContainer = result;
                    [self.tableView reloadData];
                } else if (!result.count && !error) {
                    [MessageTextView textViewWithHeader:@"Open Positions" message:[NSString stringWithFormat:@"Please visit our website: %@", self.company.webLink] onView:self.view completion:^(id result, NSError *error) {
                        if (!self.message) {
                            self.message = (UITextView *)result;
                            [self.view addSubview:self.message];
                        }
                    }];
                    
                    [self.emptyContainer setHidden:NO];
                } else if (error) {
                    [TTUtils showAlertWithText:@"Unable to load at the moment"];
                }
                loading = NO;
                [TTActivityIndicator dismiss];
            }];
        }
    }
}

#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == SectionHeader ? 1 : [self.dataContainer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionHeader) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"header"];
        return cell;
    } else {
        CompanyLookingForTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        Position *position = [self.dataContainer objectAtIndex:indexPath.row];
        cell.titleLabel.text = position.positionTitle;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Position *selectedPosition = self.dataContainer[indexPath.row];
    DLog(@"Position %@", [selectedPosition dictionary]);
    PositionViewController *positionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"positionViewController"];
    positionViewController.position = selectedPosition;
    positionViewController.company = self.company;
    [self.navigationController pushViewController:positionViewController animated:YES];
}

#pragma mark Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.tableView;
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // check if controller is part of company profile tabs
    if (!self.isProfileTab) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyStories];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    //[[DataManager sharedManager] cancelRequestsForActivityType:ActivityTypeCompanyStories];
}

@end
