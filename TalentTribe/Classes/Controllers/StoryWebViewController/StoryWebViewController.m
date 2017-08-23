//
//  StoryWebViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/14/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryWebViewController.h"

@interface StoryWebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation StoryWebViewController

#pragma mark Interface actions

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Data reloading

- (void)reloadData {
    [self.webView stopLoading];
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearDelegatesAndCancel];
}

#pragma mark Misc

- (void)clearDelegatesAndCancel {
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
}

- (void)dealloc {
    [self clearDelegatesAndCancel];
}

@end
