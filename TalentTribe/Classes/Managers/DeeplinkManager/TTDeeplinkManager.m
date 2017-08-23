//
//  TTDeeplinkManager.m
//  TalentTribe
//
//  Created by Asi Givati on 10/12/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "TTDeeplinkManager.h"
#import "AppDelegate.h"
#import "GeneralMethods.h"
#import "TTTabBarController.h"
#import "RootNavigationController.h"
#import "DataManager.h"
#import "Story.h"
#import "Company.h"

#import "CreateViewController.h"
#import "CommManager.h"
#import "StoryFeedViewController.h"
#import "StoryDetailsViewController.h"
#import "CompanyProfileViewController.h"
#import "SDWebImagePrefetcher.h"
#import "DetailsPageViewController.h"

#define PAGE_ID_SEPARATOR_SYMBOL @"pageId="
#define OBJECT_ID_SEPARATOR_SYMBOL @"&objectId="

#define kPageId @"pageId"
#define kObjectId @"objectId"

#define MISSING_PARAMETERS_ALERT @"There are missing parameters in the link which you try to open"

#define NUMBER_OF_TABBAR_ITEMS 5

#define STORY_PAGE_ID @"story"
#define EXPLORE_PAGE_ID @"explore"
#define CREATE_PAGE_ID @"create"
#define NOTIFICATINS_PAGE_ID @"notifications"
#define PROFILE_PAGE_ID @"profile"


// story feed page ID : story
// story feed example: https://talenttribe.me?pageid=story&objectid=24d52212-a5b7-4ffb-aac5-6a4c0ce9b9bb

// Other pages ID:

// explore,create,notifications,profile

// to perform an action without objectId please send it as "0" like so:
// profile page example: https://talenttribe.me?pageid=profile&objectid=0


@implementation TTDeeplinkManager

+(nullable instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once (&once, ^
                   {
                       sharedInstance = [[self alloc] init];
                   });
    return sharedInstance;
}

-(void)loadPath:(NSString *)urlPath
{
    //urlPath = @"https://talenttribe.me?pageId=123&objectId=24d52212-a5b7-4ffb-aac5-6a4c0ce9b9bb";
    
    if (![self pathIsVerified:urlPath])
    {
        return;
    }
    
    [self deallocDeeplinkManager];
    
    self.fullPath = urlPath;
    [self setDeeplinkPropertiesFromPath:self.fullPath];
    
    [self startWithAlert:YES];
}

-(void)setDeeplinkPropertiesFromPath:(NSString *)path
{
    NSArray *pathSeparated = [path componentsSeparatedByString:@"&"];
    for (NSString *temp in pathSeparated) {
        NSArray *keyValueSeparated = [temp componentsSeparatedByString:@"="];
        if ([keyValueSeparated.firstObject isEqualToString:kPageId]) {
            self.pageId = keyValueSeparated[1];
        } else if ([keyValueSeparated.firstObject isEqualToString:kObjectId]) {
            self.objectId = keyValueSeparated[1];
        }
    }
    
    if (self.pageId && self.objectId) {
        self.tabBarNum = [self getTabBarNumberByPageID:self.pageId];
    }
    return;
    
    // #Asi TT_DOMAIN/SERVER_URL - should be dynamic from 'path'
    NSString *domainAndPageID = [NSString stringWithFormat:@"%@/%@%@",SERVER_URL, TT_REDIRECT, PAGE_ID_SEPARATOR_SYMBOL];
    
    path = [GeneralMethods removeFirstNumberOfChars:(int)domainAndPageID.length fromTheTheString:path];
    
    NSArray *separatedObj = [GeneralMethods splitTheString:path toArrayByWord:OBJECT_ID_SEPARATOR_SYMBOL caseSensitive:NO];
    
    if ([separatedObj count] > 0)
    {
        self.pageId = separatedObj[0];
        if (separatedObj[1])
        {
            self.objectId = separatedObj[1];
        }
        self.tabBarNum = [self getTabBarNumberByPageID:self.pageId];
    }
    else
    {
        [self showMissingParamsAlert];
    }
}

-(void)deallocDeeplinkManager
{
    self.fullPath  = nil;
    self.pageId = nil;
    self.objectId = nil;
    self.tabBarNum = -1;
    self.mode = OFF_MODE;
    self.selectedIndexPath = nil;
    self.selectedViewController = nil;
    self.cellClicked = NO;
}


-(void)startWithAlert: (BOOL)showAlert
{
    if (![self clickAvailable])
    {
//        if (!self.delegate)
//        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please complete the login process before moving to the requested page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//        }
        return;
    }
    
    [self performClick];
    
    //    if (showAlert)
    //    {
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Are you sure you want to leave this page?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    //        alert.tag = 10;
    //        [alert show];
    //    }
    //    else
    //    {
    //        [self performClick];
    //    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag])
    {
        case 10: // Leave the page alert
        {
            if (buttonIndex == 0)
            {
                [self deallocDeeplinkManager];
            }
            else if (buttonIndex == 1)
            {
                [self performClick];
            }
        }
            break;
    }
}

-(void)performClick
{
    if (self.tabBarNum >= 0 && (self.tabBarNum <= (NUMBER_OF_TABBAR_ITEMS -1)))
    {
        if ([self.delegate respondsToSelector:@selector(selectTabBarAtIndex:)])
        {
            self.mode = ON_MODE;
            [self.delegate selectTabBarAtIndex:self.tabBarNum];
            [self viewControllerDidSelected];
//            [self performSelector:@selector(viewControllerDidSelected) withObject:nil afterDelay:1];
        }
    }
    else if (self.tabBarNum == -1 && self.pageId) // linked to view how not belongs tabbar
    {
        
    }
}

-(void)viewControllerDidSelected
{
    self.pageId = nil; // need a check
    
    id topVC = [GeneralMethods getTopViewController];
    
    if ([topVC isMemberOfClass:[RootNavigationController class]])
    {
        id visibleVC = [topVC visibleViewController];
        
        if ([visibleVC isMemberOfClass:[TTTabBarController class]]) // from tabbar
        {
            TTTabBarController *tabBarController = ((TTTabBarController *)visibleVC);
            NSInteger visibleVCSelectedIndex = tabBarController.selectedIndex;
            if (visibleVCSelectedIndex == self.tabBarNum)
            {
                UINavigationController *navigationController = (UINavigationController *)(tabBarController.selectedViewController);
                
                self.selectedViewController = [navigationController visibleViewController];
                [self handleTapFromTabBar];
            }
        }
    }
    else if ([topVC isKindOfClass:[UIViewController class]])
    {
        if (self.delegate) // self.delegate exist - means we are after the login process
        {
            self.selectedViewController = (CreateViewController *)topVC;
            [self dissmisFirstAndContinue];
        }
    }
}

-(void)dissmisFirstAndContinue
{
    [self.selectedViewController dismissViewControllerAnimated:YES completion:^
     {
         [self performClick];
     }];
}

-(void)handleTapFromTabBar
{
    if (!self.selectedViewController)
    {
        return;
    }
    
    switch (self.tabBarNum)
    {
        case 0:
        {
            [self storyPageHandling];
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            [self profilePageHandling];
        }
            break;
    }
    
}

-(void)profilePageHandling
{
    

}


-(void)handleTap_NotFromTabBar
{
    if (!self.selectedViewController)
    {
        return;
    }
}

#pragma mark Pages handle

-(void)storyPageHandling
{
    StoryFeedViewController *storyVC = (StoryFeedViewController *)self.selectedViewController;
    
    NSUInteger cellPosition = [storyVC getStoryFromTableViewById:self.objectId];
    
    if (cellPosition != -1) // Story Exist
    {
        [self handleExistStoryWithCellIndexPath:cellPosition animated:NO];
    }
    else // Story Not Exist
    {
        [self handleMissingStory];
    }
}


-(void)handleExistStoryWithCellIndexPath:(NSInteger)cellPosition animated:(BOOL)animated
{
    DLog(@"Story Number %lu Exist",(unsigned long)cellPosition);
    StoryFeedViewController *storyVC = (StoryFeedViewController *)self.selectedViewController;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:cellPosition inSection:0];
    [storyVC.tableView setContentOffset:CGPointZero animated:NO]; //scrolling table to top
    
    [storyVC.tableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
    [storyVC performSelector:@selector(autoAdjustScrollToTop) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(storyFeedTableViewScrollCompleted) withObject:nil afterDelay:1.3];
}

-(void)storyFeedTableViewScrollCompleted
{
    if (!self.cellClicked) // bug fix
    {
        StoryFeedViewController *storyVC = (StoryFeedViewController *)self.selectedViewController;
        StoryFeedTableViewCell *cell = (StoryFeedTableViewCell *)[storyVC.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        if (cell)
        {
            self.cellClicked = YES;
           [cell blinkCellWithColor:[GeneralMethods colorWithRed:96 green:172 blue:237] interval:1 firstAlpha:0.75 parent:storyVC.tableView];
        }
        
    }
}


-(void)handleMissingStory
{
    NSLog(@"Story Not Exist");
    CGSize size = CGSizeMake(500, 500);
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:self.objectId forKey:@"storyId"];
    NSDictionary *sizeDict = @{@"width" : [NSString stringWithFormat:@"%i",(int)size.width] ,@"height": [NSString stringWithFormat:@"%i",(int)size.height]};
    [params setObject:sizeDict forKey:@"size"];
    
    [TTActivityIndicator showOnMainWindowAnimated:YES];

        [[DataManager sharedManager] getStoryWithParams:params completionHandler:^(id result, NSError *error)
        {
            [TTActivityIndicator dismiss];
            
            if (result && !error)
            {
                NSDictionary *resultDict = [[NSDictionary alloc]initWithDictionary:result];
                StoryFeedViewController *storyFeedVC = (StoryFeedViewController *)self.selectedViewController;
                
                if ([resultDict allKeys] > 0)
                {
                    Company *company = [[Company alloc]initWithDictionary:result];
                    Story *story = [[Story alloc]initWithDictionary:result];
                    
                    NSMutableArray *urls = [NSMutableArray new];
                    NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
                    if (url)
                    {
                        DLog(@"Downloading story image with URL %@", url);
                        [urls addObject:url];
                    }
                    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
                    
                    
                    UIStoryboard *storyboard = [GeneralMethods getStoryboardByName:@"Main"];
                    
                    StoryDetailsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
                    controller.company = company;
                    controller.currentStory = story;
                    controller.storyDetailsControllerType = StoryDetailsTypeViewController;
                    controller.openedByDeeplink = YES;
                    controller.shouldOpenComment = NO;
                    
                    storyFeedVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    [storyFeedVC.navigationController pushViewController:controller animated:NO];
                    [self deallocDeeplinkManager];
                }
            }
            else
            {
                [self deallocDeeplinkManager];
            }
        }];
    
    
//    [TTActivityIndicator showOnMainWindowAnimated:YES];
//
//    [[DataManager sharedManager] storyFeedForCategory:nil companyId:nil completionHandler:^(id result, NSError *error)
//     {
//         [TTActivityIndicator dismiss];
//        
//         if (result && !error)
//         {
//             Company *company;
//             Story *story;
//             StoryFeedViewController *storyFeedVC = (StoryFeedViewController *)self.selectedViewController;
//             
//             if ([result count] > 0)
//             {
//                 company = (Company *)result[0];
//                 story = company.stories[0];
////                 [storyFeedVC.tableView reloadData];
//                 NSMutableArray *urls = [NSMutableArray new];
//                 NSURL *url = [NSURL URLWithString:[story.storyImages.firstObject objectForKeyOrNil:kRegularImage]];
//                 if (url)
//                 {
//                     DLog(@"Downloading story image with URL %@", url);
//                     [urls addObject:url];
//                 }
//                 [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
//                 
//                 [storyFeedVC presentStoryDetailsForCompany:company story:story comment:NO pushStyle:YES];
//            }
//         }
//         else
//         {
//             //handle error
//         }
//     }];
}

#pragma mark Dictionaries

-(NSString *)getPageIDFromPath :(NSString *)path
{
    path = [path lowercaseString];
    
    if ([path isEqualToString:@"123"])
    {
        return STORY_PAGE_ID;
    }
    else if ([path isEqualToString:@"234"])
    {
        return EXPLORE_PAGE_ID;
    }
    else if ([path isEqualToString:@"345"])
    {
        return CREATE_PAGE_ID;
    }
    else if ([path isEqualToString:@"456"])
    {
        return NOTIFICATINS_PAGE_ID;
    }
    else if ([path isEqualToString:@"567"])
    {
        return PROFILE_PAGE_ID;
    }
    
//    if ([path isEqualToString:@"story"])
//    {
//        return STORY_PAGE_ID;
//    }
//    else if ([path isEqualToString:@"explore"])
//    {
//        return EXPLORE_PAGE_ID;
//    }
//    else if ([path isEqualToString:@"create"])
//    {
//        return CREATE_PAGE_ID;
//    }
//    else if ([path isEqualToString:@"notifications"])
//    {
//        return NOTIFICATINS_PAGE_ID;
//    }
//    else if ([path isEqualToString:@"profile"])
//    {
//        return PROFILE_PAGE_ID;
//    }
    
    return nil;
}

-(int)getTabBarNumberByPageID:(NSString *)path
{
    path = [path lowercaseString];
    int tabNum = -1;
    
    if ([path isEqualToString:STORY_PAGE_ID])
    {
        tabNum =  0;
    }
    else if ([path isEqualToString:EXPLORE_PAGE_ID])
    {
        tabNum =  1;
    }
    else if ([path isEqualToString:CREATE_PAGE_ID])
    {
        tabNum =  2;
    }
    else if ([path isEqualToString:NOTIFICATINS_PAGE_ID])
    {
        tabNum =  3;
    }
    else if([path isEqualToString:PROFILE_PAGE_ID])
    {
        tabNum =  4;
    }
    
    return tabNum;
}

#pragma mark -

#pragma mark Verifications

-(BOOL)pathIsVerified: (NSString *)path
{
    if (!path || [path isEqualToString:@""])
    {
        [self showMissingParamsAlert];
        return NO;
    }
    else if ((![GeneralMethods theWord:PAGE_ID_SEPARATOR_SYMBOL existInTheString:path caseSensitive:NO]) || ![GeneralMethods theWord:OBJECT_ID_SEPARATOR_SYMBOL existInTheString:path caseSensitive:NO])
    {
        [self showMissingParamsAlert];
        return NO;
    }
    
    return YES;
}


-(BOOL)clickAvailable
{
    return (self.pageId.length > 0 && self.delegate && [self.mode isEqualToString:OFF_MODE]);
}

#pragma mark -
#pragma Alerts

-(void)showMissingParamsAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:MISSING_PARAMETERS_ALERT delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -

@end
