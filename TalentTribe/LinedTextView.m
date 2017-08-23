//
//  LinedTextView.m
//  TalentTribe
//
//  Created by Mendy on 15/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "LinedTextView.h"

@implementation LinedTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureTextView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureTextView];
    }
    return self;
}

- (void)awakeFromNib {
    [self configureTextView];
}

- (void)configureTextView {
    self.layoutManager.delegate = self;
    
    self.font = BEBAS_BOLD(34);
    self.scrollEnabled = NO;
    self.allowsEditingTextAttributes = NO;
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.textAlignment = NSTextAlignmentLeft;
}

+ (void)textViewWithText:(NSString *)text maxWidth:(CGFloat)width maxHeight:(CGFloat)height completion:(SimpleResultBlock)completion {
    if (!text || text.length == 0) {
        if (completion) {
            completion(nil, nil);
        }
    }
    LinedTextView *textView = [[LinedTextView alloc] init];
    textView.text = [text uppercaseString];
    
    /*
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.maximumLineHeight = 50.0f;
    paragraphStyle.minimumLineHeight = 30.0f;
    paragraphStyle.lineSpacing = -10.0;
    NSString *string = [text uppercaseString];
    NSDictionary *ats = @{
                          NSFontAttributeName : TITILLIUMWEB_BOLD(26),
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
    [textView configureTextView];
     */
     
    [textView sizeToFit];
    CGSize actualSize = [textView sizeThatFits:CGSizeMake(width, height)];
    textView.frame = CGRectMake(0, (CGRectGetWidth([UIScreen mainScreen].bounds) - 10) - MIN(actualSize.height, height), actualSize.width, MIN(actualSize.height, height));
    textView.textAlignment = NSTextAlignmentLeft;
    
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[text uppercaseString]];
//    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:(0.0/255.0) green:(179.0/255.0) blue:(234.0/255.0) alpha:1.0] range:NSMakeRange(0, text.length)];
//    textView.attributedText = attributedString;
//    [textView configureTextView];
    if (completion) {
        completion(textView, nil);
    }
}

- (void)drawRect:(CGRect)rect {
    [self.layoutManager enumerateLineFragmentsForGlyphRange:NSMakeRange(0, self.text.length) usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
        
        /// The frame of the rectangle.
        UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:CGRectMake(usedRect.origin.x, usedRect.origin.y, usedRect.size.width, usedRect.size.height + 10)];
        
        /// Set the background color for each line.
        [[UIColor colorWithRed:(0.0/255.0) green:(179.0/255.0) blue:(234.0/255.0) alpha:1.0] setFill];
        
        /// Build the rectangle.
        [rectanglePath fill];
        self.textColor = [UIColor whiteColor];
        textContainer.maximumNumberOfLines = 3;
        textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        textContainer.heightTracksTextView = YES;
//        textContainer.widthTracksTextView = YES;
//        textContainer.lineFragmentPadding = 9;
    }];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 0;
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end
