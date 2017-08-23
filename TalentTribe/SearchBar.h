//
//  SearchBar.h
//  Testing
//
//  Created by Mendy on 07/02/2016.
//  Copyright © 2016 Mendy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchBarDelegate <NSObject>
- (void)searchBarDidClear;
- (void)searchBarDidChangeTextWithText:(NSString *)searchText;
@end

@interface SearchBar : UISearchBar
- (void)showIndicator:(BOOL)show;
@property (assign, nonatomic)id<SearchBarDelegate>searchBarDelegate;
@end
