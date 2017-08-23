//
//  CompanyProfileViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/11/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCustomViewController.h"
#import "Company.h"
#import "AsyncVideoDisplay.h"

typedef enum {
    MenuItemStories,
    MenuItemLookingFor,
    //MenuItemOurOffices,
    MenuItemAbout,
    //MenuItemPeople,
    //MenuItemProducts,
    menuItemsCount
} MenuItem;

@interface CompanyProfileViewController : TTCustomViewController

@property (nonatomic, strong) Company *company;
@property MenuItem currentSelectedItem;

@end
