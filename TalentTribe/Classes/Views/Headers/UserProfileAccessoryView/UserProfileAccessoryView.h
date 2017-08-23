//
//  UserProfileAccessoryView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserProfileAccessoryView;

@protocol UserProfileAccessoryViewDelegate <NSObject>

- (void)accessoryViewCancelButtonPressed:(UserProfileAccessoryView *)view;
- (void)accessoryView:(UserProfileAccessoryView *)view didSelectItem:(NSString *)string;

@end

@interface UserProfileAccessoryView : UIView

@property (nonatomic, weak) id <UserProfileAccessoryViewDelegate> delegate;

@property BOOL suggestionsEnabled;

+ (UserProfileAccessoryView *)accessoryViewWithDelegate:(id <UserProfileAccessoryViewDelegate>)delegate;

+ (CGFloat)height;

- (void)filterSuggestionsByInput:(NSString *)input;

@end
