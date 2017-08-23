//
//  CreateGalleryGroupView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateGalleryGroupView.h"
#import "CreateGalleryGroupCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CreateGalleryGroupView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property BOOL animating;

@end

@implementation CreateGalleryGroupView

#pragma mark Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.visible = NO;
    self.animating = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateGalleryGroupCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

#pragma mark Appearance handling

- (void)showInView:(UIView *)superview animated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating && !self.visible) {
            self.animating = YES;
            self.frame = CGRectMake(0, - superview.frame.size.height, superview.frame.size.width, superview.frame.size.height);
            [superview addSubview:self];
            [self reloadData];
            [UIView animateWithDuration:animated ? 0.5f : 0.0f animations:^{
                self.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height);
            } completion:^(BOOL finished) {
                self.animating = NO;
                self.visible = YES;
                if (completion) {
                    completion();
                }
            }];
        }
    }
}

- (void)hideViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    @synchronized(self) {
        if (!self.animating && self.visible) {
            self.animating = YES;
            [UIView animateWithDuration:animated ? 0.5f : 0.0f animations:^{
                self.frame = CGRectMake(self.frame.origin.x, - self.frame.size.height, self.frame.size.width, self.frame.size.height);
            } completion:^(BOOL finished) {
                self.animating = NO;
                self.visible = NO;
                [self removeFromSuperview];
                if (completion) {
                    completion();
                }
            }];
        }
    }
}

#pragma mark Reloading data

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)setGroupsContainer:(NSArray *)groupsContainer {
    _groupsContainer = groupsContainer;
    if (self.visible) {
        [self reloadData];
    }
}

#pragma mark UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupsContainer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateGalleryGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ALAssetsGroup *group = [self.groupsContainer objectAtIndex:indexPath.row];
    cell.groupImageView.image = [UIImage imageWithCGImage:[group posterImage]];
    cell.groupTitle.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.groupAssetsCount.text = [NSString stringWithFormat:@"%ld item%@", (long)group.numberOfAssets, (group.numberOfAssets != 1) ? @"s" : @""];
    return cell;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.groupsContainer objectAtIndex:indexPath.row];
    if (self.selectionBlock) {
        self.selectionBlock(group, indexPath.row);
    }
}

#pragma mark Dealloc

- (void)dealloc {
    self.selectionBlock = nil;
}

@end
