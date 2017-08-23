//
//  PositionViewController.m
//  TalentTribe
//
//  Created by Mendy on 01/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "PositionViewController.h"
#import "CompanyPositionDetailsTableViewCell.h"
#import "CompanyPositionSummaryTableViewCell.h"
#import "StoryDetailsShareCell.h"
#import "DataManager.h"
#import "User.h"
#import "TTAlertView.h"
#import "TTTabBarController.h"
#import "TTEmailAlertView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <JTMaterialSpinner/JTMaterialSpinner.h>
#import "CommManager.h"
#import "Mixpanel.h"

@interface PositionViewController () <UITableViewDataSource, UITableViewDelegate, TTEmailAlertViewDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@property (strong, nonatomic) UIView *animateMessageView;
@property (strong, nonatomic) TTEmailAlertView *alertView;
@property (assign, nonatomic) CGFloat webViewHeight;
@end

typedef NS_ENUM(NSInteger, PositionsCells) {
    PositionTitle,
    PositionLocation,
    PositionId,
    PositionSummary,
    PositionApply
};

#define kJobTitle @"Job Title"
#define kLocation @"Location"
#define kJobID @"Job ID"

@implementation PositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spinnerView.circleLayer.lineWidth = 3.0;
    self.spinnerView.circleLayer.strokeColor = [UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0].CGColor;
    [self.view bringSubviewToFront:self.spinnerView];
    [self createNavigationView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)animateView:(BOOL)animate {
    if (!animate) {
        [self.spinnerView endRefreshing];
        return;
    }
    [self.spinnerView beginRefreshing];
}

- (void)applySelected {
    if (![DataManager sharedManager].isCredentialsSavedInKeychain) {
        DLog(@"Not Register");
        [[DataManager sharedManager] showLoginScreen];
        return;
    } else if (![[DataManager sharedManager].currentUser isProfileMinimumFilled]) {
        [(TTTabBarController *)self.rdv_tabBarController presentCreateUserProfileScreenAnimated:YES];
        return;
    }
    [self animateView:YES];
    [[DataManager sharedManager] wannaWorkInCompany:self.company wanna:YES completionHandler:^(BOOL success, NSError *error) {
        if (success && !error) {
            [self.company setWannaWork:YES];
            [[DataManager sharedManager] showTopMessage:self withText:@"We have got your application!" backgroundColor:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            if (error) {
                [self showWannaWorkFailedAlert];
            }
        }
        [self animateView:NO];
    }];
}

#pragma mark - CV

- (void)performFileUploadRequest {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            [[DataManager sharedManager] performUploadCVRequestWithCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [self.alertView dismiss:YES];
                    [[DataManager sharedManager] showTopMessage:self withText:@"We have got your application!" backgroundColor:nil];
                    [self.navigationController popViewControllerAnimated:YES];
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

- (void)performFileUploadRequestWithoutSession {
    @synchronized(self) {
        static BOOL loading = NO;
        if (!loading) {
            loading = YES;
            [TTActivityIndicator showOnMainWindow];
            NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
            [[Mixpanel sharedInstance] track:@"Applied with email" properties:@{
                                                                            @"email" : self.alertView.email,
                                                                            @"Company" : self.company.companyName,
                                                                            @"position title": self.position.positionTitle,
                                                                            @"position location": self.position.positionLocation,
                                                                            }];
            
            [[Mixpanel sharedInstance].people set:@{
                                                    @"$user_email": self.alertView.email,
                                                    @"position title": self.position.positionTitle,
                                                    @"position location": self.position.positionLocation,
                                                    @"Company" : self.company.companyName
                                                    }];

            [[Mixpanel sharedInstance].people increment:@"positions applied count" by:@1];
            [[DataManager sharedManager] performUploadCVWithoutSessionRequest:@{
                                                                                @"userId": uniqueIdentifier,
                                                                                @"email": self.alertView.email,
                                                                                @"openPositionId": self.position.positionId,
                                                                                } withCompletionHandler:^(BOOL success, NSError *error) {
                if (success && !error) {
                    [self.alertView dismiss:YES];
                    [[DataManager sharedManager] showTopMessage:self withText:@"Great! Please check your email now." backgroundColor:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [TTUtils showAlertWithText:@"Unable to complete the request at the moment"];
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


- (void)showWannaWorkFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"It seems that you are interested in quite a few companies, that's very nice\r\nAnyway,It looks like you have reached your maximum daily quota.\r\nFeel free to continue looking for other companies, and tomorrow you will be able to express your interest in them" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
}

- (void)createNavigationView {
    CGFloat logoSize = 25;
    CGFloat space = 5;
    
    UILabel *companyName = [[UILabel alloc] init];
    companyName.text = self.company.companyName;
    companyName.textColor = [UIColor whiteColor];
    companyName.textAlignment = NSTextAlignmentLeft;
    companyName.font = [UIFont fontWithName:@"TitilliumWeb-SemiBold" size:16];
    
    CGSize actualSize = [companyName sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 0.5 - logoSize + space, CGRectGetHeight(self.navigationController.navigationBar.bounds))];
    companyName.frame = CGRectMake(logoSize + space, 0, actualSize.width, CGRectGetHeight(self.navigationController.navigationBar.bounds));
    
    UIImageView *companyLogo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(companyName.frame) - (logoSize + space), CGRectGetMidY(self.navigationController.navigationBar.bounds) - (logoSize/2), logoSize, logoSize)];
    [companyLogo sd_setImageWithURL:[NSURL URLWithString:self.company.companyLogo]];
    companyLogo.layer.cornerRadius = CGRectGetWidth(companyLogo.bounds)/2;
    
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, actualSize.width + logoSize, CGRectGetHeight(self.navigationController.navigationBar.bounds))];
    self.navigationItem.titleView = navigationView;
    
    [navigationView addSubview:companyName];
    [navigationView addSubview:companyLogo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationViewTapped)];
    [navigationView addGestureRecognizer:tap];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != PositionSummary) {
        return 80;
    }
    
    /*
    NSString *stringReplaced = [self.position.positionSummary stringByReplacingOccurrencesOfString:@"/n" withString:@"//n"];
    CGRect rect = [self.position.positionSummary boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName : TITILLIUMWEB_LIGHT(16.0f)} context:nil];
     */
    
    if (self.webViewHeight > 0) {
        return self.webViewHeight;
    }
    return [self webViewHeight:self.position.positionSummary];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompanyPositionDetailsTableViewCell *details = [self.tableView dequeueReusableCellWithIdentifier:@"positionViewControllerCell"];
    CompanyPositionSummaryTableViewCell *summary = [self.tableView dequeueReusableCellWithIdentifier:@"positionSummaryCell"];
    switch (indexPath.row) {
        case PositionTitle: {
            details.titleLabel.text = kJobTitle;
            details.descriptionLabel.text = self.position.positionTitle;
        } break;
        case PositionLocation: {
            details.titleLabel.text = kLocation;
            details.descriptionLabel.text = self.position.positionLocation;
        } break;
        case PositionId: {
            details.titleLabel.text = kJobID;
            details.descriptionLabel.text = self.position.positionNumber.length ? self.position.positionNumber : self.position.positionId;
        } break;
        case PositionSummary: {
            summary.textView.text = self.position.positionSummary;
            summary.webView.opaque = NO;
            summary.webView.backgroundColor = [UIColor clearColor];
            summary.webView.delegate = self;
    
            NSData *data = [[self htmlStringForPositionSummary:self.position.positionSummary] dataUsingEncoding:NSUTF8StringEncoding];
            [summary.webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@""]];
            return summary;
        } break;
        case PositionApply: {
            return [self applyCell];
        } break;
            
        default:
            break;
    }
    return details;
}

- (StoryDetailsShareCell *)applyCell {
    StoryDetailsShareCell *shareCell = [self.tableView dequeueReusableCellWithIdentifier:@"positionApplyCell"];
    [shareCell.shareButton setTitle:self.company.wannaWork ? @"APPLIED" : @"APPLY NOW" forState:UIControlStateNormal];
    shareCell.shareButton.enabled = !self.company.wannaWork;
    shareCell.shareButton.alpha = self.company.wannaWork ? 0.5 : 1.0;
    [shareCell.shareButton addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    return shareCell;
}


- (void)showAlert {
    self.alertView = [[TTEmailAlertView alloc] initWithMessage:[NSString stringWithFormat:@"Ready to be a part of %@?", self.company.companyName] acceptTitle:@"Send" cancelTitle:@""];
    self.alertView.delegate = self;
    [self.alertView showOnMainWindow:YES];
}

#pragma mark - TTEmailAlertViewDelegate

- (void)emailAlertView:(TTEmailAlertView *)alertView pressedButtonWithindex:(ButtonIndex2)index {
    if (index == ButtonIndexClose2) {
        [alertView dismiss:YES];
        return;
    }
    [self performFileUploadRequestWithoutSession];
}

- (NSString *)htmlStringForPositionSummary:(NSString *)summary {
    summary = [summary stringByReplacingOccurrencesOfString:@"\n" withString:@"</br>"];
    summary = [summary stringByReplacingOccurrencesOfString:@"\n\n" withString:@"</br></br>"];
    NSString *html = [NSString stringWithFormat:@"<html><head></head><body><p style=\"font-family: TitilliumWeb-Light; font-size: 16px;\">%@</p></body></html>", summary];
    return html;
}

- (NSInteger)webViewHeight:(NSString *)summary {
    UIWebView *webView = [[UIWebView alloc] init];
    [webView loadHTMLString:[self htmlStringForPositionSummary:summary] baseURL:nil];
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    NSInteger height = [result integerValue];
    return height;
}

- (void)navigationViewTapped {
    //[self presentCompanyDetailsForCompany:self.company item:MenuItemStories];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.webViewHeight > 0) {
        return;
    }
    CGFloat contentHeight = webView.scrollView.contentSize.height;
    self.webViewHeight = contentHeight;
    [self.tableView reloadData];
}

@end
