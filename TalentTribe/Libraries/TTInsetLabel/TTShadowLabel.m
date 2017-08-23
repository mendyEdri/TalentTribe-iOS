//
//  TTInsetLabel.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/4/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTShadowLabel.h"

#define kShadowBlur 10.0f;

@implementation TTShadowLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.edgeInsets = UIEdgeInsetsZero;
        self.shadowEnabled = YES;
    }
    return self;
}

- (void)setShadowEnabled:(BOOL)shadowEnabled {
    _shadowEnabled = shadowEnabled;
    if (shadowEnabled) {
        if (UIEdgeInsetsEqualToEdgeInsets(self.edgeInsets, UIEdgeInsetsZero)) {
            self.edgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
        }
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (self.shadowEnabled) {
        NSShadow * shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.45f];
        shadow.shadowOffset = CGSizeZero;
        shadow.shadowBlurRadius = kShadowBlur;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        [attributedString addAttributes:@{NSShadowAttributeName : shadow} range:NSMakeRange(0, attributedString.string.length)];
        [super setAttributedText:attributedString];
    } else {
        [super setAttributedText:attributedText];
    }
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

@end
