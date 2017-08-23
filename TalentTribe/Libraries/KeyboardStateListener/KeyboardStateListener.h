//
//  KeyboardStateListener.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardStateListener : NSObject

@property CGRect keyboardFrame;
@property BOOL keyboardShown;

+ (void)setupObservations;
+ (id)sharedListener;

@end
