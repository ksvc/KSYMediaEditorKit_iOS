//
//  KSYEditAnimateImageCell.m
//  demo
//
//  Created by sunyazhou on 2017/8/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditAnimateImageCell.h"
#import "KSYAudioEffectCommonLayout.h"
#import "KSYBgMusicModel.h"
#import "KSYEditStickerCollectionViewCell.h"

@interface KSYEditAnimateImageCell ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *subtitleCollectionView;
@property (nonatomic, strong) NSMutableArray <KSYBgMusicModel *> *models; //这里复用bgm的model
@end

@implementation KSYEditAnimateImageCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviews];
    [self setupModels];
    
    [self.subtitleCollectionView reloadData];
}

- (void)configSubviews{
    KSYAudioEffectCommonLayout *layout = [[KSYAudioEffectCommonLayout alloc] initSize:CGSizeMake(63,63)];
    self.subtitleCollectionView.collectionViewLayout = layout;
    [self.subtitleCollectionView registerNib:[UINib nibWithNibName:[KSYEditStickerCollectionViewCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYEditStickerCollectionViewCell className]];
    
    [self.subtitleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
    
    self.subtitleCollectionView.dataSource = self;
    self.subtitleCollectionView.delegate = self;
    
}

- (void)prepareForReuse{
    [self.subtitleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
}

- (void)setupModels{
    if (self.models == nil) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.models removeAllObjects];
    
    NSMutableArray *imgagesNameArrsy = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < 10; i++) {
        NSString *str = [NSString stringWithFormat:@"dynamic_image0%d",i+1];
        [imgagesNameArrsy addObject:str];
    }
    
    for (int i = 0; i < imgagesNameArrsy.count; i++) {
        NSString *imageName = [imgagesNameArrsy objectAtIndex:i];
        KSYBgMusicModel *audioModel = [[KSYBgMusicModel alloc] init];
        audioModel.bgmImageName = imageName;
        
        [self.models addObject:audioModel];
    }
}


#pragma mark -
#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYEditStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditStickerCollectionViewCell className]  forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(editPanelStickerType:selectedIndex:)]) {
        [self.delegate editPanelStickerType:KSYMEEditStickerTypeAnimatedImage selectedIndex:indexPath.row];
    }
}
@end
