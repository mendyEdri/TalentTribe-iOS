//
//  CreateViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/19/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, strong) Company *selectedCompany;
@property (nonatomic, strong) NSString *storyIdToLoad;
@end
