//
//  CompanyAboutViewController.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CompanyAboutViewController.h"
#import "CompanyAboutHeaderCollectionViewCell.h"
#import "CompanyAboutDescriptionCollectionViewCell.h"
#import "CompanyInfo.h"
#import "Company.h"
#import "Snippets.h"

typedef enum {
    SectionItemHeader,
    SectionItemDescription,
    sectionItemsCount
} SectionItem;

typedef enum {
    HeaderItemIndustry,
    HeaderItemHeadquarters,
    HeaderItemEmployers,
    HeaderItemFounded,
    HeaderItemFunding,
    HeaderItemFundingStage,
    headerItemsCount
} HeaderItem;

@interface CompanyAboutViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *detailsContainer;

@end

@implementation CompanyAboutViewController

#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

#pragma mark Data reloading

- (void)reloadData {
    self.detailsContainer = self.company.companyInfo.snippets;
    [self.collectionView reloadData];
}

#pragma mark UICollectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sectionItemsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case SectionItemHeader: {
            return headerItemsCount;
        } break;
        case SectionItemDescription: {
            return self.detailsContainer.count;
        }
        default: {
            return 0;
        } break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionItemHeader: {
            CompanyAboutHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"aboutCell" forIndexPath:indexPath];
            switch (indexPath.row) {
                case HeaderItemIndustry: {
                    cell.headerLabel.text = @"Industry";
                    cell.imageView.image = [UIImage imageNamed:@"industry"];
                    cell.titleLabel.text = self.company.industry;
                    //cell.titleLabel.textColor = UIColorFromRGB(0xfc44ae);
                } break;
                case HeaderItemEmployers: {
                    cell.headerLabel.text = @"Employees";
                    cell.imageView.image = [UIImage imageNamed:@"employees"];
                    cell.titleLabel.text = self.company.employees;
                    //cell.titleLabel.textColor = UIColorFromRGB(0x37bd52);
                } break;
                case HeaderItemFounded: {
                    cell.headerLabel.text = @"Founded";
                    cell.imageView.image = [UIImage imageNamed:@"founded"];
                    cell.titleLabel.text = self.company.founded;
                    //cell.titleLabel.textColor = UIColorFromRGB(0xf3b620);
                } break;
                case HeaderItemFunding: {
                    cell.headerLabel.text = @"Funding";
                    cell.imageView.image = [UIImage imageNamed:@"funding"];
                    cell.titleLabel.text = self.company.funding;
                    //cell.titleLabel.textColor = UIColorFromRGB(0x3fd09e);
                } break;
                case HeaderItemHeadquarters: {
                    cell.headerLabel.text = @"Headquarters";
                    cell.imageView.image = [UIImage imageNamed:@"headquarters"];
                    cell.titleLabel.text = self.company.headquarters;
                    //cell.titleLabel.textColor = UIColorFromRGB(0xfe8b0e);
                } break;
                case HeaderItemFundingStage: {
                    cell.headerLabel.text = @"Funding Stage";
                    cell.imageView.image = [UIImage imageNamed:@"stage"];
                    cell.titleLabel.text = self.company.stage;
                    //cell.titleLabel.textColor = UIColorFromRGB(0x28b5ed);
                } break;
                default:
                    break;
            }
            return cell;
        } break;
        case SectionItemDescription: {
            CompanyAboutDescriptionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailsCell" forIndexPath:indexPath];
            Snippets *snippet = [self.detailsContainer objectAtIndex:indexPath.row];
            cell.titleLabel.attributedText = [CompanyAboutDescriptionCollectionViewCell attributedStringForTitle:snippet.header content:snippet.content];
            return cell;
        }
        default: {
            return nil;
        } break;
    }
}

#pragma mark UICollectionView flowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    switch (indexPath.section) {
        case SectionItemHeader: {
            CGFloat width = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumLineSpacing) / 2;
            CGFloat height = ((collectionView.bounds.size.width / 2.9f) - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom - flowLayout.minimumInteritemSpacing) / 2;
            return CGSizeMake(width, height);
        } break;
        case SectionItemDescription: {
            Snippets *snippet = [self.detailsContainer objectAtIndex:indexPath.row];
            CGFloat width = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumLineSpacing);
            NSAttributedString *attributedString = [CompanyAboutDescriptionCollectionViewCell attributedStringForTitle:snippet.header content:snippet.content];
            CGSize textSize = [attributedString boundingRectWithSize:CGSizeMake(width - [CompanyAboutDescriptionCollectionViewCell contentLeftMargin] - [CompanyAboutDescriptionCollectionViewCell contentRightMargin], CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
            return CGSizeMake(width, ceil(textSize.height) + [CompanyAboutDescriptionCollectionViewCell contentTopMargin] + [CompanyAboutDescriptionCollectionViewCell contentBottomMargin]);
        }
        default: {
            return CGSizeZero;
        } break;
    }
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Scrolling header

- (UIScrollView *)tt_scrollableView {
    return self.collectionView;
}

#pragma mark View lifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

@end
