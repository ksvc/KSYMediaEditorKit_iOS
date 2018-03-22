//
//  KSYRecordReverbCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYRecordReverbCell.h"


#import "KSYAudioEffectCommonLayout.h"
#import "KSYBgMusicModel.h"
#import "KSYRecordAECommonCell.h"

@interface KSYRecordReverbCell () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *reverbCollectionView;
@property(nonatomic, strong) NSMutableArray <KSYBgMusicModel *> *models;

@property(nonatomic, strong) NSIndexPath    *lastSelectedIndexPath;
@end

@implementation KSYRecordReverbCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviews];
    [self setupModels];
}

- (void)configSubviews{
    KSYAudioEffectCommonLayout *layout = [[KSYAudioEffectCommonLayout alloc] initSize:CGSizeMake(63,144 - 35-14 - 10)];
    self.reverbCollectionView.collectionViewLayout = layout;
    [self.reverbCollectionView registerNib:[UINib nibWithNibName:[KSYRecordAECommonCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYRecordAECommonCell className]];
    
    [self.reverbCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
    
    
}

- (void)setupModels{
    if (self.models == nil) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.models removeAllObjects];
    NSArray *voiceChangeImgagesArrsy = @[@"closeEffect",
                                         @"record_audio_effect_recording_room",
                                         @"record_audio_effect_vocal_concert",
                                         @"record_audio_effect_KTV",
                                         @"record_audio_effect_stage"
                                         ];
    NSArray *voiceChangeNamesArrsy = @[@"",@"录音棚",@"演唱会",@"KTV",@"舞台"];
    
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
        [self.delegate audioEffectType:KSYMEAudioEffectTypeChangeReverb andValue:indexPath.row];
    }
}
@end
