//
//  UserProfileAccessoryView.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 10/15/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "UserProfileAccessoryView.h"
#import "UserProfileAccessoryCell.h"
#import "UIView+Additions.h"

@interface UserProfileAccessoryView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataContainer;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation UserProfileAccessoryView

+ (UserProfileAccessoryView *)accessoryViewWithDelegate:(id <UserProfileAccessoryViewDelegate>)delegate {
    UserProfileAccessoryView *accessoryView = [UserProfileAccessoryView loadFromXib];
    accessoryView.delegate = delegate;
    return accessoryView;
}

+ (CGFloat)height {
    return 40.0f;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   [self.nextResponder resignFirstResponder];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate accessoryViewCancelButtonPressed:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.suggestionsEnabled = NO;
        self.queue = [[NSOperationQueue alloc] init];
        [self.queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"UserProfileAccessoryCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

#pragma mark Reloading data

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.suggestionsEnabled) {
            self.collectionView.hidden = NO;
            if (self.dataContainer.count > 0) {
                [self.collectionView setContentOffset:CGPointZero];
                [self.collectionView setHidden:NO];
                [self.collectionView reloadData];
            } else {
                [self.collectionView setHidden:YES];
            }
        } else {
            [self.collectionView setHidden:YES];
            self.backgroundColor = [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.0];
        }
    });
}

- (void)setSuggestionsEnabled:(BOOL)suggestionsEnabled {
    _suggestionsEnabled = suggestionsEnabled;
    self.dataContainer = nil;
    [self reloadData];
}

#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataContainer.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileAccessoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = [self.dataContainer objectAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.dataContainer objectAtIndex:indexPath.row];
    CGSize titleSize = CGRectIntegral([title boundingRectWithSize:CGSizeMake(MAXFLOAT, [UserProfileAccessoryView height]) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UserProfileAccessoryCell font]} context:nil]).size;
    return CGSizeMake(titleSize.width + [UserProfileAccessoryCell sideMargins], [UserProfileAccessoryView height]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate accessoryView:self didSelectItem:[self.dataContainer objectAtIndex:indexPath.row]];
}

#pragma mark Data filtering

- (void)filterSuggestionsByInput:(NSString *)input {
    [self.queue cancelAllOperations];
    [self.queue addOperationWithBlock:^{
        if (input.length > 0) {
            NSString *inputString = [input lowercaseString];
            NSArray *suggestions = [self suggestionsContainer];
            NSMutableArray *filteredSuggestions = [NSMutableArray new];
            [suggestions enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[obj lowercaseString] containsString:inputString]) {
                    [filteredSuggestions addObject:obj];
                }
            }];
            self.dataContainer = filteredSuggestions;
            [self reloadData];
        } else {
            self.dataContainer = nil;
            [self reloadData];
        }
    }];
}

- (NSArray *)suggestionsContainer {
    static NSArray *container = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *suggestions = [NSMutableArray new];
        NSString *content =  [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"skills_list" ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
        NSArray *contentArray = [content componentsSeparatedByString:@"\n"];
        for (NSString *item in contentArray) {
            NSArray *itemArray = [item componentsSeparatedByString:@";"];
            if (itemArray.count) {
                [suggestions addObjectsFromArray:itemArray];
            }
        }
        container = suggestions;
    });
    return container;
}

@end
