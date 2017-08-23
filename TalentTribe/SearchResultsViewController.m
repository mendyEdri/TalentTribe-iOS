//
//  SearchResultsViewController.m
//  TalentTribe
//
//  Created by Mendy on 09/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "SearchResultStoryTableViewCell.h"
#import "SearchResultCompanyTableViewCell.h"
#import "SearchResultCategoryTableViewCell.h"
#import "StoryCategory.h"
#import "CompanyProfileViewController.h"
#import "StoryDetailsViewController.h"
#import "DetailsPageViewController.h"
#import "StoryFeedViewController.h"
#import "StoryFeedYAxisViewController.h"
#import "SearchResultsFeedViewController.h"

@interface SearchResultsViewController () <UITableViewDataSource, UITableViewDelegate, SearchResultCategoryCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *storiesDataSource;
@property (strong, nonatomic) NSMutableArray *companiesDataSource;
@property (strong, nonatomic) NSMutableArray *categoriesDataSource;
@property (assign, nonatomic) CGFloat categoryCellHeight;
@end


typedef NS_ENUM(NSInteger, Sections) {
    Companies,
    Stories,
    Categories
};

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.storiesDataSource = [[NSMutableArray alloc] init];
    self.companiesDataSource = [[NSMutableArray alloc] init];
    self.categoriesDataSource = [[NSMutableArray alloc] init];
    [self configureTableView];
}

- (void)configureTableView {
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:(240.0/255.0) green:(240.0/255.0) blue:(240.0/255.0) alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)updateStories:(NSArray *)stories companies:(NSArray *)companies categories:(NSArray *)categories {
    if (!stories) {
        [self.storiesDataSource removeAllObjects];
    } else if (stories.count == 0) {
        [self.storiesDataSource removeAllObjects];
    } else {
        self.storiesDataSource = [[NSMutableArray alloc] initWithArray:stories];
    }
    
    if (!companies) {
        [self.companiesDataSource removeAllObjects];
    } else if (companies.count == 0) {
        [self.companiesDataSource removeAllObjects];
    } else {
        self.companiesDataSource = [[NSMutableArray alloc] initWithArray:companies];
    }
    
    if (!categories) {
        [self.categoriesDataSource removeAllObjects];
    } else if (categories.count == 0) {
        [self.categoriesDataSource removeAllObjects];
    } else {
        self.categoriesDataSource = [[NSMutableArray alloc] initWithArray:categories];
    }
    
    [self reloadData];
}

#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.showInitialData) {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showInitialData) {
        return self.initialDataContiner.count;
    }
    
    switch (section) {
        case Stories:
            return self.storiesDataSource.count;
            break;
        case Companies:
            return self.companiesDataSource.count;
            break;
        case Categories:
            return 1;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showInitialData) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultTextCell"];
        cell.contentView.backgroundColor = self.tableView.backgroundColor; //[UIColor whiteColor];
        cell.backgroundColor = self.tableView.backgroundColor; //[UIColor whiteColor];
        cell.textLabel.textColor = [UIColor grayColor];
        StoryCategory *category = self.initialDataContiner[indexPath.row];
        cell.textLabel.text = category.categoryName;
        return cell;
    }
    
    switch (indexPath.section) {
        case Stories: {
            SearchResultStoryTableViewCell *storyCell = [tableView dequeueReusableCellWithIdentifier:@"searchResultStory"];
            return storyCell;
        } break;
        case Companies: {
            SearchResultCompanyTableViewCell *companyCell = [tableView dequeueReusableCellWithIdentifier:@"searchResultCompany"];
            return companyCell;
        } break;
        case Categories: {
            SearchResultCategoryTableViewCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:@"searchResultCategory"];
            categoryCell.delegate = self;
            return categoryCell;
        } break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showInitialData) {
        return;
    }
    
    switch (indexPath.section) {
        case Companies: {
            if (self.companiesDataSource.count == 0) {
                break;
            }
            SearchResultCompanyTableViewCell *companyCell = (SearchResultCompanyTableViewCell *)cell;
            [companyCell setCompany:self.companiesDataSource[indexPath.row]];
        } break;
        case Stories: {
            if (self.storiesDataSource.count == 0) {
                break;
            }
            SearchResultStoryTableViewCell *storyCell = (SearchResultStoryTableViewCell *)cell;
            [storyCell setStory:self.storiesDataSource[indexPath.row]];
        } break;
        case Categories: {
            SearchResultCategoryTableViewCell *categoryCell = (SearchResultCategoryTableViewCell *)cell;
            [categoryCell setCategories:self.categoriesDataSource];
        } break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.showInitialData) {
        return @"Top Trending";
    }
    switch (section) {
        case Companies: {
            if (self.storiesDataSource.count == 0 && self.companiesDataSource.count == 0 && self.categoriesDataSource.count == 0) {
                return @"";
            }
            return self.companiesDataSource.count ? @"Companies" : nil;
        } break;
        case Stories:
            return self.storiesDataSource.count ? @"Stories" : nil;
        break;
        case Categories:
            return self.categoriesDataSource.count ? @"Topics" : nil;
        break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showInitialData) {
        return UITableViewAutomaticDimension;
    }
    
    switch (indexPath.section) {
        case Stories:
            return  [self heightForCellWithStory:self.storiesDataSource[indexPath.row]] + [SearchResultStoryTableViewCell topAndBottomSpace];
        break;
        case Companies:
            return 80;
        break;
        case Categories:
            return self.categoryCellHeight ? self.categoryCellHeight : 200;
            break;
        default:
            break;
    }
   return UITableViewAutomaticDimension;
}

#pragma mark - UITableView Deleaget

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showInitialData) {
        StoryCategory *category = self.initialDataContiner[indexPath.row];
        [self presentStoryFeedForStoryCategory:category];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    switch (indexPath.section) {
        case Companies: {
            CompanyProfileViewController *companyController = [self.storyboard instantiateViewControllerWithIdentifier:@"companyProfileViewController"];
            if (self.companiesDataSource && self.companiesDataSource.count > indexPath.row) {
                companyController.company = self.companiesDataSource[indexPath.row];
                companyController.currentSelectedItem = 0;
                [self.navigationController pushViewController:companyController animated:YES];
            }
        } break;
        case Stories: {
            Story *story = self.storiesDataSource[indexPath.row];
            StoryDetailsViewController *storyController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyCommentsViewController"];
            storyController.currentStory = story;
            storyController.storyDetailsControllerType = StoryDetailsTypeViewController;
            storyController.openedByDeeplink = NO;
            storyController.shouldOpenComment = NO;
            storyController.shouldDownloadStory = YES;
            storyController.canOpenCompanyDetails = NO;
            [self.navigationController pushViewController:storyController animated:YES];
        } break;
            
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)heightForCellWithStory:(Story *)story {
    CGRect titleHeight = [story.storyTitle boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.bounds) - [SearchResultStoryTableViewCell sideSpaces], 20) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"TitilliumWeb-Light" size:15.0]} context:nil];
    CGRect contentHeight = [story.storyContent boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.bounds) - [SearchResultStoryTableViewCell sideSpaces], 70) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"TitilliumWeb-Thin" size:14.0]} context:nil];
    
    return CGRectGetHeight(titleHeight) + CGRectGetHeight(contentHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (![self tableView:tableView titleForHeaderInSection:section]) {
     //   return nil;
    }
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight([self.tableView headerViewForSection:section].bounds))];
    containerView.backgroundColor = tableView.backgroundColor;
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, CGRectGetWidth(self.tableView.bounds), 22)];
    headerTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    headerTitle.font = [UIFont fontWithName:@"Futura" size:16];
    headerTitle.textColor = [UIColor lightGrayColor];
    [containerView addSubview:headerTitle];
    return containerView;
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)hideTableView:(BOOL)hide {
    self.tableView.hidden = hide;
}

#pragma mark - SearchResultCategoryCellDelegate

- (void)collectionView:(UICollectionView *)collectionView didUpdateHeight:(CGFloat)height {
    self.categoryCellHeight = height;
    [self reloadData];
}

- (void)categorySelectedAtIndex:(NSInteger)index {
    DLog(@"Category Selected %@", self.categoriesDataSource[index]);
    StoryCategory *category = self.categoriesDataSource[index];
    [self presentStoryFeedForStoryCategory:category];
}

#pragma mark Keyboard Observation

- (void)keyboardWillShow:(NSNotification *)sender {
    CGFloat height = [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|curveOption animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, height, 0);
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    NSTimeInterval duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curveOption = [[sender.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|curveOption animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = edgeInsets;
    } completion:nil];
}

- (void)presentStoryFeedForStoryCategory:(StoryCategory *)storyCategory {
    if (storyCategory) {
        SearchResultsFeedViewController *results = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsFeedViewController"];
        [results setSelectedCategory:storyCategory];
        [self.navigationController pushViewController:results animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end