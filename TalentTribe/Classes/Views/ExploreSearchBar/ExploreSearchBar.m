//
//  ExploreSearchBar.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ExploreSearchBar.h"

@interface ExploreSearchBar ()

@property (nonatomic, weak) IBOutlet UIView *searchContainer;

@end

@implementation ExploreSearchBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:17.0f], NSForegroundColorAttributeName : UIColorFromRGBA(0xffffff, 0.5f)}];
    
    self.searchContainer.layer.masksToBounds = YES;
    self.searchContainer.layer.cornerRadius = 5.0f;
}

@end
