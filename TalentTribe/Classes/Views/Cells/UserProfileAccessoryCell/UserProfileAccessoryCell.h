//
//  UserProfileAccessoryCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 11/13/15.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileAccessoryCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

+ (CGFloat)sideMargins;
+ (UIFont *)font;

@end
