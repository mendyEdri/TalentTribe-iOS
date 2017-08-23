//
//  StoryItemProvider.h
//  TalentTribe
//
//  Created by Mendy on 28/01/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface StoryItemProvider : UIActivityItemProvider

- (instancetype)initWithPlaceholderItem:(id)placeholderItem shareStory:(Story *)story image:(UIImage *)image;
@end
