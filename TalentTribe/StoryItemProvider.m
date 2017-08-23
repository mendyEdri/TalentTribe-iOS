//
//  StoryItemProvider.m
//  TalentTribe
//
//  Created by Mendy on 28/01/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "StoryItemProvider.h"

@interface StoryItemProvider ()
@property (strong, nonatomic) Story *story;
@property (strong, nonatomic) UIImage *image;
@end

static NSString *const StoryFeedId = @"story";

@implementation StoryItemProvider

- (instancetype)initWithPlaceholderItem:(id)placeholderItem shareStory:(Story *)story image:(UIImage *)image {
    self = [super initWithPlaceholderItem:placeholderItem];
    if (self) {
        self.story = story;
        self.image = image;
    }
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    NSString *imageLink = self.story.storyImages.firstObject[@"regular"];
    if (self.story.videoLink) {
        imageLink = @"https://storage.googleapis.com/tt-images/category/culture_vibe.jpg";
        if (self.story.videoThumbnailLink) {
            imageLink = self.story.videoThumbnailLink;
        }
    }
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return [[DataManager sharedManager] shareHtmlWithImageUrl:imageLink storyUrl:[self storyUrlWithStory:self.story] titleText:self.story.storyTitle bodyString:self.story.storyContent];
    } else if ([activityType isEqualToString:UIActivityTypeMessage]) {
        return [NSString stringWithFormat:@"%@\n%@", self.story.storyTitle, [NSString stringWithFormat:@"Continue Reading.. %@", [NSURL URLWithString:[self storyUrlWithStory:self.story]]]];
    } else if ([activityType isEqualToString:@"com.burbn.instagram.shareextension"]) {
        return self.image;
    } else  {
        NSString *shareString = [NSString stringWithFormat:@"%@\n%@", self.story.storyTitle, [NSString stringWithFormat:@"Continue Reading.. %@", [NSURL URLWithString:[self storyUrlWithStory:self.story]]]];
        return shareString;
    }
    return nil;
}

- (id)item {
    return @"Item";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return [NSString stringWithFormat:@"TalentTribe: %@", self.story.storyTitle];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return [[UIImage alloc] init];//self.story.storyTitle;
}

- (NSString *)storyUrlWithStory:(Story *)story {
    return [NSString stringWithFormat:@"%@/redirect.html?pageId=%@&objectId=%@", SERVER_URL, StoryFeedId, story.storyId];
}

@end
