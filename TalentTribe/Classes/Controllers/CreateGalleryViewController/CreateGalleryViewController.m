//
//  CreateGalleryViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 7/3/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CreateGalleryViewController.h"
#import "CreateGalleryCollectionViewCell.h"
#import "CreateGalleryGroupView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Additions.h"
#import "CreateStoryViewController.h"
#import "GeneralMethods.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

NSInteger numberOfItemsInRow = 4;

@interface CreateGalleryViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIView *headerTitleView;
@property (nonatomic, weak) IBOutlet UILabel *groupTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *groupPickerIndicator;

@property (nonatomic, strong) CreateGalleryGroupView *groupPickerView;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) NSArray *assetsContainer;
@property (nonatomic, strong) NSArray *groupsContainer;

@property (nonatomic, strong) NSMutableArray *selectedItems;

@end

@implementation CreateGalleryViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedItems = [NSMutableArray new];
    }
    return self;
}

#pragma mark Interface actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate createGalleryViewControllerShouldDismiss:self];
}

- (IBAction)nextButtonPressed:(id)sender {
    [self.delegate createGalleryViewController:self didSelectAssets:self.selectedItems];
}

- (IBAction)toggleGroupSelection:(id)sender {
    self.view.userInteractionEnabled = NO;
    if (self.groupPickerView.visible) {
        [self.groupPickerView hideViewAnimated:YES completion:^{
            self.view.userInteractionEnabled = YES;
        }];
    } else {
        [self.groupPickerView showInView:self.view animated:YES completion:^{
            self.view.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark Group picker handling

- (CreateGalleryGroupView *)groupPickerView {
    if (!_groupPickerView) {
        _groupPickerView = [CreateGalleryGroupView loadFromXib];
        __weak typeof (self) weakSelf = self;
        [_groupPickerView setSelectionBlock:^(ALAssetsGroup *group, NSInteger index){
            __strong typeof (weakSelf) strongSelf = weakSelf;
            [strongSelf handleGroupSelection:group];
        }];
    }
    return _groupPickerView;
}

#pragma mark Data reloading

- (void)reloadData {
    [TTActivityIndicator showOnView:self.view];
    [self enumerateGroupsWithCompletionBlock:^(NSArray *groups, NSError *error) {
        if (groups && !error) {
            self.groupsContainer = groups;
            [self.groupPickerView setGroupsContainer:groups];
            [self selectAssetsInGroup:groups.firstObject completionBlock:^{
                [TTActivityIndicator dismiss];
            }];
        } else {
            //handle permissions
            [TTActivityIndicator dismiss];
        }
    }];
}

#pragma mark Assets handling

- (void)enumerateGroupsWithCompletionBlock:(void(^)(NSArray *groups, NSError *error))completion {
    
    if (!self.assetsLibrary) {
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    ALAssetsFilter *assetsFilter = [ALAssetsFilter allAssets];
    
    __block NSMutableArray *groups = [NSMutableArray new];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:assetsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if(groupType == ALAssetsGroupSavedPhotos) {
                if (groups.count > 0) {
                    [groups insertObject:group atIndex:0];
                } else {
                    [groups addObject:group];
                }
            } else {
                if (group.numberOfAssets > 0) {
                    [groups addObject:group];
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(groups, nil);
                }
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:resultsBlock failureBlock:failureBlock];
}

- (BOOL)checkAssetType:(ALAsset *)asset {
    NSString *type = [asset valueForProperty:ALAssetPropertyType];
    double duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
    if (type == ALAssetTypeVideo) {
        if (!self.allowVideo || duration > 30.0) {
            return NO;
        }
    }
    return YES;
}

- (void)selectAssetsInGroup:(ALAssetsGroup *)group completionBlock:(void(^)(void))completion {
    if (group) {
        [TTActivityIndicator showOnView:self.view];
        self.assetsGroup = group;
//        self.groupTitleLabel.text = group ? [group valueForProperty:ALAssetsGroupPropertyName] : @"No Items";
        self.groupTitleLabel.text = group ? @"CAMERA ROLL" : @"NO ITEMS";
        __block NSMutableArray *assets = [NSMutableArray new];
        ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset && [self checkAssetType:asset]) {
                
                [assets addObject:asset];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.assetsContainer = assets;
                    [self.collectionView reloadData];
//                    for (ALAsset *asset in assets) {
//                        for (ALAsset *selAsset in [_delegate selectedAssets]) {
//                            if([asset.defaultRepresentation.url.absoluteString isEqualToString:selAsset.defaultRepresentation.url.absoluteString])
//                            {
//                                [self.selectedItems addObject:asset];
//                                NSInteger index = [assets indexOfObject:asset];
//                                [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//                            }
//                        }
//                    }
                    [TTActivityIndicator dismiss];
                    if (completion) {
                        completion();
                    }
                });
            }
        };
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
    } else {
        self.assetsContainer = nil;
        
        
        
        [self.collectionView reloadData];
        [TTActivityIndicator dismiss];
        if (completion) {
            completion();
        }
    }
}

- (void)handleGroupSelection:(ALAssetsGroup *)group {
    [self selectAssetsInGroup:group completionBlock:nil];
    self.view.userInteractionEnabled = NO;
    [_groupPickerView hideViewAnimated:YES completion:^{
        self.view.userInteractionEnabled = YES;
    }];
}

#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^ {
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsContainer.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CreateGalleryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    ALAsset *asset = [self.assetsContainer objectAtIndex:indexPath.item];
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    BOOL videoSignNeeded = ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]);
    [cell videoSignNeeded:videoSignNeeded];
    
    return cell;
}


#pragma mark UICollectionViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat width = floor(CGRectGetWidth(collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (numberOfItemsInRow - 1)) / numberOfItemsInRow;
    return CGSizeMake(width, width);
}

#pragma mark UICollectionView delegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assetsContainer objectAtIndex:indexPath.item];
    int numOfSelectedVideos = [self numberOfSelectedAssetType:ALAssetTypeVideo];
    int numOfSelectedImages = [self numberOfSelectedAssetType:ALAssetTypePhoto];
    
    bool canAddAsset = NO;
    NSString *alertTitle;
    
    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
    {
        if (self.numOfVideosAllowed == 0 || [self numberOfSelectedAssetType:ALAssetTypePhoto] > 0)
        {
            alertTitle = CS_MEDIA_TYPE_ALERT;
        }
        else if (numOfSelectedVideos + 1 <= self.numOfVideosAllowed)
        {
            numOfSelectedVideos++;
            canAddAsset = YES;
        }
        else
        {
            alertTitle = CS_MAXIMUM_MEDIA_ALERT;
        }
    }
    else if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
    {
        if (self.numOfImagesAllowed == 0 || [self numberOfSelectedAssetType:ALAssetTypeVideo] > 0)
        {
            alertTitle = CS_MEDIA_TYPE_ALERT;
        }
        else if (numOfSelectedImages + 1 <= self.numOfImagesAllowed)
        {
            numOfSelectedImages++;
            canAddAsset = YES;
        }
        else
        {
            alertTitle = CS_MAXIMUM_MEDIA_ALERT;
        }
    }
    
    if (canAddAsset)
    {
        [self.selectedItems addObject:asset];
    }
    else
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
        UIAlertController *alert = [GeneralMethods showAlertControllerWithSingleButtonTitle:@"OK" title:alertTitle onController:self buttonClicked:^(bool clicked)
            {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.assetsContainer count] > (int)indexPath.item)
    {
        ALAsset *asset = [self.assetsContainer objectAtIndex:indexPath.item];
        
        if ([self.selectedItems containsObject:asset])
        {
            [self.selectedItems removeObject:asset];
        }
    }
}

-(int)numberOfSelectedAssetType:(NSString *)type
{
    int counter = 0;
    for (ALAsset *asset in self.selectedItems)
    {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:type])
        {
            counter ++;
        }
    }
    
    return counter;
}


#pragma mark Misc

- (void)updateContentSize {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark View lifeCycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateContentSize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)dealloc {
    self.groupsContainer = nil;
    self.assetsContainer = nil;
    
}

@end

