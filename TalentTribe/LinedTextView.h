//
//  LinedTextView.h
//  TalentTribe
//
//  Created by Mendy on 15/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinedTextView : UITextView <NSLayoutManagerDelegate>
- (instancetype)init;
+ (void)textViewWithText:(NSString *)text maxWidth:(CGFloat)width maxHeight:(CGFloat)height completion:(SimpleResultBlock)completion;
@end
