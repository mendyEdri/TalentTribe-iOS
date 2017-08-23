//
//  CompanyProfileHeaderView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/11/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyProfileHeaderView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"

#define SCALED_CONSTANT(a) (a * (CGRectGetWidth([[UIScreen mainScreen] bounds]) / 320.0f))
#define kMinImageWidth SCALED_CONSTANT(20.0f)
#define kMaxImageWidth (SCALED_CONSTANT(67.0f) / 568) * screenHeight
#define kMinTitleHeight SCALED_CONSTANT(20.0f)
#define kMaxTitleHeight SCALED_CONSTANT(30.0f)
#define kTopOffset 33.0f
#define kSideOffset 10.0f

@interface CompanyProfileHeaderView ()

@property CGFloat titleWidth;

@end

@implementation CompanyProfileHeaderView

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _progress = 0.0f;
        _titleWidth = 0.0f;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.companyLabel setAdjustsFontSizeToFitWidth:YES];
    [self.companyLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
}

#pragma mark Custom setters

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(MAX(0.0f, progress), 1.0f);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setProgress:(CGFloat)progress withAnimationDuration:(CGFloat)duration {
    CGFloat tmpProgress = MIN(MAX(0.0f, progress), 1.0f);
    
    CGRect newImageFrame = [self frameForCompanyImageProgress:tmpProgress];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = @(self.companyImageView.frame.size.width / 2.0f);
    animation.toValue = @(newImageFrame.size.width / 2.0f);
    animation.duration = duration;
    [self.companyImageView.layer addAnimation:animation forKey:@"cornerRadius"];
    
    [UIView animateWithDuration:duration animations:^{
        self.companyImageView.frame = newImageFrame;
        self.companyLabel.frame = [self frameForCompanyLabelProgress:tmpProgress];
    } completion:^(BOOL finished) {
        [self setProgress:tmpProgress];
    }];
}

- (void)setCompanyTitle:(NSString *)title {
    if (title) {
        [self.companyLabel setAttributedText:[[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : self.companyLabel.font, NSForegroundColorAttributeName : self.companyLabel.textColor}]];
        self.titleWidth = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0f) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.companyLabel.font} context:nil].size.width;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } else {
        [self.companyLabel setAttributedText:nil];
        self.titleWidth = 0.0f;
    }
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.companyImageView.frame = [self frameForCompanyImageProgress:self.progress];
    self.companyLabel.frame = [self frameForCompanyLabelProgress:self.progress];
}

- (CGRect)frameForCompanyImageProgress:(CGFloat)progress {
    CGFloat width = kMinImageWidth + (1.0f - progress) * (kMaxImageWidth - kMinImageWidth);
    CGFloat height = width;
    CGFloat originX = (self.frame.size.width - width) / 2.0f - (([self titleWidthForProgress:1.0f] + kMinImageWidth + kSideOffset) / 2.0f) * progress;
    CGFloat originY = kTopOffset;
    CGRect frame = CGRectIntegral(CGRectMake(originX, originY, width, height));
    return frame;
}

- (CGRect)frameForCompanyLabelProgress:(CGFloat)progress {
    if (self.titleWidth > 0.0f) {
        CGFloat height = kMinTitleHeight + (1.0f - progress) * ABS(kMaxTitleHeight - kMinTitleHeight);
        CGFloat width = height * (self.titleWidth / kMaxTitleHeight);
        CGFloat originX = (self.frame.size.width - width) / 2.0f;
        CGFloat originY = kTopOffset +  (1.0f - progress) * kMaxImageWidth;
        CGRect frame = CGRectIntegral(CGRectMake(originX, originY, width, height));
        return frame;
    } else {
        return CGRectZero;
    }
}

- (CGFloat)titleWidthForProgress:(CGFloat)progress {
    CGFloat height = kMinTitleHeight + (1.0f - progress) * ABS(kMaxTitleHeight - kMinTitleHeight);
    CGFloat width = height * (self.titleWidth / kMaxTitleHeight);
    return width;
}

- (void)dealloc {
    [self.companyImageView sd_cancelCurrentImageLoad];
}

@end
