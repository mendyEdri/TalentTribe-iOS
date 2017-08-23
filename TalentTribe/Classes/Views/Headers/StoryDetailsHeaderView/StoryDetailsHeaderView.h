//
//  StoryDetailsHeaderView.h
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 5/8/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryDetailsHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *authorImageView;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorOccupation;
@property (nonatomic, weak) IBOutlet UIView *authorContainer;
@property (nonatomic, weak) IBOutlet UIButton *reportButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *authorContainerHeight;


- (void)setTitle:(NSString *)title;
- (void)setOccupation:(NSString *)occupation;
- (void)setAuthor:(NSString *)author highlight:(NSString *)highlight;
- (void)setAuthor:(NSString *)author date:(NSDate *)date;
- (void)setAuthorImageURL:(NSString *)imageURL;


+ (CGFloat)heightForTitle:(NSString *)title author:(NSString *)author size:(CGFloat)width;

+ (CGFloat)contentTopMargin;
+ (CGFloat)contentBottomMargin;
+ (CGFloat)contentLeftMargin;
+ (CGFloat)contentRightMargin;

+ (UIFont *)font;

@end
