//
//  UserProfileTextFieldTableViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/2/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileTextFieldTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIImageView *checkMark;

@property (nonatomic, weak) IBOutlet UIView *highlightView;

- (void)setAttributedPlaceholder:(NSString *)placeholder;
- (void)setAttributedPlaceholder:(NSString *)placeholder attributes:(NSDictionary *)attributes;

@end
