//
//  ExpandedTextView.h
//  TalentTribe
//
//  Created by Yagil Cohen on 6/10/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@interface ExpandedTextView : SZTextView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property int minHeight;
@property int maxHeight;
@end
