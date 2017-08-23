//
//  ReferQuestionViewController.h
//  TalentTribe
//
//  Created by Yagil Cohen on 6/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCustomViewController.h"

@interface ReferQuestionViewController : TTCustomViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;



@end
