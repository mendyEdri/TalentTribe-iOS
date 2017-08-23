//
//  StoryFeedViewController.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCustomViewController.h"
#import "StoryCategory.h"

@interface StoryFeedViewController : TTCustomViewController

@property (nonatomic, strong) StoryCategory *selectedCategory;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
-(NSInteger)getStoryFromTableViewById:(NSString *)storyId;
- (void)autoAdjustScrollToTop;
@end
