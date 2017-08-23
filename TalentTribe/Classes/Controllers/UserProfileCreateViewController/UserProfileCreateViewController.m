//
//  UserProfileCreateViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 9/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileCreateViewController.h"
#import "TTGradientHandler.h"
#import "UIViewController+Modal.h"
#import "DataManager.h"
#import "TTActivityIndicator.h"
#import "TTAlertView.h"

@interface UserProfileCreateViewController ()

@property (nonatomic, weak) IBOutlet TTCustomGradientView *headerView;

@end

@implementation UserProfileCreateViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        
    }
    return self;
}

- (void)moveToSummaryScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileSummaryViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveToUserProfileScreen {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Interface actions

- (IBAction)cvButtonPressed:(id)sender {
    [self moveToSummaryScreen];
}

- (IBAction)pdfButtonPressed:(id)sender {
    [self performFileUploadRequest];
}

- (IBAction)backButtonPressed:(id)sender
{
    if (self.isModal)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark File upload request

- (void)performFileUploadRequest {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] performUploadCVRequestWithCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [self showUploadCVAlert];
                } else {
                    if (error) {
                        [TTUtils showAlertWithText:@"Unable to complete the request at the moment"];
                    }
                }
                [TTActivityIndicator dismiss];
                loading = NO;
            }];
        }
    }
}

- (void)showUploadCVAlert {
    TTAlertView *alert = [[TTAlertView alloc] initWithMessage:[NSString stringWithFormat:@"An email with instruction and link for uploading resume was sent to: %@", [[[DataManager sharedManager] currentUser] userContactEmail]] cancelTitle:@"CLOSE"];
    [alert showOnMainWindow:YES];
}

#pragma mark Data reloading

- (void)reloadData {
    
}

#pragma mark View lifeCycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setGradientType:TTGradientType8];
}

- (void)dealloc {
    
}

@end
