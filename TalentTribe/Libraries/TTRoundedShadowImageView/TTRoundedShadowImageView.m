//
//  TTRoundedShadowImageView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/22/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTRoundedShadowImageView.h"
#import "TTRoundedBorderImageView.h"

@interface TTRoundedShadowImageView ()

@property (nonatomic, strong) UIImageView *innerImageView;

@end

@implementation TTRoundedShadowImageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //self.innerImageView = [TTRoundedBorderImageView new];
        self.innerImageView = [[UIImageView alloc] init];
        self.innerImageView.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    /*
    self.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.58f].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 0.7f;
    self.layer.masksToBounds = NO;
     */
    [self addSubview:self.innerImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    self.layer.cornerRadius = self.bounds.size.width / 2.0f;
    self.innerImageView.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
    [self.innerImageView setImage:image];
}

@end
