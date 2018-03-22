//
//  KSYMVView.m
//  demo
//
//  Created by sunyazhou on 2017/9/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYMVView.h"
#import "KSYMVModel.h"
#import "KSYAudioEffectCommonLayout.h"
#import "KSYEditMVCell.h"
@interface KSYMVView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic, weak) IBOutlet UICollectionView *mvCollectionView;
@property(nonatomic, strong) NSMutableArray <KSYMVModel *> *models;
@property(nonatomic, strong) NSIndexPath    *lastSelectedIndexPath;
@end

@implementation KSYMVView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviews];
    [self setupModels];
}

- (void)configSubviews{
    self.mvCollectionView.dataSource = self;
    self.mvCollectionView.delegate = self;
    KSYAudioEffectCommonLayout *layout = [[KSYAudioEffectCommonLayout alloc] initSize:CGSizeMake(63,144 - 35-14 - 10)];
    self.mvCollectionView.collectionViewLayout = layout;
    [self.mvCollectionView registerNib:[UINib nibWithNibName:[KSYEditMVCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYEditMVCell className]];
    
    [self.mvCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
    
    
}

- (void)setupModels{
    if (self.models == nil) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.models removeAllObjects];
    NSArray *mvImgagesArrsy = @[
                                @"closeEffect",
                                @"mv-101.png",
                                @"mv-102.png",
                                @"mv-103.png"
                                ];
    NSArray *mvNamesArrsy = @[@"",@"Fashion Shots",@"Lucky You",@"Party Time"];
    NSArray *mvResNameArrsy = @[@"",@"mv-101",@"mv-102",@"mv-103"];
    
    for (int i = 0; i < mvImgagesArrsy.count; i++) {
        NSString *imageName = [mvImgagesArrsy objectAtIndex:i];
        NSString *mvName = [mvNamesArrsy objectAtIndex:i];
        NSString *mvResName = [mvResNameArrsy objectAtIndex:i];
        KSYMVModel *mvModel = [[KSYMVModel alloc] init];
        mvModel.bgmImage = imageName;
        mvModel.mvName = mvName;
        mvModel.mvResName = mvResName;
        if (i == 0) {
            mvModel.isSelected = YES;
        }
        [self.models addObject:mvModel];
    }
    
    self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark -
#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYEditMVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditMVCell className]  forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYMVModel *lastMVModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
    KSYMVModel *selectedModel = [self.models objectAtIndex:indexPath.row];
    if (self.lastSelectedIndexPath == indexPath) {
        //选择同一个cell
        selectedModel.isSelected = !selectedModel.isSelected;
    } else {
        lastMVModel.isSelected = NO;
        [collectionView reloadItemsAtIndexPaths:@[self.lastSelectedIndexPath]];
        selectedModel.isSelected = YES;
    }
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    self.lastSelectedIndexPath = indexPath;
    [collectionView scrollToItemAtIndexPath:self.lastSelectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(mvDidSelectedMVPathName:)]) {
        if (selectedModel.isSelected) {
            [self.delegate mvDidSelectedMVPathName:selectedModel.mvResName];
        } else {
            [self.delegate mvDidSelectedMVPathName:@""];
        }
    }
}
@end
