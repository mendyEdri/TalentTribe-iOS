//
//  AssociatedCompanyViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 11/12/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "AssociatedCompanyViewController.h"
#import "AssociatedCompanyTableViewCell.h"
#import "AssociateCompanyAlertViewController.h"
#import "Company.h"
#import "MessageTextView.h"
#import "TTRoundedCornersButton.h"
#import "CreateStoryAlert.h"

@interface AssociatedCompanyViewController () <UITableViewDataSource, UITableViewDelegate, CreateStoryAlertDelegate, AssociateCompanyAlertDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataContainer;
@property (nonatomic, weak) IBOutlet TTRoundedCornersButton *associateButton;
@property (strong, nonatomic) CreateStoryAlert *createStoryAlert;
@end

@implementation AssociatedCompanyViewController

#pragma mark Reload data

- (void)reloadData {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] associatedCompaniesWithCompletionHandler:^(NSArray *result, NSError *error){
                if (result && !error) {
                    self.dataContainer = result;
                    [MessageTextView removeFromView:self.view];
                    [self dismissCreateStoryAlert];
                } else {
                    if (error) {
                        [TTUtils showAlertWithText:@"Unable to load at the moment"];
                    }
                }
                loading = NO;
                [TTActivityIndicator dismiss];
                [self.tableView reloadData];
                if (!self.dataContainer || self.dataContainer.count == 0) {
                    [MessageTextView textViewWithHeader:@"No Associated Company Yet" message:@"Verifying your work email lets you upload stories and videos of your company vibe." onView:self.view completion:^(id result, NSError *error) {
                        UITextView *message = (UITextView *)result;
                        [self.view addSubview:message];
                        [self.view bringSubviewToFront:self.associateButton];
                    }];
                }
            }];
        }
    }
}
#pragma mark Interface actions

- (IBAction)quitButtonPressed:(UIButton *)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self cellForChildView:sender]];
    if (indexPath) {
        [self unregisterCompany:[self.dataContainer objectAtIndex:indexPath.row]];
    }
}

- (void)unregisterCompany:(Company *)company {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] unregisterUserCompany:company completionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [self reloadData];
                } else {
                    if (error) {
                        [TTUtils showAlertWithText:@"Unable to load at the moment"];
                    }
                }
                loading = NO;
                [TTActivityIndicator dismiss];
                [self.tableView reloadData];
            }];
        }
    }
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataContainer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssociatedCompanyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Company *company = [self.dataContainer objectAtIndex:indexPath.row];
    cell.titleLabel.text = company.companyName;
    return cell;
}

#pragma mark UITableView delegate

#pragma mark Misc

- (UITableViewCell *)cellForChildView:(UIView *)childView {
    UIView *view = childView;
    while (view && (![view isKindOfClass:[UITableViewCell class]])) {
        view = view.superview;
    }
    UITableViewCell *cell = (UITableViewCell *)view;
    NSAssert([cell isKindOfClass:[UITableViewCell class]], @"");
    return cell;
}

- (IBAction)associateCompanyButtonPressed:(id)sender {
    UIStoryboard *alertStoryboard = [UIStoryboard storyboardWithName:@"Alert" bundle:nil];
    AssociateCompanyAlertViewController *alert = [alertStoryboard instantiateViewControllerWithIdentifier:@"associateCompanyAlertViewController"];
    alert.delegate = self;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma AssociatedCompanyAlert Delegate -

- (void)didClosedAlertViewController {
    
}

#pragma mark - CreateStoryAlert Delegate

-(void)createStoryAlert:(CreateStoryAlert *)alert closeButtonClicked:(id)sender {
    [self dismissCreateStoryAlert];
}

-(void)createStoryAlert:(CreateStoryAlert *)alert emptyOrHalfFilledProfileButtonClicked:(id)sender {

}

-(void)createStoryAlertDidFinishCodeVerification:(CreateStoryAlert *)alert {
    [self reloadData];
}

- (void)dismissCreateStoryAlert {
    if (self.createStoryAlert && ![self.createStoryAlert isHidden]) {
        [UIView animateWithDuration:0.35 animations:^{
            self.createStoryAlert.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.createStoryAlert removeFromSuperview];
            self.createStoryAlert = nil;
        }];
    }
}

#pragma mark View lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.createStoryAlert && [self.createStoryAlert isHidden] == NO && [self.createStoryAlert.alertContainerInputTextField isHidden] == NO) {
        [self.createStoryAlert.alertContainerInputTextField becomeFirstResponder];
    }
}

@end
