//
//  UserProfileCVViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 11/23/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "UserProfileCVViewController.h"
#import "User.h"

@interface UserProfileCVViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property BOOL loading;

@end

@implementation UserProfileCVViewController

#pragma mark Deleting CV

- (void)performDeleteCVRequest {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] deleteCVWithCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [[[DataManager sharedManager] currentUser] setUserCVURL:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    if (error) {
                        [TTUtils showAlertWithText:@"Unable to continue at the moment"];
                    }
                }
                [TTActivityIndicator dismiss];
                loading = NO;
            }];
        }
    }
}

#pragma mark Interface actions

- (IBAction)deleteCVButtonPressed:(id)sender {
    [self performDeleteCVRequest];
}

#pragma mark Reloading

- (void)reloadData {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self clearDelegatesAndCancel];
    if (self.urlToOpen) {
        [TTActivityIndicator showOnMainWindow];
        [self.webView setDelegate:self];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlToOpen]]];
    }
}

#pragma mark UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [TTActivityIndicator dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [TTActivityIndicator dismiss];
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)clearDelegatesAndCancel {
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
}

- (void)dealloc {
    [self clearDelegatesAndCancel];
}

@end
