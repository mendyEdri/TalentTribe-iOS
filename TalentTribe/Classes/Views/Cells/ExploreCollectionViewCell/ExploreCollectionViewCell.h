//
//  ExploreCollectionViewCell.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTShadowLabel.h"
#import "TTGradientHandler.h"

@interface ExploreCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet TTShadowLabel *titleLabel;
@property (nonatomic, weak) IBOutlet TTCustomGradientView *gradientView;

@end
