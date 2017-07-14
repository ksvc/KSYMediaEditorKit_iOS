//
//  KSYRecordVoiceChangeCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYRecordVoiceChangeCell.h"

#import "KSYAudioEffectCommonLayout.h"
#import "KSYBgMusicModel.h"
#import "KSYRecordAECommonCell.h"

@interface KSYRecordVoiceChangeCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *voiceChangeCollectionView;
@property(nonatomic, strong) NSMutableArray <KSYBgMusicModel *> *models;

@property(nonatomic, strong) NSIndexPath    *lastSelectedIndexPath;
@end

@implementation KSYRecordVoiceChangeCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    [self configSubviews];
    [self setupModels];
}

- (void)configSubviews{
    KSYAudioEffectCommonLayout *layout = [[KSYAudioEffectCommonLayout alloc] initSize:CGSizeMake(63,144 - 35-14 - 10)];
    self.voiceChangeCollectionView.collectionViewLayout = layout;
    [self.voiceChangeCollectionView registerNib:[UINib nibWithNibName:[KSYRecordAECommonCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYRecordAECommonCell className]];
    
    [self.voiceChangeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
    
    
}

- (void)setupModels{
    if (self.models == nil) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.models removeAllObjects];
    NSArray *voiceChangeImgagesArrsy = @[@"关闭效果",
                                         @"record_audio_effect_uncle",
                                         @"record_audio_effect_lolita",
                                         @"record_audio_effect_serious",
                                         @"record_audio_effect_robort"
                                         ];
    NSArray *voiceChangeNamesArrsy = @[@"",@"大叔",@"萝莉",@"庄重",@"机器人"];
    
    for (int i = 0; i < voiceChangeImgagesArrsy.count; i++) {
        NSString *imageName = [voiceChangeImgagesArrsy objectAtIndex:i];
        NSString *voiceName = [voiceChangeNamesArrsy objectAtIndex:i];
        KSYBgMusicModel *audioModel = [[KSYBgMusicModel alloc] init];
        audioModel.bgmImageName = imageName;
        audioModel.bgmName = voiceName;
        if (i == 0) {
            audioModel.isSelected = YES;
        }
        [self.models addObject:audioModel];
    }

    self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark -
#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYRecordAECommonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYRecordAECommonCell className]  forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYBgMusicModel *lastFilterModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
    KSYBgMusicModel *selectedModel = [self.models objectAtIndex:indexPath.row];
    if (self.lastSelectedIndexPath == indexPath) {
        //选择同一个cell
        selectedModel.isSelected = !selectedModel.isSelected;
    } else {
        lastFilterModel.isSelected = NO;
        [collectionView reloadItemsAtIndexPaths:@[self.lastSelectedIndexPath]];
        selectedModel.isSelected = YES;
    }
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    self.lastSelectedIndexPath = indexPath;
    [collectionView scrollToItemAtIndexPath:self.lastSelectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(audioEffectType:andValue:)]) {
        [self.delegate audioEffectType:KSYMEAudioEffectTypeChangeVoice andValue:indexPath.row];
    }
}
@end
