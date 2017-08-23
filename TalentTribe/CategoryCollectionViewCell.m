//
//  CategoryCollectionViewCell.m
//  TalentTribe
//
//  Created by Mendy on 16/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "CategoryCollectionViewCell.h"
#import "GeneralMethods.h"

@interface CategoryCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@end

@implementation CategoryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0;
}

- (void)setCategory:(StoryCategory *)category atIndex:(NSInteger)index {
    CGSize actualSize = [self.categoryButton.titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 0.8, CGRectGetWidth(self.categoryButton.bounds))];
    [GeneralMethods setNew_width:MAX(actualSize.width, CGRectGetWidth(self.categoryButton.bounds)) ToView:self.categoryButton];
    self.categoryButton.center = self.categoryButton.superview.center;
    [self.categoryButton setTitle:category.categoryName forState:UIControlStateNormal];
    self.categoryButton.tag = index;
}

- (IBAction)didSelectCategory:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCategoryAtIndex:)]) {
        [self.delegate didSelectCategoryAtIndex:sender.tag];
    }
}

@end
