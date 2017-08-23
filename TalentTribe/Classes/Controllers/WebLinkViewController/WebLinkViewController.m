//
//  WebLinkViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "WebLinkViewController.h"
#import "TTActivityIndicator.h"

@interface WebLinkViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation WebLinkViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [self clearDelegateAndCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadData {
    if ([[self.navigationController.viewControllers firstObject] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    } else {
        [self createCustomBackButton];
    }
    [self.navigationItem setTitle:self.titleString ?: nil];
}

#pragma mark UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [TTActivityIndicator showOnMainWindow];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [TTActivityIndicator dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [TTActivityIndicator dismiss];
}

#pragma mark View lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
    if (self.urlToOpen) {
        [self clearDelegateAndCancel];
        [self.webView setDelegate:self];
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.urlToOpen]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearDelegateAndCancel];
}

- (void)clearDelegateAndCancel {
    self.webView.delegate = nil;
    [self.webView stopLoading];
}

- (void)dealloc {
    [self clearDelegateAndCancel];
}

@end
