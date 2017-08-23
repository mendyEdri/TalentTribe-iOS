//
//  UserProfileKeyboardObservingViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileKeyboardObservingViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property BOOL keyboardVisible;

- (UITableViewCell *)tableViewCellFromSubview:(UIView *)view;
- (NSIndexPath *)indexPathForFirstResponder;
- (void)scrollToIndexPath:(NSIndexPath *)indexPath highlight:(BOOL)highlight;

@end
