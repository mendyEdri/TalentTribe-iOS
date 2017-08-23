//
//  SearchResultsViewController.h
//  TalentTribe
//
//  Created by Mendy on 09/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UIViewController

- (void)reloadData;
- (void)hideTableView:(BOOL)hide;
- (void)updateStories:(NSArray *)stories companies:(NSArray *)companies categories:(NSArray *)categories;
@property (assign, getter=shouldShowInitialData, setter=showInitialData:, nonatomic) BOOL showInitialData;
@property (strong, nonatomic) NSArray *initialDataContiner;
@end
