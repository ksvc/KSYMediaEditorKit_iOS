//
//  NemoFilterView.m
//  Nemo
//
//  Created by ksyun on 17/4/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "StickerView.h"
#import "StickerCell.h"
#import "KSYSTFilter.h"
#import "STFilterManager.h"
#import "senseAr.h"

#define KFilterCellHeight 100
#define KFilterCellWidth 100
#define kFilterSpaceWidth 16
#define kEffectNum  7

@interface StickerView()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
}
@property (nonatomic, strong) UICollectionView * stickerConfigView;// 贴纸view


@end


@implementation StickerView

- (instancetype)init{
    if (self = [super init]) {
        [self initConfigView];
    }
    return self;
}

- (void)initConfigView{
    // flow Layout
    UICollectionViewFlowLayout *allFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    allFlowLayout.itemSize = CGSizeMake(KFilterCellWidth, KFilterCellHeight);
    allFlowLayout.sectionInset = UIEdgeInsetsMake(20, 16, 16, 0);
    allFlowLayout.minimumLineSpacing = kFilterSpaceWidth;
    allFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _stickerConfigView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:allFlowLayout];
    _stickerConfigView.showsHorizontalScrollIndicator = NO;
    _stickerConfigView.backgroundColor = [UIColor clearColor];
    _stickerConfigView.dataSource = self;
    _stickerConfigView.delegate = self;
    _stickerConfigView.scrollsToTop = NO;
    [self addSubview:_stickerConfigView];
    
    [_stickerConfigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_stickerConfigView registerClass:[StickerCell class] forCellWithReuseIdentifier:@"stickerCell"];
    
    [_stickerConfigView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[STFilterManager instance] STMaterialCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    StickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"stickerCell" forIndexPath:indexPath];
    
    SenseArMaterial * material;
    if(indexPath.row >0){
        material= [[STFilterManager instance]materialAtIndex:(indexPath.row -1)];
    }else{
        material = nil;
    }
    cell.material = material;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //选中后添加一个边框
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 1.5;
    cell.layer.borderColor = [[UIColor colorWithHexString:@"#ff8c10"]CGColor];
    
    if([self.delegate respondsToSelector:@selector(StickerChanged:)]){
        [self.delegate StickerChanged:(int)indexPath.row];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 0;
    cell.layer.borderColor = [[UIColor clearColor]CGColor];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.borderWidth = 0;
    cell.layer.borderColor = [[UIColor clearColor]CGColor];
    
}
@end

