//
//  Notification.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "Notification.h"

@implementation Notification

#define kCompanyLogo @"companyLogo"
#define kCompanyName @"companyName"
#define kNotificationContent @"content"
#define kNotificationRead @"isRead"
#define kNotificationTime @"time"
#define kNotificationTypeID @"typeId"
#define kNotificationTypeName @"typeName"

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (dictionary) {
            self.companyLogo = [dictionary valueForKeyOrNil:kCompanyLogo];
            self.companyName = [dictionary valueForKeyOrNil:kCompanyName];
            self.notificationContent = [dictionary valueForKeyOrNil:kNotificationContent];
            self.notificationRead = [dictionary valueForKeyOrNil:kNotificationRead];
            self.notificationID = [dictionary valueForKeyOrNil:kNotificationTypeID];
            self.notificationType = [dictionary valueForKeyOrNil:kNotificationTypeName];
            self.notificationTime = [dictionary valueForKeyOrNil:kNotificationTime];
        }
    }
    return self;
}

@end
