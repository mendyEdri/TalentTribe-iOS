//
//  ReferQuestionViewController.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ReferQuestionViewController.h"
#import "TTGradientHandler.h"
#import "ReferToCell.h"
#import "DataManager.h"
#import "QuickSearch.h"


@interface ReferQuestionViewController () {
    
    NSMutableArray *companyList;
    NSArray *searchResults;
    QuickSearch *ttComunityObject;
    QuickSearch *currentSelectedObject;
    QuickSearch *lastSelectedObject;
    NSIndexPath *lastSelectedIndexPath;

}

@end



@implementation ReferQuestionViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Refer question to";
    }
    return self;
}

#pragma mark - Create Bar Buttons

- (void)createBarButtons {
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [postButton setTitle:@"Done" forState:UIControlStateNormal];
    [postButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 40.0, 0.0, 0.0)];
    [postButton.titleLabel setFont:[UIFont fontWithName:@"TitilliumWeb-Bold" size:16.0f]];
    UIBarButtonItem *postBarItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];
    [postButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[postBarItem];
    
    
    
//    [[UINavigationBar appearanceWhenContainedIn:[CreateViewController class], nil] setBackgroundColor:[UIColor greenColor]];
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.segmentView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:35/255.0f green:167/255.0f blue:224/255.0f alpha:1] CGColor], (id)[[UIColor colorWithRed:35/255.0f green:167/255.0f blue:224/255.0f alpha:1] CGColor], nil];
//    [self.segmentView.layer insertSublayer:gradient atIndex:0];
}




#pragma mark - Table View Data source and Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [companyList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"ReferToCell";
    ReferToCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    

    
    [cell fillCellWithData:companyList[indexPath.row]];

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (QuickSearch *quickSearchObject in companyList) {
        
        if (quickSearchObject.isSelected) {
            
            lastSelectedObject = quickSearchObject;
            lastSelectedObject.isSelected = NO;
            lastSelectedIndexPath = [NSIndexPath indexPathForItem:[companyList indexOfObject:lastSelectedObject] inSection:0];
            
        }
    }
    

    currentSelectedObject = companyList[indexPath.row];
    currentSelectedObject.isSelected = YES;

    NSIndexPath* rowToReload = indexPath;
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,lastSelectedIndexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    

    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Prepare the content of the table
    [self setTheTableContent];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self createBarButtons];

    
}

#pragma mark - Set the Table Content
-(void) setTheTableContent
{
    NSMutableDictionary *communityObject = [[NSMutableDictionary alloc] init];
    [communityObject setObject:@"TT community" forKey:@"name"];
    
    ttComunityObject = [[QuickSearch alloc] initWithDictionary:communityObject];
    
    NSArray *selectedArray = [NSArray arrayWithArray:[DataManager sharedManager].companySelectedArray];
    companyList = [NSMutableArray new];
    
    for (int i=0; i<[selectedArray count]; i++) {
        
        QuickSearch *quickSearchObject = selectedArray[i];
        [companyList insertObject:quickSearchObject atIndex:i];
    }
    
    NSArray *array = [NSArray arrayWithArray:companyList];
    [self updateData:array];

    
}

#pragma mark - UITExtFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger limit = 100;
    NSString *searchString = textField.text;
    searchString = [searchString stringByAppendingString:string];
    
    if (range.length == 1 && range.location != 0 && searchString.length > 0) {
        
        searchString = [searchString substringToIndex:[searchString length]-1];
        
    }
    
    if (range.length == 1 && range.location == 0) {
        
        searchString = @"";
        companyList = [NSMutableArray array];
        [self updateData:companyList];
        
    }
    
    if ([searchString isEqualToString:@" "] || searchString.length > 0) {
        
        [[DataManager sharedManager] quickSearchForText:searchString withLimit:limit andType:QuickSearchCompany completionHandler:^(id result, NSError *error) {
            
            if (!error) {
                
                NSArray *dataArray = (NSArray *) result;
                
                if ([dataArray count] > 0)
                {
                    [self updateData:dataArray];
                }
            }
        }];
    }
    
    return YES;
}

#pragma mark - Done button pressed
-(void)doneButtonPressed:(UIButton *)btn
{
    if (currentSelectedObject != nil)
    {
        [[DataManager sharedManager].companySelectedArray addObject:currentSelectedObject];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
}

#pragma mark - Update Data
- (void)updateData:(NSArray *)array
{
    
    companyList = [NSMutableArray arrayWithArray:array];
    [companyList insertObject:ttComunityObject atIndex:0];
    [self.tableView reloadData];
}

@end
