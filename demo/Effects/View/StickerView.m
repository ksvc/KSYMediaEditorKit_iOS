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
@property (nonatomic, strong) NSMutableDictionary *cellDic;

@end


@implementation StickerView

- (instancetype)init{
    if (self = [super init]) {
        [self initConfigView];
        self.cellDic = [[NSMutableDictionary alloc] init];
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
    _stickerConfigView.allowsMultipleSelection = NO;
    _stickerConfigView.dataSource = self;
    _stickerConfigView.delegate = self;
    _stickerConfigView.scrollsToTop = NO;
    [self selectStickerIdx:0];
    [self addSubview:_stickerConfigView];
    
    [_stickerConfigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_stickerConfigView registerClass:[StickerCell class] forCellWithReuseIdentifier:@"stickerCell"];
    
    [_stickerConfigView reloadData];
}

- (void)selectStickerIdx:(NSInteger)idx{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_stickerConfigView selectItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        if([self.delegate respondsToSelector:@selector(StickerChanged:)]){
            [self.delegate StickerChanged:(int)idx];
        }
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[STFilterManager instance] STMaterialCount]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 每次先从字典中根据IndexPath取出唯一标识符
    NSString *identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"stickerCell%@", [NSString stringWithFormat:@"%@", indexPath]];
        [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
        // 注册Cell
        [self.stickerConfigView registerClass:[StickerCell class] forCellWithReuseIdentifier:identifier];
        
    }
    
    StickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
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
    StickerCell * cell = (StickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell downloadMaterial];
    
    if([self.delegate respondsToSelector:@selector(StickerChanged:)]){
        [self.delegate StickerChanged:(int)indexPath.row];
    }
}
@end
