//
//  CompanyStoriesAskCollectionViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/29/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyStoriesAskButton : UIButton
@end

@interface CompanyStoriesAskCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIButton *gradientButton;

+ (CGFloat)height;

@end
