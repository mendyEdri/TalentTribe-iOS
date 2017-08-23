//
//  AssociateCompanyAlertViewController.h
//  TalentTribe
//
//  Created by Mendy on 23/12/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AssociateCompanyAlertDelegate <NSObject>

- (void)didClosedAlertViewControllerAndAssociationSucceed:(BOOL)succeed;
@end

@interface AssociateCompanyAlertViewController : UITableViewController
@property (weak, nonatomic) id<AssociateCompanyAlertDelegate>delegate;
@end
