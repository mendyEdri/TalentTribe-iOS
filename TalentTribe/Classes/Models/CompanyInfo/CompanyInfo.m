//
//  CompanyInfo.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyInfo.h"
#import "Snippets.h"
#import "TeamMember.h"

#define kAbout @"about"
#define kDescription @"description"
#define kWebLink @"webLink"
#define kPromotion @"promotion"
#define kTeamMembers @"teamMembers"
#define kUserViewTimes @"userViewTimes"
#define kUserWannaWork @"userWannaWork"
#define kVibeDisabled @"vibeDisabled"
#define kOfficePhotos @"officePhotos"
#define kImage @"image"
#define kTeamMembers @"teamMembers"
#define kSnippets @"snippets"
#define kTitle @"title"
#define kText @"text"

@interface CompanyInfo ()

@end

@implementation CompanyInfo

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSDictionary *about = [dict objectForKeyOrNil:kAbout];
        
        NSMutableArray *snippetsContainer = [NSMutableArray new];
        if (about) {
            NSString *companyDescriptionString = [[about objectForKeyOrNil:kDescription] length] ? [about objectForKeyOrNil:kDescription] : nil;
            
            if (companyDescriptionString) {
                [snippetsContainer addObject:[[Snippets alloc] initWithHeader:nil content:companyDescriptionString]];
            }
            
            self.promotion = [[about objectForKeyOrNil:kPromotion] boolValue];
            self.teamMembers = [about objectForKeyOrNil:kTeamMembers];
            self.userViewTimes = [[about objectForKeyOrNil:kUserViewTimes] integerValue];
            self.userWannaWork = [[about objectForKeyOrNil:kUserWannaWork] boolValue];
            self.vibeDisabled = [[about objectForKeyOrNil:kVibeDisabled] boolValue];
        }
        
        NSArray *snippetsArray = [dict objectForKeyOrNil:kSnippets];
        if (snippetsArray) {
            for (NSDictionary *snippetDict in snippetsArray) {
                [snippetsContainer addObject:[[Snippets alloc] initWithHeader:snippetDict[kTitle] content:snippetDict[kText]]];
            }
        }
        
        self.snippets = snippetsContainer.count ? snippetsContainer : nil;
        
        NSArray *officePhotos = [dict objectForKeyOrNil:kOfficePhotos];
        if (officePhotos) {
            NSMutableArray *photosContainer = [NSMutableArray new];
            for (id officeItem in officePhotos) {
                if ([officeItem isKindOfClass:[NSDictionary class]]) {
                    if ([officeItem objectForKeyOrNil:kImage]) {
                        [photosContainer addObject:[officeItem objectForKeyOrNil:kImage]];
                    }
                } else if ([officeItem isKindOfClass:[NSString class]]) {
                    [photosContainer addObject:officeItem];
                }
            }
            self.officePhotos = photosContainer.count ? photosContainer : nil;
        }
        
        /*NSArray *teamMembers = [[dict objectForKeyOrNil:kTeamMembers] count] ? [dict objectForKeyOrNil:kTeamMembers]: @[@{@"memberId" : @(1), @"fullName" : @"Ryan Greenspan", @"occupation" : @"CEO", @"image" : @"http://zetwet.com/blog/wp-content/uploads/2015/01/Side-Part-Hairstyles-Men-46.jpg", @"type" : @"FOUNDER"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Liza Edelstein", @"occupation" : @"PR Manager", @"image" : @"http://hairstylic.com/wp-content/uploads/2014/10/Mens-Hairstyles-Short-Haircuts-For-Men-Classic-Gelled.jpg", @"type" : @"FOUNDER"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Omar Epps", @"occupation" : @"iOS Developer", @"image" : @"http://vb.top-new.net/image/14/03/images_41e0.jpg", @"type" : @"FOUNDER"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Micky Mouse", @"occupation" : @"UI/UX", @"image" : @"http://easyday.snydle.com/files/2013/06/classic-men-hairstyles.jpg", @"type" : @"FOUNDER"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Nick Sloviack", @"occupation" : @"HR Manager", @"image" : @"http://fimgs.net/images/avatariru/s.165214.jpg", @"type" : @"FOUNDER"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Richard Gere", @"occupation" : @"Staff", @"image" : @"http://www.efashionhelp.com/wp-content/uploads/2012/05/latest-sunglasses-for-men-2012.jpg", @"type" : @"REST_OF_TEAM"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Simon Olmester", @"occupation" : @"Staff", @"image" : @"https://s-media-cache-ak0.pinimg.com/236x/77/1b/75/771b75e3e117ed22c32628ddc73a8cf8.jpg", @"type" : @"REST_OF_TEAM"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Tyrion Lannister", @"occupation" : @"Staff", @"image" : @"http://img3.wikia.nocookie.net/__cb20120316184837/gameofthrones/images/c/c3/TyrionEW.png", @"type" : @"REST_OF_TEAM"},
                                                                          @{@"memberId" : @(1), @"fullName" : @"Jon Snow", @"occupation" : @"Knows nothing", @"image" : @"https://pbs.twimg.com/profile_images/3456602315/aad436e6fab77ef4098c7a5b86cac8e3_normal.jpeg", @"type" : @"REST_OF_TEAM"}];*/
        NSArray *teamMembers = [[dict objectForKeyOrNil:kTeamMembers] count] ? [dict objectForKeyOrNil:kTeamMembers] : nil;
        if (teamMembers) {
            NSMutableArray *membersContainer = [NSMutableArray new];
            for (id teamMemberItem in teamMembers) {
                if ([teamMemberItem isKindOfClass:[NSDictionary class]]) {
                    TeamMember *member = [[TeamMember alloc] initWithDictionary:teamMemberItem];
                    [membersContainer addObject:member];
                }
            }
            self.teamMembers = membersContainer.count ? membersContainer : nil;
        }
    }
    return self;
}

@end
