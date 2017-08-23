//
//  AppDelegate.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/24/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "AppDelegate.h"
#import "TTGradientHandler.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KeyboardStateListener.h"
#import "TTDeeplinkManager.h"
#import "GeneralMethods.h"
#import "StoryFeedViewController.h"
#import "Mixpanel.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#ifdef STAGING
#define MIXPANEL_TOKEN @"f8992f27ebd5570dfab3b3c32a9b9784"
#else
#define MIXPANEL_TOKEN @"c361e94dcca816ef1b205758154d8f8a"
#endif


@interface AppDelegate ()

@property TTDeeplinkManager *deeplinkManager;

@end

#define kLastAppEntryDate @"lastEntryTimeInterval"

@implementation AppDelegate

- (void)customizeAppearance {

    [[UINavigationBar appearance] setBackgroundImage:[TTGradientHandler navBarImage] forBarMetrics:UIBarMetricsDefault];
  //  [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:(31.0/255.0) green:(172.0/255.0) blue:(228.0/255.0) alpha:1.0]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"TitilliumWeb-Light" size:21.0f]}];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    [self customizeAppearance];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [KeyboardStateListener setupObservations];

    
    //Register for push notifications
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
    }
    
    self.deeplinkManager = DEEPLINK_MANAGER;

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // navigate to NotificationsViewController
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StoryFeedViewController *feed = [storyboard instantiateViewControllerWithIdentifier:@"notificationsViewController"];
        self.window.rootViewController = feed;
    }
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
#if (TARGET_OS_SIMULATOR)
    [[Mixpanel sharedInstance] identify:@"ios_simulator"];
    [[Mixpanel sharedInstance].people set:@{@"$uniqueId": @"ios_simulator", @"$last_login": [NSDate date]}];
#else
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [[Mixpanel sharedInstance] identify:udid];
    [[Mixpanel sharedInstance].people set:@{@"$uniqueId": udid, @"$last_login": [NSDate date]}];
#endif
    
    [Fabric with:@[[Crashlytics class]]];
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{    
    bool returnBool = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];

    // PLIST VER
    
    NSMutableArray *schemes = [NSMutableArray array];
    NSArray *bundleURLTypes = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleURLTypes"];
    [bundleURLTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [schemes addObjectsFromArray:[bundleURLTypes[idx] objectForKey:@"CFBundleURLSchemes"]];
    }];
    
    for (NSString *schemeKey in schemes)
    {
        if ([GeneralMethods theWord:schemeKey existInTheString:url.scheme caseSensitive:NO])
        {
            [self.deeplinkManager loadPath:url.host];
            break;
        }
    }
    
//    NSString *stringUrl = [NSString stringWithFormat:@"%@",[url absoluteString]];
//    
//    if (stringUrl.length > 0 && [GeneralMethods theWord:TT_DOMAIN existInTheString:stringUrl caseSensitive:NO])
//    {
//        [self.deeplinkManager loadPath:stringUrl];
//    }
    
    return returnBool;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    DLog(@"UserActivity %@", userActivity.webpageURL);
    [self.deeplinkManager loadPath:[userActivity.webpageURL absoluteString]];
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([[self.window.rootViewController presentedViewController] isKindOfClass:[MPMoviePlayerViewController class]]) {
        if ([self.window.rootViewController presentedViewController].isBeingDismissed) {
            return UIInterfaceOrientationMaskPortrait;
        } else {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    if(location.y > 0 && location.y < [[UIApplication sharedApplication] statusBarFrame].size.height) {
        [self touchedStatusBar];
    }
}

- (void)touchedStatusBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTouchedStatusBar object:nil];
}

#pragma mark Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:kDeviceToken];
    [defaults synchronize];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteNotification object:nil];
    }
    @catch (NSException *exception) {
        
    }
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (BOOL)timePassedToRefresh {
    NSTimeInterval savedTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastAppEntryDate] doubleValue];
    NSTimeInterval currentTime = [NSDate date].timeIntervalSince1970;
    
    NSInteger minutesToRefresh = 30;
    if (savedTime >= (currentTime + (60 * minutesToRefresh))) {
        return YES;
    }
    return NO;
}

#pragma mark App LifeCycle

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Enter Background");
    
    [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:kLastAppEntryDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"Will Resign Active");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillResignActive" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Become Active");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:nil];
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteNotification object:nil];
    }
    @catch (NSException *exception) {
        
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kLastAppEntryDate]) {
        return;
    }
    
    if ([self timePassedToRefresh]) {
        [[DataManager sharedManager] clearFeedIndexes];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StoryFeedViewController *feed = [storyboard instantiateViewControllerWithIdentifier:@"storyFeedViewController"];
        self.window.rootViewController = feed;
    }
}

@end
