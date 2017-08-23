//
//  SettingTextField.m
//  TalentTribe
//
//  Created by Anton Vilimets on 9/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "SettingTextField.h"

@implementation SettingTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.leftViewMode = UITextFieldViewModeAlways;
    return self;
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.9 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, 0.0f, self.frame.size.height-1);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height-1);
    CGContextStrokePath(context);
}


@end
