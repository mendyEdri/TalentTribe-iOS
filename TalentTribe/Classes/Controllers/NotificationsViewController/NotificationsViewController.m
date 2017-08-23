//
//  NotificationsViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "NotificationsViewController.h"
#import "DataManager.h"
#import "RDVTabBarController.h"
#import "RootNavigationController.h"
#import "NotificationCell.h"
#import "RDVTabBarItem.h"
#import "TTTabBarController.h"
#import "MessageTextView.h"
#import "GeneralMethods.h"

@interface NotificationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *logoutButton;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MessageTextView *messageTextView;
@property (assign, nonatomic) NSInteger page;

@end

@implementation NotificationsViewController

#pragma mark View lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    //if([DataManager sharedManager].isCredentialsSavedInKeychain == NO) {
    self.logoutButton.hidden = NO;
    //}
    
    self.dataSource = [NSMutableArray new];
}

- (void)reloadData {
    [TTActivityIndicator showOnView:self.view.superview];
    [[DataManager sharedManager] userNotificationsWithParams:@{ @"pageSize" : @(100),  @"page" : @(self.page) } completionHandler:^(id result, NSError *error) {
        [TTActivityIndicator dismiss:YES];
        if (!error && result) {
            NSArray *resultsArray = result;
            if (resultsArray.count > self.page ? self.page : 1 * 100) {
                self.page++;
            }
            if (resultsArray.count > 0) {
                [self.dataSource removeAllObjects];
            }
            for (NSDictionary *dict in resultsArray) {
                Notification *notification = [[Notification alloc] initWithDictionary:dict];
                [self.dataSource addObject:notification];
            }
        }
        if (self.dataSource.count == 0) {
            [MessageTextView textViewWithHeader:@"No Notifications" message:@"Once your profile will be asked to be viewed we will notify you!" onView:self.view completion:^(id result, NSError *error) {
                UITextView *message = (UITextView *)result;
                if (!self.messageTextView) {
                    [self.view addSubview:message];
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MessageTextView removeFromView:self.view];
            });
        }
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@(%@)", appVersion, buildVersion];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [(TTTabBarController *)self.rdv_tabBarController updateTabBarNotificationBadge];
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        [self reloadData];
        return;
    }
    
    [MessageTextView textViewWithHeader:@"No Notifications" message:@"Once your profile will be asked to be viewed we will notify you!" onView:self.view completion:^(id result, NSError *error) {
        UITextView *message = (UITextView *)result;
        [self.view addSubview:message];
    }];
}

- (void)prepareDummyDatasource
{
    NSMutableArray *arr = [NSMutableArray array];
    Notification *notif = [Notification new];
    notif.notificationTitle = @"Uber App";
    notif.notificationType = @"Requested your contact info";
    [arr addObject:notif];
    
    notif = [Notification new];
    notif.notificationTitle = @"Airbnb internet";
    notif.notificationType = @"Requested your contact info";
    [arr addObject:notif];
    
    notif = [Notification new];
    notif.notificationTitle = @"Uber App";
    notif.notificationType = @"Posted a new story";
    [arr addObject:notif];
    
    notif = [Notification new];
    notif.notificationTitle = @"Airbnb internet";
    notif.notificationType = @"posted a new story";
    [arr addObject:notif];
    
    self.dataSource = arr;
}

- (IBAction)logout:(UIButton *)sender
{
    [[DataManager sharedManager] logoutWithCompletionHandler:^(BOOL success, NSError *error)
    {
        TTDeeplinkManager *manager = DEEPLINK_MANAGER;
        manager.delegate = nil;
        [(RootNavigationController *)(self.rdv_tabBarController.navigationController) moveToLoginScreen:YES];
    }];
}
- (IBAction)settingsPressed:(UIButton *)sender
{
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
    UIViewController *setttingsVC = [settingsStoryboard instantiateInitialViewController];
    [self presentViewController:setttingsVC animated:YES completion:^{
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:[NotificationCell cellIdentifier] forIndexPath:indexPath];
    [cell setupWithNotification:self.dataSource[indexPath.row]];
    return cell;
}

@end
