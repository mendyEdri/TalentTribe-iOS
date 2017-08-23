//
//  Notification.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, strong) NSString *notificationID;
@property (nonatomic, strong) NSString *notificationTitle;
@property (nonatomic, strong) NSString *notificationType;
@property (nonatomic, strong) NSString *notificationContent;
@property (nonatomic, strong) NSString *notificationTime;
@property (nonatomic, getter=isNotificationRead) BOOL notificationRead;
@property (nonatomic, strong) NSString *companyLogo;
@property (nonatomic, strong) NSString *companyName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
