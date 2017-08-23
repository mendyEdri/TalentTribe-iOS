//
//  CompanyPeopleViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyPeopleViewController.h"
#import "Company.h"
#import "CompanyInfo.h"
#import "CompanyPeopleHeaderView.h"
#import "CompanyPeopleTableViewCell.h"
#import "TeamMember.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
typedef enum {
    SectionItemFounders,
    SectionItemRest,
    sectionItemsCount
} SectionItem;

@interface CompanyPeopleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet TTRoundedBorderImageView *headerImageView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *foundersContainer;
@property (nonatomic, strong) NSArray *teamContainer;

@property (nonatomic, strong) NSTimer *headerTimer;
@property NSInteger currentHeaderIndex;
@property BOOL cancelled;

@end

@implementation CompanyPeopleViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    NSArray *members = self.company.companyInfo.teamMembers;
    if (members.count) {
        [self.tableView setHidden:NO];
        
        NSMutableArray *founders = [NSMutableArray new];
        NSMutableArray *team = [NSMutableArray new];
        
        for (TeamMember *member in members) {
            if (member.type == TeamMemberTypeFounder) {
                [founders addObject:member];
            } else {
                [team addObject:member];
            }
        }
        
        self.foundersContainer = founders;
        self.teamContainer = team;
        
        [self.tableView reloadData];
        
        self.currentHeaderIndex = 0;
        self.cancelled = NO;
        [self updateHeaderViewForHeaderIndex:self.currentHeaderIndex animated:NO];
    } else {
        [self.tableView setHidden:YES];
    }
}
#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionItemsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemFounders: {
            return self.foundersContainer.count;
        } break;
        case SectionItemRest: {
            return self.teamContainer.count;
        } break;
        default: {
            return 0;
        } break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CompanyPeopleHeaderView *headerView =  [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    headerView.titleLabel.text = section == SectionItemFounders ? @"Founders & Management" : @"Rest of the Team";
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompanyPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TeamMember *member = indexPath.section == SectionItemFounders ? [self.foundersContainer objectAtIndex:indexPath.row] : [self.teamContainer objectAtIndex:indexPath.row];
    cell.nameLabel.text = member.fullName;
    cell.occupationLabel.text = member.occupation;
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:member.profileImageLink]];
    
#warning REMOVE
    cell.storiesIconView.hidden = indexPath.row != 3;
    cell.storiesLabel.text = indexPath.row == 3 ? @"3 stories" : nil;
    
    return cell;
}

#pragma mark UITableView delegate

#pragma mark Header handling

- (void)scheduleHeaderTimer {
    [self invalidateHeaderTimer];
    self.headerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(headerTimerFired) userInfo:nil repeats:NO];
}

- (void)headerTimerFired {
    self.currentHeaderIndex++;
    if (self.currentHeaderIndex >= self.foundersContainer.count + self.teamContainer.count) {
        self.currentHeaderIndex = 0;
    }
    [self updateHeaderViewForHeaderIndex:self.currentHeaderIndex animated:YES];
}

- (void)updateHeaderViewForHeaderIndex:(NSInteger)index animated:(BOOL)animated {
    TeamMember *member = [self teamMemberForHeaderIndex:index];
    [self.headerImageView sd_cancelCurrentImageLoad];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:member.profileImageLink] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (animated) {
        [UIView transitionWithView:self.view duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.headerImageView.image = image;
        } completion:^(BOOL finished) {
            if (!self.cancelled) {
                [self scheduleHeaderTimer];
            }
        }];
        } else {
            self.headerImageView.image = image;
            if (!self.cancelled) {
                [self scheduleHeaderTimer];
            }
        }
    }];
}

- (void)invalidateHeaderTimer {
    if (self.headerTimer) {
        if ([self.headerTimer isValid]) {
            [self.headerTimer invalidate];
        }
        self.headerTimer = nil;
    }
}

- (TeamMember *)teamMemberForHeaderIndex:(NSInteger)index {
    if (index >= self.foundersContainer.count) {
        return [self.teamContainer objectAtIndex:index - self.foundersContainer.count];
    } else {
        return [self.foundersContainer objectAtIndex:index];
    }
}


#pragma mark Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.tableView;
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CompanyPeopleHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"headerView"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.cancelled = YES;
    [self invalidateHeaderTimer];
}

- (void)dealloc {
    self.cancelled = YES;
    [self invalidateHeaderTimer];
}

@end
