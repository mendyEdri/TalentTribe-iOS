//
//  TTTouchImageView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 4/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTTouchImageView.h"

@implementation TTTouchImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    /*
    self.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.58f].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 0.7f;
    */
    self.layer.masksToBounds = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.delegate touchedTTTouchImageView:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self.delegate touchEndedTTTouchImageView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.delegate touchEndedTTTouchImageView:self];
}

@end
