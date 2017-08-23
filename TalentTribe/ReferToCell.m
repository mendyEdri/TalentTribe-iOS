//
//  ReferToCell.m
//  TalentTribe
//
//  Created by Yagil Cohen on 6/16/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "ReferToCell.h"
#import "QuickSearch.h"
#import "UIImageView+WebCache.h"

@implementation ReferToCell


-(void) fillCellWithData:(id)data {
    
    QuickSearch *quickSearch = (QuickSearch *) data;
    self.lblCompanyName.text = quickSearch.quickSearchName;

    NSURL *logoURL = [NSURL URLWithString:quickSearch.quickSearchImage];
    [self.imgCompanyLogo sd_setImageWithURL:logoURL
                    placeholderImage:[UIImage imageNamed:@"DefaultTN.png"]
                             options:SDWebImageRefreshCached];
    
    [self.imgCheckmark setHidden:!quickSearch.isSelected];
//    if (self.isSelected) {
//        
//        [self.imgCheckmark setHidden:NO];
//        
//    } else {
//        
//        [self.imgCheckmark setHidden:YES];
//    }
    
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
