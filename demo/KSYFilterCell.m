//
//  KSYFilterCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYFilterCell.h"
#import "KSYFilterModel.h"

#import "KSYFilterCollectionViewCell.h"
#import "KSYFilterCollectionViewLayout.h"

@interface KSYFilterCell () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *filterCellCollectionView;
@property(nonatomic, strong) NSMutableArray *filterModels;
@property(nonatomic, strong) NSIndexPath    *lastSelectedIndexPath;
@end

@implementation KSYFilterCell

- (void)awakeFromNib {
    [super awakeFromNib];
 
    [self setupModels];
    [self configSubview];
    [self.filterCellCollectionView reloadData];
}

- (void)setupModels{
    if (self.filterModels == nil) {
        self.filterModels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.filterModels removeAllObjects];
    NSArray *filterImgagesArrsy = @[
                                  @"filter_origin",
                                  @"fliter_fresh",
                                  @"fliter_beautiful",
                                  @"fliter_sweet",
                                  @"filter_nostalgia",
                                  @"fliter_blue",
                                  @"fliter_photo"
                                  ];
    NSArray *filterNamesArrsy = @[
                                   @"原图",
                                   @"小清新",
                                   @"靓丽",
                                   @"甜美可人",
                                   @"怀旧",
                                   @"蓝调",
                                   @"老照片"
                                   ];
    
    for (int i = 0; i < filterNamesArrsy.count; i++) {
        NSString *imageName = [filterImgagesArrsy objectAtIndex:i];
        NSString *filterName = [filterNamesArrsy objectAtIndex:i];
        KSYFilterModel *filterModel = [[KSYFilterModel alloc] init];
        filterModel.imageName = imageName;
        filterModel.filterName = filterName;
        if (i == 0) {
            filterModel.isSelected = YES;
        }
        [self.filterModels addObject:filterModel];
    }
    self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
}

- (void)configSubview{
    [self.filterCellCollectionView registerNib:[UINib nibWithNibName:[KSYFilterCollectionViewCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYFilterCollectionViewCell className]];
    
    [self.filterCellCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    KSYFilterCollectionViewLayout *layout = [[KSYFilterCollectionViewLayout alloc] initSize:CGSizeMake(80, 120)];
    self.filterCellCollectionView.collectionViewLayout = layout;
    self.filterCellCollectionView.dataSource = self;
    self.filterCellCollectionView.delegate = self;
    self.filterCellCollectionView.allowsMultipleSelection = NO;
    self.filterCellCollectionView.multipleTouchEnabled = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filterModels.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYFilterCollectionViewCell className] forIndexPath:indexPath];
    cell.model  = self.filterModels[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYFilterModel *lastFilterModel = [self.filterModels objectAtIndex:self.lastSelectedIndexPath.row];
    KSYFilterModel *selectedFilterModel = [self.filterModels objectAtIndex:indexPath.row];
    if (self.lastSelectedIndexPath == indexPath) {
        //选择同一个cell
        selectedFilterModel.isSelected = !selectedFilterModel.isSelected;
    } else {
        lastFilterModel.isSelected = NO;
        [collectionView reloadItemsAtIndexPaths:@[self.lastSelectedIndexPath]];
        selectedFilterModel.isSelected = YES;
    }
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    self.lastSelectedIndexPath = indexPath;
    [collectionView scrollToItemAtIndexPath:self.lastSelectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(filterCell:filterType:filterIndex:)]) {
        [self.delegate filterCell:self filterType:KSYMEFilterTypeEffectFilter filterIndex:indexPath.row];
    }
}
@end
