//
//  KSYBeautyFilterCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/7.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYBeautyFilterCell.h"
#import "KSYFilterModel.h"

#import "KSYFilterCollectionViewCell.h"
#import "KSYFilterCollectionViewLayout.h"

@interface KSYBeautyFilterCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *beautyCollectionView;
@property(nonatomic, strong) NSMutableArray *beautyModels;
@property(nonatomic, strong) NSIndexPath    *lastSelectedIndexPath;
@end
@implementation KSYBeautyFilterCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupModels];
    [self configSubview];
    [self.beautyCollectionView reloadData];
}

- (void)setupModels{
    if (self.beautyModels == nil) {
        self.beautyModels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.beautyModels removeAllObjects];
    NSArray *filterImgagesArrsy = @[
                                    @"ksy_media_edit_record_beauty_origin",
                                    @"ksy_media_edit_record_beauty_ExtTilter_ziran",
                                    @"ksy_media_edit_record_beauty_ProFitler_weimei",
                                    @"ksy_media_edit_record_beauty_NaturalFitler_huayan",
                                    @"ksy_media_edit_record_beauty_NaturalFitler_fennen"
                                    ];
    NSArray *filterNamesArrsy = @[
                                  @"原图",
                                  @"自然",
                                  @"唯美",
                                  @"花颜",
                                  @"粉嫩"
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
        [self.beautyModels addObject:filterModel];
    }
    self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
}

- (void)configSubview{
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYFilterCollectionViewCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYFilterCollectionViewCell className]];
    
    [self.beautyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    KSYFilterCollectionViewLayout *layout = [[KSYFilterCollectionViewLayout alloc] initSize:CGSizeMake(80, 120)];
    self.beautyCollectionView.collectionViewLayout = layout;
    self.beautyCollectionView.dataSource = self;
    self.beautyCollectionView.delegate = self;
    self.beautyCollectionView.allowsMultipleSelection = NO;
    self.beautyCollectionView.multipleTouchEnabled = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.beautyModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYFilterCollectionViewCell className] forIndexPath:indexPath];
    cell.model  = self.beautyModels[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYFilterModel *lastFilterModel = [self.beautyModels objectAtIndex:self.lastSelectedIndexPath.row];
    KSYFilterModel *selectedFilterModel = [self.beautyModels objectAtIndex:indexPath.row];
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
    
    [self notifyDelegate:(KSYMEBeautyKindType)indexPath.row];
}

- (void)notifyDelegate:(KSYMEBeautyKindType)kind{
    if ([self.delegate respondsToSelector:@selector(beautyFilterCell:filterType:)]) {
        [self.delegate beautyFilterCell:self filterType:kind];
    }
}
@end
