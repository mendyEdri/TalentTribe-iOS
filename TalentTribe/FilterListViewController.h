//
//  FilterListTableViewController.h
//  TalentTribe
//
//  Created by Anton Vilimets on 7/21/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterItem.h"


@class FilterListViewController;

@protocol FilterListViewDelegate <NSObject>

- (void)filterListView:(FilterListViewController *)controller didSelectItem:(FilterItem *)item;

@end

@interface FilterListViewController : UIViewController

@property (nonatomic, weak) id <FilterListViewDelegate> delegate;

@property FilterType filterType;

@end
