//
//  SearchResultCompanyTableViewCell.m
//  TalentTribe
//
//  Created by Mendy on 09/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "SearchResultCompanyTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SearchResultCompanyTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *companyLogo;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headquartersLabel;
@property (weak, nonatomic) IBOutlet UILabel *employeesLabel;
@end

@implementation SearchResultCompanyTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:(240.0/255.0) green:(240.0/255.0) blue:(240.0/255.0) alpha:1.0];
    self.contentView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:(240.0/255.0) green:(240.0/255.0) blue:(240.0/255.0) alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCompany:(Company *)company {
    [self.companyLogo sd_setImageWithURL:[NSURL URLWithString:company.companyLogo]];
    self.companyNameLabel.text = company.companyName;
    self.employeesLabel.text = company.employees ? [NSString stringWithFormat:@"%@ Employees", company.employees ? company.employees : @"1"] : @"";
    self.headquartersLabel.text = company.headquarters ? company.headquarters : @"";
}

@end
