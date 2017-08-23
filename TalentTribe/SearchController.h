//
//  SearchController.h
//  Testing
//
//  Created by Mendy on 07/02/2016.
//  Copyright © 2016 Mendy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBar.h"

@protocol SearchControllerDelegate <NSObject>

- (void)didStartSearching;
- (void)didTapOnSearchButton;
- (void)didTapOnCancelButton;
- (void)didChangeSearchText:(NSString *)searchText;

@end

@interface SearchController : UISearchController
@property (strong, nonatomic) SearchBar *customSearchBar;
@property (assign, nonatomic) id<SearchControllerDelegate>searchDelegate;
+ (void)searchControllerWithSearchResult:(UIViewController *)searchResultsController onController:(UIViewController *)viewController withCompletion:(SimpleResultBlock)completion;
- (void)updateTrending:(NSArray *)trending;
- (void)dismissSearchController;
- (void)showIndicator:(BOOL)show;
@end
