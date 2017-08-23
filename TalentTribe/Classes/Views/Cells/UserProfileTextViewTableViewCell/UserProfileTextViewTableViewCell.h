//
//  UserProfileTextViewTableViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@interface UserProfileTextViewTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet SZTextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeight;

- (void)setAttributedPlaceholder:(NSString *)placeholder;
- (void)setAttributedPlaceholder:(NSString *)placeholder attributes:(NSDictionary *)attributes;


@end
