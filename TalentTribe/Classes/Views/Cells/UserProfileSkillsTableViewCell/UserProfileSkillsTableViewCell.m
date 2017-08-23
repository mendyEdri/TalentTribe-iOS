//
//  UserProfileSkillsTableViewCell.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/1/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileSkillsTableViewCell.h"

@implementation UserProfileSkillsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.tagList setShowsTagButton:NO];
    [self.tagList setEditingEnabled:YES];
    [self.tagList setRemoveOnTap:YES];
}

@end
