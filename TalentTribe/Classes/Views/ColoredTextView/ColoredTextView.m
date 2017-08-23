//
//  ColoredTextView.m
//  TalentTribe
//
//  Created by Mendy on 08/12/2015.
//  Copyright © 2015 OnOApps. All rights reserved.
//

#import "ColoredTextView.h"
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface ColoredTextView ()
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) UIColor *backgroundTextColor;
@property (nonatomic, strong) UIColor *textColor;
@end

static CGFloat sidePadding = 20;

@implementation ColoredTextView

/*
- (void)awakeFromNib {
    [super awakeFromNib];
    [self coloredTextViewWithText:self.text backgroundTextColor:nil textColor:nil rowHeight:0 fontSize:0 fontName:nil];
}
*/
- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text backgroundTextColor:(UIColor *)backgroundTextColor textColor:(UIColor *)textColor rowHeight:(CGFloat)rowHeight fontSize:(CGFloat)fontSize fontName:(NSString *)fontName {
    self = [super initWithFrame:frame];
    if (self) {
        [self coloredTextViewWithText:text backgroundTextColor:backgroundTextColor textColor:textColor rowHeight:rowHeight fontSize:fontSize fontName:fontName];
    }
    return self;
}

+ (void)textViewWithText:(NSString *)text backgroundTextColor:(UIColor *)backgroundTextColor textColor:(UIColor *)textColor rowHeight:(CGFloat)rowHeight fontSize:(CGFloat)fontSize fontName:(NSString *)fontName frame:(CGRect)frame completion:(SimpleResultBlock)completion {
    ColoredTextView *coloredTextView = [[ColoredTextView alloc] initWithFrame:frame text:text backgroundTextColor:backgroundTextColor textColor:textColor rowHeight:rowHeight fontSize:fontSize fontName:fontName];
    coloredTextView.backgroundColor = [UIColor lightGrayColor];

    if (completion) {
        completion(coloredTextView, nil);
    }
}
 
- (void)coloredTextViewWithText:(NSString *)text backgroundTextColor:(UIColor *)backgroundTextColor textColor:(UIColor *)textColor rowHeight:(CGFloat)rowHeight fontSize:(CGFloat)fontSize fontName:(NSString *)fontName {
    self.text = text;
    self.backgroundTextColor = backgroundTextColor;
    self.textColor = textColor;
    self.rowHeight = rowHeight;
    self.fontSize = fontSize;
    self.fontName = fontName;
}

- (void)drawRect:(CGRect)rect {
    if (!self.text || self.text.length <= 2) {
        return;
    }
    [super drawRect:rect];
    CGFloat rowHeight = self.rowHeight ? self.rowHeight : 40;
    CGFloat fontSize = self.fontSize ? self.fontSize : rowHeight / 1.5;
    self.fontSize = fontSize;
    NSString *fontName = self.fontName ? self.fontName : @"TitilliumWeb-Semibold";
    self.fontName = fontName;
    UIColor *backgroundTextColor = self.backgroundTextColor ? self.backgroundTextColor : [[UIColor blackColor] colorWithAlphaComponent:0.58];
    UIColor *textColor = self.textColor ? self.textColor : [UIColor whiteColor];
    
    CGFloat topPadding = fontSize / 3.0;
    CGFloat leftPadding = 20;
    CGFloat rightPadding = 20;
    CGFloat betweenLineSpace = 1;
    
    // detect second word and insert line break
    NSArray *arr = [self.text componentsSeparatedByString:@" "];
    NSInteger rangeIndex = 0; // where the brake line will add
    
    UILabel *factLabel = [[UILabel alloc] init];
    factLabel.text = self.text;
    factLabel.font = [UIFont fontWithName:fontName size:fontSize];
    factLabel.numberOfLines = 3;
    factLabel.lineBreakMode = NSLineBreakByWordWrapping;
    factLabel.adjustsFontSizeToFitWidth = YES;
    factLabel.minimumScaleFactor = 0.5;
    CGSize expectSize = [factLabel sizeThatFits:self.bounds.size];
    factLabel.frame = CGRectMake(factLabel.frame.origin.x, factLabel.frame.origin.y, expectSize.width, expectSize.height);
    
    if (arr.count >= 3) {
        NSString *firstWord = arr[0];
        NSString *secondWord = arr[1];

        NSInteger index = 0;
        NSString *secondLine = @"";
        for (NSString *nextWord in arr) {
            if (index >= 2) {
               secondLine = [secondLine stringByAppendingString:[NSString stringWithFormat:@"%@ ", nextWord]];
            }
            index++;
        }
        
        if ((self.text.length - (arr.count - 1)) > 14) {
            if (secondLine.length > 4 || arr.count >= 4) {
                rangeIndex = firstWord.length + 1 + secondWord.length;
            }
        }
    }
    if (rangeIndex && rangeIndex < self.text.length) {
        //self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(rangeIndex, 1) withString:@"\n"];
    }
    
    
    NSMutableArray *linesArray = [NSMutableArray new];
    NSString *line = @"";
    NSInteger wordIndex = 0;
    for (NSString *word in arr) {
        wordIndex++;
        BOOL shouldAppend = line.length + word.length <= 24; // 26
        DLog(@"Rect of row %d", [self lineFits:[line stringByAppendingString:[NSString stringWithFormat:@"%@ ", word]]]);
        if (shouldAppend) {
            line = [line stringByAppendingString:[NSString stringWithFormat:@"%@ ", word]];
        }
        if (!shouldAppend && line.length > 1) {
            NSString *updatedLine = [line substringToIndex:line.length - 1];
            [linesArray addObject:updatedLine];
            line = !shouldAppend ? [NSString stringWithFormat:@"%@ ", word] : @"";
            if (wordIndex == arr.count) {
                [linesArray addObject:line];
            }
        } else if (wordIndex == arr.count) {
            [linesArray addObject:line];
        }
    }
    
    self.text = @"";
    for (NSString *line in linesArray) {
        self.text = [self.text stringByAppendingString:line];
        if (linesArray.count > 1) {
            self.text = [self.text stringByAppendingString:@"\n"];
        } else if (linesArray.count == 1) {
            NSString *line = [linesArray firstObject];
            if (line.length > 22) {
                NSInteger range = 0;
                if (arr.count == 1) {
                    NSString *firstWord = [arr firstObject];
                    range = firstWord.length;
                } else if (arr.count > 1) {
                    NSString *firstWord = [arr firstObject];
                    NSString *secondWord = arr[1];
                    range = firstWord.length + 1 + secondWord.length;
                }
                self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(range, 1) withString:@"\n"];
            }
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1;
//    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.minimumLineHeight = rowHeight;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:fontSize] range:NSMakeRange(0, self.text.length)];
    [attr addAttribute:@"kBackgroundAttribute" value:backgroundTextColor range:NSMakeRange(0, self.text.length)];
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, self.text.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, self.text.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attr);
    CGMutablePathRef framePath = CGPathCreateMutable();
    
    CGRect bounds = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds) - (rightPadding + leftPadding), CGRectGetHeight(self.bounds) - topPadding);
    CGPathAddRect(framePath, nil, bounds);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), framePath, nil);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex numLines = CFArrayGetCount(lines);
    CGPoint *origins = (CGPoint *)malloc(numLines * sizeof(CGPoint));
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);
    
    NSArray *reversedArray = (__bridge NSArray*)lines;
    NSArray *array = [[reversedArray reverseObjectEnumerator] allObjects];
    CGFloat lineHeight = 0;
    NSInteger lineIndex = 0;
    for (id line in array) {
        CGPoint lineOrigin = origins[lineIndex];
        lineOrigin.y = lineOrigin.y - topPadding;
        
        CTLineRef lineRef = (__bridge CTLineRef)(line);
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        NSArray *runsArray = (__bridge NSArray *)runs;
        NSInteger index = 0;
        for (id runRef in runsArray) {
            CTRunRef run = (__bridge CTRunRef)(runRef);
            CFRange stringRange = CTRunGetStringRange(run);
            if (stringRange.length == 1) {
                break;
            }
            CGFloat ascent = 0;
            CGFloat descent = 0;
            CGFloat leading = 0;
            double typographicBounds = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            __unused CGFloat xOffset = CTLineGetOffsetForStringIndex(lineRef, stringRange.location, nil) - leftPadding;
            
            CGFloat lineSpace = (rowHeight/2 - fontSize/2 + descent);
            CGFloat startingPoint = rowHeight * lineIndex + lineSpace;
            
            CGContextSetTextPosition(ctx, lineOrigin.x + rightPadding, startingPoint + topPadding + betweenLineSpace * 2);
            CGFloat currentLineHeight = ascent + descent + leading;
            if (currentLineHeight > lineHeight) {
                lineHeight = currentLineHeight;
            }
            
            CGRect runBounds = CGRectMake(/*lineOrigin.x*/ 0, startingPoint, typographicBounds + rightPadding  + leftPadding, rowHeight - betweenLineSpace); //+ leftPadding + rightPadding
            
            CFDictionaryRef attributesRef = CTRunGetAttributes(run);
            NSDictionary *attributes = (__bridge NSDictionary *)(attributesRef);
            UIColor *maybeColor = [attributes valueForKey:@"kBackgroundAttribute"];
            if ([maybeColor isKindOfClass:[UIColor class]]) {
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:runBounds cornerRadius:0];
                [maybeColor setFill];
                [path fill];
                index++;
            }
            CTRunDraw(run, ctx, CFRangeMake(0, 0));
        }
        
        lineIndex++;
    }
    CGContextRestoreGState(ctx);
}

- (BOOL)lineFits:(NSString *)line {
    CGRect expectedLabelSize = [line boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds) - (sidePadding * 2), self.rowHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : TITILLIUMWEB_SEMIBOLD(self.fontSize)} context:NULL];
    DLog(@"Bounds %f", self.bounds.size.width - (sidePadding * 2));
    DLog(@"Lable %f", expectedLabelSize.size.width);
    return expectedLabelSize.size.width < self.bounds.size.width - (sidePadding * 2);
}

@end
