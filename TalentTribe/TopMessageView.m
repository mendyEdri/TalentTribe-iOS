//
//  TopMessageView.m
//  TalentTribe
//
//  Created by Mendy on 01/02/2016.
//  Copyright © 2016 OnOApps. All rights reserved.
//

#import "TopMessageView.h"
#import "GeneralMethods.h"

@interface TopMessageView ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation TopMessageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, -80, CGRectGetWidth([UIScreen mainScreen].bounds), 80);
    self.label.adjustsFontSizeToFitWidth = YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initializeSubviews];
        self = [self initWithFrame:CGRectZero];
    }
    return self;
}

- (instancetype)initializeSubviews {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    if (view) {

    }
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, -80, CGRectGetWidth([UIScreen mainScreen].bounds), 80)];
    if (self) {
        
    }
    return self;
}

- (id)initWithText:(NSString *)text backgroundColor:(UIColor *)color {
    self.label.text = text;
    self.backgroundColor = color ? color : [UIColor colorWithRed:(46.0/255.0) green:(204.0/255.0) blue:(113.0/255.0) alpha:1.0];
    return self;
}

- (void)setText:(NSString *)text backgroundColor:(UIColor *)color {
    self.label.text = text;
    self.backgroundColor = color ? color : [UIColor colorWithRed:(46.0/255.0) green:(204.0/255.0) blue:(113.0/255.0) alpha:1.0];
}

- (void)animate {
    static BOOL inProcess = NO;
    if (inProcess) {
        return;
    }
    @synchronized(self) {
        inProcess = YES;
        [GeneralMethods setNew_Ypos:-CGRectGetHeight(self.bounds) ToView:self];
        [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:2 options:kNilOptions animations:^{
            [GeneralMethods setNew_Ypos:-4 ToView:self];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:2 options:kNilOptions animations:^{
                    [GeneralMethods setNew_Ypos:-CGRectGetHeight(self.bounds) ToView:self];
                } completion:^(BOOL finished) {
                    inProcess = NO;
                }];
            }); 
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
