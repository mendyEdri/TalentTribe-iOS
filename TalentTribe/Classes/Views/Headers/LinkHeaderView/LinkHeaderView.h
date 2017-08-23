//
//  LinkHeaderView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsHeaderView.h"

@interface LinkHeaderView : StoryDetailsHeaderView

@property (nonatomic, weak) IBOutlet UILabel *linkLabel;

- (void)setLinkURL:(NSString *)linkURL date:(NSDate *)date;

@end
