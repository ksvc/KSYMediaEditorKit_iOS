//
//  KSYRecordAudioEffectView.m
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYRecordAudioEffectView.h"

#import "KSYRecordAELayout.h"
#import "KSYRecordVoiceChangeCell.h"
#import "KSYRecordReverbCell.h"

@interface KSYRecordAudioEffectView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *audioEffectCollectionView;
@property (weak, nonatomic) IBOutlet HMSegmentedControl *audioEffectSegment;

@end

@implementation KSYRecordAudioEffectView
- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self configAESubviews];
}

- (void)configAESubviews{
    
    //音效切换的collectionView
    [self.audioEffectCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-44);
    }];
    self.audioEffectCollectionView.backgroundColor = [UIColor clearColor];//[UIColor jk_colorWithHex:0x07080b andAlpha:0.8];
    //注册
    [self.audioEffectCollectionView registerNib:[UINib nibWithNibName:[KSYRecordVoiceChangeCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYRecordVoiceChangeCell className]];
    [self.audioEffectCollectionView registerNib:[UINib nibWithNibName:[KSYRecordReverbCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYRecordReverbCell className]];
    
    
    self.audioEffectCollectionView.dataSource = self;
    self.audioEffectCollectionView.delegate = self;
    KSYRecordAELayout *layout = [[KSYRecordAELayout alloc] initSize:CGSizeMake(kScreenMinLength, 142)];
    self.audioEffectCollectionView.collectionViewLayout = layout;
    
    
    //底部segement
    [self.audioEffectSegment mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.audioEffectCollectionView.mas_bottom);
    }];
    self.audioEffectSegment.sectionTitles = @[@"变声",@"混响"];
    self.audioEffectSegment.frame = CGRectMake(0, 20, self.width, 40);
    self.audioEffectSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.audioEffectSegment.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.audioEffectSegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.audioEffectSegment.shouldAnimateUserSelection = NO;
    self.audioEffectSegment.selectionIndicatorColor = [UIColor redColor];
    self.audioEffectSegment.selectionIndicatorBoxColor = [UIColor redColor];
    [self.audioEffectSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        return attString;
    }];
    
}

- (void)resetLayoutWithSize:(CGSize)size{
    KSYRecordAELayout *layout = [[KSYRecordAELayout alloc] initSize:size];
    self.audioEffectCollectionView.collectionViewLayout = layout;
}
#pragma mark - 
#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.audioEffectSegment.sectionTitles.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    if (indexPath.row == 0) {
        KSYRecordVoiceChangeCell *voiceChangeCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYRecordVoiceChangeCell className] forIndexPath:indexPath];
        cell = voiceChangeCell;
        voiceChangeCell.delegate = self.delegate;  //透传代理到cell
    } else{
        KSYRecordReverbCell *reverbCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYRecordReverbCell className] forIndexPath:indexPath];
        cell = reverbCell;
        reverbCell.delegate = self.delegate; //透传代理到cell
    }
        
    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = kScreenWidth;
    float currentPage = scrollView.contentOffset.x / pageWidth;
    [self.audioEffectSegment setSelectedSegmentIndex:currentPage animated:YES];
}
- (IBAction)valueChange:(HMSegmentedControl *)sender {
    NSIndexPath *scrollIndex = [NSIndexPath indexPathForRow:sender.selectedSegmentIndex inSection:0];
    [self.audioEffectCollectionView scrollToItemAtIndexPath:scrollIndex
                                      atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

@end
