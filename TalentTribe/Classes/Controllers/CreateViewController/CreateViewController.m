//
//  CreateViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 6/19/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateViewController.h"
#import "TTSlidingViewController.h"
#import "TTSlidingMenuView.h"
#import "UIViewController+Container.h"
#import "TTGradientHandler.h"
#import "CreateTabViewController.h"
#import "DejalActivityView.h"
#import "DataManager.h"
#import "CreateStoryViewController.h"
#import "CreateStoryAlert.h"
#import "TalentTribe-Swift.h"
#import "User.h"
#import "AssociateCompanyAlertViewController.h"

typedef enum {
    CreateItemStory,
    CreateItemQuestion,
    createItemsCount
} CreateItem;

@interface CreateViewController () //<TTSlidingViewControllerDataSource, TTSlidingViewControllerDelegate>

@property (nonatomic, weak) IBOutlet TTCustomGradientView *headerView;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, strong) CreateStoryViewController *storyController;
@property (weak, nonatomic) IBOutlet UILabel *topBarTitle;

/*@property (nonatomic, strong) TTSlidingViewController *slidingController;

@property (nonatomic, strong) NSMutableDictionary *viewControllers;
@property CreateItem currentSelectedItem;
*/
@end

@implementation CreateViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        /*self.viewControllers = [NSMutableDictionary new];
        self.currentSelectedItem = CreateItemStory;*/
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    //[self.slidingController setCurrentSelectedIndex:self.currentSelectedItem];
    //[self.slidingController reloadData];
}

#pragma mark Interface Actions
- (IBAction)cancelButtonPressed:(id)sender
{
    if ([self.storyController isMemberOfClass:[CreateStoryViewController class]])
    {
        CreateStoryViewController *story = (CreateStoryViewController *)self.storyController;
        if (story.createStoryAlert &&
            (story.createStoryAlert.alertMode == uploadVideoProgressMode ||
            story.createStoryAlert.alertMode == uploadStoryProgressMode))
        {
            [story.createStoryAlert animatedContainerAlert];
            return;
        }
    }
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


//-(void)viewDidAppear:(BOOL)animated
//{
//    if (self.isMovingToParentViewController) {
//        if(![DataManager sharedManager].isCredentialsSavedInKeychain)
//        {
//            [self moveToLoginScreen:YES];
//        }
//    } else {
//        if (![DataManager sharedManager].isCredentialsSavedInKeychain) {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
//}

- (void)moveToLoginScreen:(BOOL)animated {
    LoginSelectionViewController *loginController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    loginController.viewState = ViewStateAction;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [navController setNavigationBarHidden:YES];
    loginController.restorationIdentifier = @"shouldContinueCreateStoryProcess";
    [self presentViewController:navController animated:animated completion:nil];
}


- (IBAction)postButtonPressed:(id)sender {
    //CreateTabViewController *controller = (CreateTabViewController *)[self viewControllerForMenuItem:self.currentSelectedItem];
    [self.postButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateDisabled];
    [self.postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if ([self.storyController isMemberOfClass:[CreateStoryViewController class]])
    {
        CreateStoryViewController *story = (CreateStoryViewController *)self.storyController;
        if (story.createStoryAlert && story.createStoryAlert.hidden == NO)
        {
            [story.createStoryAlert animatedContainerAlert];
            return;
        }
        else
        {
            [story publishStory];
            return;
        }
    }

    
    CreateTabViewController *controller = self.storyController;

    if ([controller validateInput])
    {
        Story *story = [controller story];
        if (story)
        {
            if(story.storyType == StoryTypeMultimedia)
            {
                [TTActivityIndicator showOnView:self.view];
                [[DataManager sharedManager] uploadDataToGCS:controller.videoData completion:^(NSString *link, NSError *error) {
                    story.videoLink = link;
                    [self postStory:story anonumous:controller.anonymously];
                }];
            }
            else
            {
                [self postStory:story anonumous:controller.anonymously];
            }
        }
    }
}

- (void)postStory:(Story *)story anonumous:(BOOL)anonymous
{
    [TTActivityIndicator showOnView:self.view];
    [[DataManager sharedManager] addStory:story anonymously:anonymous completionHandler:^(BOOL success, NSError *error) {
        DLog(@"Story add result %d %@", success, error);
        if (success) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self showPostStoryAlertWithMessage:@"Your story was added!"];
        } else {
            [self showPostStoryAlertWithMessage:@"Failed to add a story. Please try again later"];
        }
        [TTActivityIndicator dismiss];
    }];
}

- (void)showPostStoryAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Sliding handling


- (CreateStoryViewController *)storyController {
    if (!_storyController) {
        _storyController = [self.storyboard instantiateViewControllerWithIdentifier:@"createStoryViewController"];
//        _storyController.company = self.selectedCompany;
    }
    return _storyController;
}

/*
- (TTSlidingViewController *)slidingController {
    if (!_slidingController) {
        _slidingController = [[TTSlidingViewController alloc] init];
        _slidingController.delegate = self;
        _slidingController.dataSource = self;
        _slidingController.maxNumberOfMenuItemsOnScreen = createItemsCount;
        [_slidingController setMenuEdgeInsets:UIEdgeInsetsMake(0.0f, 15.0f, 10.0f, 15.0f)];
        [self containerAddChildViewController:_slidingController toContainerView:self.contentContainer useAutolayout:YES];
    }
    return _slidingController;
}

- (CGFloat)heightForMenuInSlidingViewController:(TTSlidingViewController *)controller {
    return 40.0f;
}

- (NSInteger)numberOfItemsInSlidingViewController:(TTSlidingViewController *)controller {
    return createItemsCount;
}

- (UIView <TTSlidingView> *)slidingViewController:(TTSlidingViewController *)controller viewForMenuItemAtIndex:(NSInteger)index {
    return [[TTSlidingMenuView alloc] initWithTitle:[self titleForCreateItem:(CreateItem)index]];
}

- (UIViewController *)slidingViewController:(TTSlidingViewController *)controller viewControllerAtIndex:(NSInteger)index {
    return [self viewControllerForMenuItem:(CreateItem)index];
}

#pragma mark SlidingViewController delegate

- (void)slidingViewController:(TTSlidingViewController *)controller didSelectItemAtIndex:(NSInteger)index {
    self.currentSelectedItem = (CreateItem)index;
}

#pragma mark CreateItem Items handling

- (NSString *)titleForCreateItem:(CreateItem)item {
    switch (item) {
        case CreateItemStory: {
            return @"TELL YOUR STORY";
        } break;
        case CreateItemQuestion: {
            return @"ASK A QUESTION";
        } break;
        default: {
            return nil;
        } break;
    }
}

- (UIViewController *)viewControllerForMenuItem:(CreateItem)item {
    if ([self.viewControllers objectForKey:@(item)]) {
        return [self.viewControllers objectForKey:@(item)];
    } else {
        NSString *identifier;
        switch (item) {
            case CreateItemStory: {
                identifier = @"createStoryViewController";
            } break;
            case CreateItemQuestion: {
                identifier = @"createQuestionViewController";
            } break;
            default: {
                return nil;
            } break;
        }
        if (identifier) {
            CreateTabViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            controller.company = self.selectedCompany;
            [self.viewControllers setObject:controller forKey:@(item)];
            return controller;
        }
    }
    return nil;
}
*/

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setGradientType:TTGradientType8];
    
    if (self.storyIdToLoad) {
        self.storyController.storyIdToLoad = self.storyIdToLoad;
    }
    
    [self containerAddChildViewController:self.storyController toContainerView:self.contentContainer useAutolayout:YES];
    
    [self.topBarTitle setFont:[UINavigationBar appearance].titleTextAttributes[@"NSFont"]];
    
//    [self.view bringSubviewToFront:self.headerView];
    
    /*if (self.selectedCompany) {
        self.currentSelectedItem = CreateItemQuestion;
    }*/
}

@end
