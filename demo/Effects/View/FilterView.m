//
//  FilterView.m
//  
//
//  Created by ksyun on 17/4/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "FilterView.h"
#import "FilterCell.h"


#define KFilterCellHeight 100
#define KFilterCellWidth 75
#define kFilterSpaceWidth 16
#define kEffectNum  7

@interface FilterView()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
}
@property (nonatomic, strong) UICollectionView * filterConfigView;// 滤镜view
//当前选中的cell号，号码唯一，当前只能选中一个号
@property(nonatomic,assign) NSInteger selectedIdx;

@end



@implementation FilterView

- (instancetype)init{
    if (self = [super init]) {
        [self initConfigView];
    }
    return self;
}

- (void)initConfigView{
    _selectedIdx = 0;
    // flow Layout
    UICollectionViewFlowLayout *allFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    allFlowLayout.itemSize = CGSizeMake(KFilterCellWidth, KFilterCellHeight);
    allFlowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);//zw
    allFlowLayout.minimumLineSpacing = kFilterSpaceWidth;
    allFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //    _filterConfigView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:allFlowLayout];
    _filterConfigView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:allFlowLayout];
    _filterConfigView.allowsMultipleSelection = NO;
    _filterConfigView.showsHorizontalScrollIndicator = NO;
    _filterConfigView.showsVerticalScrollIndicator = NO;
    _filterConfigView.backgroundColor = [UIColor clearColor];
    _filterConfigView.dataSource = self;
    _filterConfigView.delegate = self;
    _filterConfigView.scrollsToTop = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_filterConfigView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:0];
    });
    
    [self addSubview:_filterConfigView];
    
    [_filterConfigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [_filterConfigView registerClass:[FilterCell class] forCellWithReuseIdentifier:@"filterCell"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kEffectNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    
    cell.effectIndex = (int)indexPath.row;
    return cell;
}

//NemoFilterCell *lastCell;
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIdx = indexPath.row;
    
    if([self.delegate respondsToSelector:@selector(specialEffectFilterChanged:)]){
        [self.delegate specialEffectFilterChanged:(int)indexPath.row];
    }
    
    FilterCell *cell = (FilterCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.layer.borderWidth = 1.5;
    cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#ff8c10"]CGColor];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterCell *cell = (FilterCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 0;
    cell.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _selectedIdx) {
        cell.contentView.layer.borderWidth = 1.5;
        cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#ff8c10"] CGColor];
    }else{
        cell.contentView.layer.borderWidth = 0;
        cell.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    cell.contentView.layer.borderWidth = 0;
    cell.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
}

@end
