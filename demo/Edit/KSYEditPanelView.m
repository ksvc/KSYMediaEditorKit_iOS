//
//  KSYEditPanelView.m
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditPanelView.h"

#import "KSYEditPanelCellLayout.h"

#import "KSYBeautyFilterCell.h"
#import "KSYBeautyFlowLayout.h"

#import "KSYEditBGMCell.h"
#import "KSYRecordVoiceChangeCell.h"
#import "KSYRecordReverbCell.h"
#import "KSYEditStickerCell.h"
#import "KSYEditSubtitleCell.h"
#import "KSYEditWatermarkCell.h"
#import "KSYEditVideoTrimCell.h"
#import "KSYEditTimesCell.h"
#import "KSYEditAnimateImageCell.h"
#import "KSYEditMVCell.h"

NSString * const kKSYEditPanelTitleBeauty         = @"美颜";
NSString * const kKSYEditPanelTitleWatermark      = @"水印";
NSString * const kKSYEditPanelTitleMultiple       = @"倍速";
NSString * const kKSYEditPanelTitleVideoTrim      = @"剪裁";
NSString * const kKSYEditPanelTitleMusic          = @"音乐";
NSString * const kKSYEditPanelTitleChangeVoice    = @"变声";
NSString * const kKSYEditPanelTitleReverb         = @"混响";
NSString * const kKSYEditPanelTitleStricker       = @"贴纸";
NSString * const kKSYEditPanelTitleSubtitle       = @"字幕";
NSString * const kKSYEditPanelTitleAnimationImage = @"动图";
//NSString * const kKSYEditPanelTitleMV             = @"MV";

@interface KSYEditPanelView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
KSYBeautyFilterCellDelegate,
KSYEditWatermarkCellDelegate,
KSYBGMusicViewDelegate,
KSYEditLevelDelegate,
KSYEditWatermarkCellDelegate
>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *panelHeights; //所有面板的高度

@end

@implementation KSYEditPanelView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.titles =  @[
                     kKSYEditPanelTitleBeauty,
                     kKSYEditPanelTitleWatermark,
                     kKSYEditPanelTitleMultiple,
                     kKSYEditPanelTitleVideoTrim,
                     kKSYEditPanelTitleMusic,
                     kKSYEditPanelTitleChangeVoice,
                     kKSYEditPanelTitleReverb,
                     kKSYEditPanelTitleStricker,
                     kKSYEditPanelTitleSubtitle,
                     kKSYEditPanelTitleAnimationImage
                     ];
    self.panelHeights = @[@140,@49,@140,@(150+70),@180,@140,@140,@100,@100,@100];
    
    [self.collectionView mas_makeConstraints:^
     (MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //cell
    [self registerCellByCellName:[KSYBeautyFilterCell className]];
    //音乐cell
    [self registerCellByCellName:[KSYEditBGMCell className]];
    //变声cell
    [self registerCellByCellName:[KSYRecordVoiceChangeCell className]];
    //混响cell
    [self registerCellByCellName:[KSYRecordReverbCell className]];
    //贴纸
    [self registerCellByCellName:[KSYEditStickerCell className]];
    //字幕
    [self registerCellByCellName:[KSYEditSubtitleCell className]];
    //水印
    [self registerCellByCellName:[KSYEditWatermarkCell className]];
    //视频裁剪
    [self registerCellByCellName:[KSYEditVideoTrimCell className]];
    //倍数
    [self registerCellByCellName:[KSYEditTimesCell className]];
    //动态贴纸
    [self registerCellByCellName:[KSYEditAnimateImageCell className]];
    //MV
    [self registerCellByCellName:[KSYEditMVCell className]];
    
    [self changeLayoutByIndex:0]; //从0开始
    
    self.levelModel = [[KSYEditSpeedLevelModel alloc] init];
    self.levelModel.level = 1;
}

- (void)registerCellByCellName:(NSString *)cellName{
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellName];
}
//

#pragma mark - 
#pragma mark -  Public methods  对外方法
- (CGFloat)panelHeightForIndex:(NSUInteger)index{
    if (index > self.panelHeights.count - 1) {return 0; }
    return [[self.panelHeights objectAtIndex:index] floatValue];
}
- (void)changeLayoutByIndex:(NSUInteger)index{
    if (index > self.panelHeights.count - 1) {return; }
    CGFloat height = [[self.panelHeights objectAtIndex:index] floatValue];
    
    self.collectionView.collectionViewLayout = [[KSYEditPanelCellLayout alloc] initSize:CGSizeMake(kScreenWidth, height)];
    
    
    NSIndexPath *scrollIndex = [NSIndexPath indexPathForRow:index inSection:0];
    [self handleCellForIndexPath:scrollIndex];
    
    [self.collectionView scrollToItemAtIndexPath:scrollIndex
                                           atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)handleCellForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath == nil) { return; }
    if (indexPath.row > self.titles.count - 1) { return; }
    
    NSString *title = [self.titles objectAtIndex:indexPath.row];
    if ([title isEqualToString:kKSYEditPanelTitleVideoTrim]) {
        KSYEditVideoTrimCell *cell = (KSYEditVideoTrimCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            cell.videoURL = self.trimVideoURL;
        }
    }
    
}


#pragma mark -
#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = nil;
    NSString *title = self.titles[indexPath.row];
    if ([title isEqualToString:kKSYEditPanelTitleBeauty]) {
        KSYBeautyFilterCell *beautyCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYBeautyFilterCell className] forIndexPath:indexPath];
        beautyCell.delegate = self;
        cell = beautyCell;
        //
    } else if ([title isEqualToString:kKSYEditPanelTitleWatermark]){
        KSYEditWatermarkCell *watermarkCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditWatermarkCell className] forIndexPath:indexPath];
        watermarkCell.delegate = self;
        watermarkCell.show = self.showWatermark;
        cell = watermarkCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleMultiple]){
        KSYEditTimesCell *timesLevelCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditTimesCell className] forIndexPath:indexPath];
        timesLevelCell.delegate = self;
        timesLevelCell.levelModel = self.levelModel;
        cell = timesLevelCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleVideoTrim]){
        KSYEditVideoTrimCell *videoTrimCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditVideoTrimCell className] forIndexPath:indexPath];
        videoTrimCell.delegate = self.videoTrimDelegate;
        videoTrimCell.videoURL = self.trimVideoURL;
        cell = videoTrimCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleMusic]){
        KSYEditBGMCell *bgmCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditBGMCell className] forIndexPath:indexPath];
        bgmCell.delegate = self;
        bgmCell.audioEffectDelegate = self.audioEffectDelegate;
        cell = bgmCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleChangeVoice]){
        KSYRecordVoiceChangeCell *voiceChangeCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYRecordVoiceChangeCell className] forIndexPath:indexPath];
        //音效代理透传
        voiceChangeCell.delegate = self.audioEffectDelegate;
        cell = voiceChangeCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleReverb]){
        KSYRecordReverbCell *reverbCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYRecordReverbCell className] forIndexPath:indexPath];
        //音效代理透传
        reverbCell.delegate = self.audioEffectDelegate;
        cell = reverbCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleStricker]){
        KSYEditStickerCell *stickerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditStickerCell className] forIndexPath:indexPath];
        stickerCell.delegate = self.stickerDelegate;
        cell = stickerCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleSubtitle]){
        KSYEditSubtitleCell *subtitleCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditSubtitleCell className] forIndexPath:indexPath];
        subtitleCell.delegate = self.stickerDelegate;
        cell = subtitleCell;
    } else if ([title isEqualToString:kKSYEditPanelTitleAnimationImage]){
        KSYEditAnimateImageCell *animatedImgCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditAnimateImageCell className] forIndexPath:indexPath];
        animatedImgCell.delegate = self.stickerDelegate;
        cell = animatedImgCell;
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYBeautyFilterCell className] forIndexPath:indexPath];
    }
    
    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = kScreenWidth;
    float currentPage = scrollView.contentOffset.x / pageWidth;
    if ([self.delegate respondsToSelector:@selector(editPanelView:scrollPage:)]) {
        [self.delegate editPanelView:self scrollPage:currentPage];
    }
}

#pragma mark - 
#pragma mark - KSYBeautyFilterCell Delegate 美颜代理
- (void)beautyFilterCell:(KSYBeautyFilterCell *)cell
              filterType:(KSYMEBeautyKindType)type{
    if ([self.delegate respondsToSelector:@selector(editPanelView:filterType:)]) {
        [self.delegate editPanelView:self filterType:type];
    }
}

#pragma mark -
#pragma mark - 背景音乐 Delegate 代理
- (void)bgMusicView:(UIView *)view
       songFilePath:(NSString *)filePath{
    if ([self.delegate respondsToSelector:@selector(editPanelView:songFilePath:)]) {
        [self.delegate editPanelView:self songFilePath:filePath];
    }
}

- (void)bgMusicView:(UIView *)view
    audioVolumnType:(KSYMEAudioVolumnType)type
           andValue:(CGFloat)value{
    if ([self.delegate respondsToSelector:@selector(editPanelView:audioVolumnType:andValue:)]) {
        [self.delegate editPanelView:self audioVolumnType:type andValue:value];
    }
}

#pragma mark -
#pragma mark - 倍速调节代理 Delegate 代理
- (void)editLevel:(NSInteger)index{
    if ([self.levelDelegate respondsToSelector:@selector(editLevel:)]) {
        [self.levelDelegate editLevel:index];
    }
    self.levelModel.level = index;
}

#pragma mark -
#pragma mark - 水印 代理
- (void)editWatermarkCell:(KSYEditWatermarkCell *)cell
            showWatermark:(BOOL)isShowWatermark{
    if ([self.watermarkDelegate respondsToSelector:@selector(editWatermarkCell:showWatermark:)]) {
        [self.watermarkDelegate editWatermarkCell:cell showWatermark:isShowWatermark];
    }
    self.showWatermark = isShowWatermark;
    
}


- (void)dealloc{
    
}
@end
