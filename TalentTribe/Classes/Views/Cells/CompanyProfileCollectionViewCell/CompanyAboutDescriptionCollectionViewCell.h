//
//  CompanyAboutDescriptionCollectionViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/29/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyAboutDescriptionCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

+ (NSAttributedString *)attributedStringForTitle:(NSString *)title content:(NSString *)content;

+ (CGFloat)contentLeftMargin;
+ (CGFloat)contentRightMargin;
+ (CGFloat)contentTopMargin;
+ (CGFloat)contentBottomMargin;

@end
