//
//  SettingsViewController.m
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//


#import "SettingsViewController.h"
#import "WebLinkViewController.h"
#import "User.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

typedef enum {
    SettingsItemEmail,
    SettingsItemPassword,
    SettingsItemCompany,
    /*SettingsItemLocation,*/
    SettingsItemSignOut,
    SettingsItemInformation,
    SettingsItemAbout,
    SettingsItemSupport,
    SettingsItemTerms,
    SettingsItemPrivacy
} SettingsItem;

@interface SettingsViewController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@end

@implementation SettingsViewController

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)logoutPressed {
    [self dismissViewControllerAnimated:YES completion:^{
        [[DataManager sharedManager] logoutWithCompletionHandler:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginScreenNotification object:@(NO)];
    }];
}

- (void)showTermsScreen {
    [self showWebLinkWithTitle:@"TERMS & CONDITIONS" link:[NSURL URLWithString:[NSString stringWithFormat:@"%@/terms", SERVER_URL]]];
}

- (void)showPolicyScreen {
    [self showWebLinkWithTitle:@"PRIVACY POLICY" link:[NSURL URLWithString:[NSString stringWithFormat:@"%@/privacy", SERVER_URL]]];
}

- (void)openMail {
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setToRecipients:@[@"support@talenttribe.me"]];
    [mailViewController setMessageBody:@"" isHTML:NO];
    [self presentViewController:mailViewController animated:YES completion:nil];
}

- (void)showWebLinkWithTitle:(NSString *)title link:(NSURL *)urlToOpen {
    WebLinkViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"webLinkViewController"];
    [controller setUrlToOpen:urlToOpen];
    [controller setTitleString:title];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SettingsItemSignOut: {
            [self logoutPressed];
        } break;
        case SettingsItemTerms: {
            [self showTermsScreen];
        } break;
        case SettingsItemSupport: {
            [self openMail];
        } break;
        case SettingsItemPrivacy: {
            [self showPolicyScreen];
        } break;
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = [[[DataManager sharedManager] currentUser] userEmail];
    }
    return cell;
}

#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
