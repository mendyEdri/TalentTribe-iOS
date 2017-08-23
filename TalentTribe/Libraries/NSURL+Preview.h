//
//  NSUrl+Preview.h
//  TalentTribe
//
//  Created by Anton Vilimets on 7/22/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Preview)

- (void)loadPreview:(void (^)(NSDictionary *result))completion;

@end
