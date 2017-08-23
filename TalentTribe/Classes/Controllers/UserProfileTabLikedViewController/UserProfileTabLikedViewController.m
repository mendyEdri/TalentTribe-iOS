//
//  UserProfileTabLikedViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/6/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileTabLikedViewController.h"
#import "UserProfileSectionHeaderView.h"
#import "UserProfileLikedTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CompanyProfileViewController.h"
#import "StoryDetailsViewController.h"
#import "Story.h"
#import "Company.h"
#import "MessageTextView.h"

typedef enum {
    SectionItemCompanies,
    SectionItemStories
    //sectionsCount
} SectionItem;

@interface UserProfileTabLikedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *emptyContainer;

@property (nonatomic, strong) NSArray *companiesContainer;
@property (nonatomic, strong) NSArray *storiesContainer;

@end

@implementation UserProfileTabLikedViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    }
    return self;
}

#pragma mark Interface actions

#pragma mark Data reloading

- (void)reloadData {
    if ([[DataManager sharedManager] isCredentialsSavedInKeychain]) {
        @synchronized(self) {
            static BOOL loading = NO;
            if (!loading) {
                [TTActivityIndicator showOnMainWindow];
                [[DataManager sharedManager] userLikedCompaniesWithCompletionHandler:^(id result, NSError *error) {
                    if (result && !error) {
                        self.companiesContainer = result;
                        
                        if (self.companiesContainer.count == 0) {
                            [self.tableView headerViewForSection:0].hidden = YES;
                            [MessageTextView textViewWithHeader:@"No Liked Companies" message:@"Like a company’s vibe? Give them a thumb up and let them know!" onView:self.view completion:^(id result, NSError *error) {
                                UITextView *message = (UITextView *)result;
                                [self.view addSubview:message];
                            }];
                        } else {
                            [self.tableView headerViewForSection:0].hidden = YES;
                        }
                        
                        /*
                        [[DataManager sharedManager] userLikedStoriesWithCompletionHandler:^(id result, NSError *error) {
                            if (result && !error) {
                                self.storiesContainer = result;
                            } else {
                                if (error) {
                                    [TTUtils showAlertWithText:@"Unable to load at the moment"];
                                }
                            }
                            
                            if (self.storiesContainer.count == 0 && self.companiesContainer.count == 0) {
                                [self.tableView setHidden:YES];
                                [self.emptyContainer setHidden:NO];
                            } else {
                                [self.tableView setHidden:NO];
                                [self.emptyContainer setHidden:YES];
                                [self.tableView reloadData];
                            }
                            
                            [TTActivityIndicator dismiss:YES];
                            loading = NO;
                        }];
                         */
                        [self.tableView setHidden:NO];
                        [TTActivityIndicator dismiss:YES];
                        [self.tableView reloadData];
                        loading = NO;
                    } else {
                        if (error) {
                            [TTUtils showAlertWithText:@"Unable to load at the moment"];
                        }
                        [self.tableView reloadData];
                        [TTActivityIndicator dismiss:YES];
                        loading = NO;
                    }
                }];
            }
        }
    }
}

#pragma mark UITableView dataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return sectionsCount;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemCompanies: {
            return self.companiesContainer.count;
        } break;
        case SectionItemStories: {
            return self.storiesContainer.count;
        } break;
        default: {
            return 0;
        } break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UserProfileSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderView"];
    headerView.addButton.hidden = YES;
    switch (section) {
        case SectionItemCompanies: {
            headerView.titleLabel.text = @"Companies";
            headerView.imageView.image = [UIImage imageNamed:@"user_liked"];
        } break;
        case SectionItemStories: {
            headerView.titleLabel.text = @"Stories";
            headerView.imageView.image = [UIImage imageNamed:@"user_liked"];
        } break;
        default: {
        } break;
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileLikedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likedCell"];
    switch (indexPath.section) {
        case SectionItemCompanies: {
            Company *company = [self.companiesContainer objectAtIndex:indexPath.row];
            if (company.companyLogo) {
                [cell.likedImageView sd_setImageWithURL:[NSURL URLWithString:company.companyLogo]];
            } else {
                //placeholder
                [cell.likedImageView setImage:nil];
            }
            cell.likedTitleLabel.text = company.companyName;
        } break;
        case SectionItemStories: {
            Story *story = [self.storiesContainer objectAtIndex:indexPath.row];
            if (story.companyLogo) {
                [cell.likedImageView sd_setImageWithURL:[NSURL URLWithString:story.companyLogo]];
            } else {
                //placeholder
                [cell.likedImageView setImage:nil];
            }
            cell.likedTitleLabel.text = story.storyTitle;
        } break;
        default: {
        } break;
    }
    return cell;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemCompanies: {
            [self presentCompanyDetailsForCompany:[self.companiesContainer objectAtIndex:indexPath.row]];
        } break;
        case SectionItemStories: {
            [self presentStoryDetailsForCompany:nil story:[self.storiesContainer objectAtIndex:indexPath.row]];
        } break;
        default: {
        } break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Navigation

- (void)presentCompanyDetailsForCompany:(Company *)company {
    CompanyProfileViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]    instantiateViewControllerWithIdentifier:@"companyProfileViewController"];
    controller.company = company;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)presentStoryDetailsForCompany:(Company *)company story:(Story *)story {
    StoryDetailsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
    controller.company = company;
    controller.currentStory = story;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Misc

- (void)setupTableViewItems {
    [self.tableView registerNib:[UINib nibWithNibName:@"UserProfileSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"sectionHeaderView"];
}

#pragma mark TT Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.tableView;
}

#pragma mark View lifeCycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableViewItems];
}

- (void)dealloc {
}

@end
