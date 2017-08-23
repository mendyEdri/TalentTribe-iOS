//
//  SearchResultStoryTableViewCell.h
//  TalentTribe
//
//  Created by Mendy on 09/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface SearchResultStoryTableViewCell : UITableViewCell

+ (CGFloat)sideSpaces;
+ (CGFloat)topAndBottomSpace;
- (void)setStory:(Story *)story;
@end
