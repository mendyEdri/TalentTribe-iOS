//
//  CompanyPositionSummaryTableViewCell.m
//  TalentTribe
//
//  Created by Mendy on 01/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "CompanyPositionSummaryTableViewCell.h"

@implementation CompanyPositionSummaryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.webView.scrollView.scrollEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
