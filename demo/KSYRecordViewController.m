//
//  KSYRecordViewController.m
//  demo
//
//  Created by sunyazhou on 2017/7/6.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYRecordViewController.h"
#import "RecordProgressView.h"
#import "KSYEditViewController.h"

#import <libksygpulive/libksygpufilter.h>

#import "KSYBeautyFlowLayout.h"

#import "KSYBeautyFilterCell.h"
#import "KSYDynamicEffectCell.h"
#import "KSYFilterCell.h"

#import "FilterManager.h"

#import "KSYBGMusicView.h"
#import "KSYRecordAudioEffectView.h"

#import <KMCVStab/KMCVStab.h>

static NSString *const kKMCToken = @"557dd71f0c01c67ab36d5318b2cdfb9f";

@interface KSYRecordViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
KSYCameraRecorderDelegate,
KSYMEConcatorDelegate,
StickerViewDelegate,
KSYFilterCellDelegate,
KSYBeautyFilterCellDelegate,
KSYBGMusicViewDelegate,
KSYAudioEffectDelegate
>



// recorder
@property (nonatomic, strong) KSYCameraRecorder *recorder;
// concator
@property (nonatomic, strong) KSYMEConcator *concator;
// recorded video list
@property (nonatomic, strong) NSMutableArray *videoList;
// 当前使用的滤镜
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>* curFilter;

// UI

@property (weak, nonatomic) IBOutlet UIButton *antiShakeBtn;

@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UIButton *beautyBtn;
@property (weak, nonatomic) IBOutlet UIButton *bgmBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioEffectBtn;

@property (weak, nonatomic) IBOutlet RecordProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;


@property (nonatomic, strong) IBOutlet UIView *beautyView; //美颜视图
@property (strong, nonatomic) IBOutlet HMSegmentedControl *beaurtySegment;
@property (weak, nonatomic) IBOutlet UICollectionView *beautyCollectionView;

@property (strong, nonatomic) IBOutlet KSYBGMusicView *bgMusicView;

@property (copy, nonatomic) NSString *curBgmPath;
@property (strong, nonatomic) IBOutlet KSYRecordAudioEffectView *aeView;
@property (weak, nonatomic) IBOutlet UISlider *exposureSlider;
// 对焦框
@property (nonatomic, strong) UIImageView *foucsCursor;
//当前触摸缩放因子
@property (nonatomic, assign) CGFloat currentPinchZoomFactor;

@property (nonatomic, assign) CVPixelBufferRef cacheBuffer; //解决防抖内存过高问题
@end

@implementation KSYRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestKCMAuth];
    [self generateRecorder];
    [self configSubviews];
    [self addGestures];
    [self registerObservers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_recorder startPreview:self.view];
    [_recorder.bgmPlayer startPlayBgm:_curBgmPath isLoop:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // 关闭摄像头采集和预览
    [_recorder stopPreview];
}

- (void)dealloc{
    if (self.cacheBuffer) {
        CVPixelBufferRelease(self.cacheBuffer);
        self.cacheBuffer = NULL;
    }
//    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)configSubviews{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.antiShakeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.closeBtn.mas_centerY);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@36);
        make.height.equalTo(@24);
    }];
    
    [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_closeBtn);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
    
    [_torchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_closeBtn);
        make.right.equalTo(_switchBtn.mas_left).offset(-34);
    }];
    
    
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(52);
        make.bottom.equalTo(self.view).offset(-53);
    }];
    
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(_deleteBtn);
    }];
    
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-52);
        make.bottom.equalTo(self.view.mas_bottom).offset(-53);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_deleteBtn.mas_top).offset(-56);
        make.height.mas_equalTo(4);
    }];
    
    [_beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(90);
        make.bottom.equalTo(_progressView.mas_top).offset(-17);
    }];
    
    [_bgmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_beautyBtn);
        make.centerX.equalTo(self.view);
    }];
    
    [_audioEffectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_beautyBtn);
        make.right.equalTo(self.view).offset(-90);
    }];
    
    //美颜相关视图
    [self.beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@184);
    }];
    self.beautyView.backgroundColor = [UIColor jk_colorWithHex:0x07080b andAlpha:0.8];
    
    [self.beaurtySegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.beautyView);
        make.height.equalTo(@44);
    }];
    self.beaurtySegment.sectionTitles = @[@"美颜",@"动态特效",@"滤镜"];
    self.beaurtySegment.frame = CGRectMake(0, 20, self.view.width, 40);
    self.beaurtySegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.beaurtySegment.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.beaurtySegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.beaurtySegment.shouldAnimateUserSelection = NO;
    self.beaurtySegment.selectionIndicatorColor = [UIColor redColor];
    self.beaurtySegment.selectionIndicatorBoxColor = [UIColor redColor];
    [self.beaurtySegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    
    self.beautyCollectionView.backgroundColor = [UIColor clearColor];//[UIColor jk_colorWithHex:0x07080b andAlpha:0.8];
    [self.beautyView addSubview:self.beaurtySegment];
    //美颜所有视图切换的collectionView
    [self.beautyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.beautyView);
        make.bottom.mas_equalTo(self.beaurtySegment.mas_top);
    }];
    
    //注册cell
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYBeautyFilterCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYBeautyFilterCell className]];
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYDynamicEffectCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYDynamicEffectCell className]];
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYFilterCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYFilterCell className]];
    
    //布局
    self.beautyCollectionView.collectionViewLayout = [[KSYBeautyFlowLayout alloc] initSize:CGSizeMake(kScreenWidth, 140)];
    self.beautyCollectionView.multipleTouchEnabled = NO;
    self.beautyCollectionView.allowsMultipleSelection = NO;
    
    //音乐
    [self.view addSubview:self.bgMusicView];
    //背景音乐相关视图
    [self.bgMusicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.height.equalTo(@(253));
    }];
    self.bgMusicView.backgroundColor = self.beautyView.backgroundColor;
    //设置代理回调
    self.bgMusicView.delegate = self;
    //设置音效代理回调
    self.bgMusicView.audioEffectDelegate = self;
    
    //音效
    [self.view addSubview:self.aeView];
    [self.aeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.height.equalTo(@(186));
    }];
    self.aeView.backgroundColor = self.bgMusicView.backgroundColor;
    self.aeView.delegate = self;
}

- (void)addGestures{
    // tap
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBGView:)];
    [self.view addGestureRecognizer:tapGes];
    tapGes.cancelsTouchesInView = NO;
    // pinch
    // etc
}

- (void)registerObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRecordInterrupted:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRecordInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)onRecordInterrupted:(NSNotification *)notification{
    // 切后台、siri、电话打断需要停止录制
    NSString *notifyName = notification.name;
    if ([notifyName isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        if ([_recorder isRecording]) {
            [self didClickRecordBtn:_recordBtn];
        }
    }else if ([notifyName isEqualToString:AVAudioSessionInterruptionNotification]){
        NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
        if (interruptionType.unsignedIntegerValue == AVAudioSessionInterruptionTypeBegan) {
            if ([_recorder isRecording]) {
                [self didClickRecordBtn:_recordBtn];
            }
        }
    }
}

- (void)generateRecorder
{
    if (!_recorder){
        _recorder = [[KSYCameraRecorder alloc] init];
        _recorder.delegate = self;
    }
    
    RecordConfigModel *recordModel = _models.firstObject;
    
    CGSize resolution = [recordModel getResolutionFromPreset];
    _recorder.previewDimension = resolution;
    _recorder.outputVideoDimension = resolution;
    
    _recorder.videoFrameRate = (int)recordModel.fps;
    
    _recorder.videoBitrate = (int)recordModel.videoKbps;
    
    _recorder.audioBitrate = (int)recordModel.audioKbps;
    
    _recorder.filter = [[KSYBeautifyProFilter alloc] init];

    // 默认开启 前置摄像头
    _recorder.cameraPosition = AVCaptureDevicePositionFront;
    // 设置最短、最长录制时间
    _recorder.minRecDuration = 5;
    _recorder.maxRecDuration = 60;
}



/**
 是否开启视频防抖

 @param enable 开启或关闭
 */
- (void)enableAntiShakeFeature:(BOOL)enable{
    [[KMCVStab sharedInstance] setEnableStabi:enable];
    if (enable) {
        __weak typeof(self) weakSelf = self;
        self.recorder.videoProcessingCallback = ^(CMSampleBufferRef sampleBuffer) {
            //为媒体数据设置一个CMSampleBufferRef
            CVPixelBufferRef lockSampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            //锁定 pixel buffer 的基地址
            CVPixelBufferLockBaseAddress(lockSampleBuffer, 0);
            //得到修改前sample的pix的基地址
            void *pxdata = CVPixelBufferGetBaseAddress(lockSampleBuffer);
            
            size_t inputW = CVPixelBufferGetWidth(lockSampleBuffer);
            size_t inputH = CVPixelBufferGetHeight(lockSampleBuffer);
            
            BOOL needBuild = NO;
            if (weakSelf.cacheBuffer == NULL){ needBuild = YES; }
            else if (CVPixelBufferGetWidth(weakSelf.cacheBuffer) != inputW ||
                       CVPixelBufferGetHeight(weakSelf.cacheBuffer) != inputH) {
                needBuild = YES;
            }
            //检查是否需要重建缓冲
            if (needBuild) {
                CVPixelBufferRef stashBuffer = weakSelf.cacheBuffer;
                if (stashBuffer) { CVPixelBufferRelease(stashBuffer); }
                // empty IOSurface properties dictionary
                CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
                
                CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, inputW, inputH, kCVPixelFormatType_32BGRA, attrs, &stashBuffer);
                if (err) {
                    NSLog(@"Create local pixel buffer error:%d", err);
                } else {
                    weakSelf.cacheBuffer = stashBuffer;
                }
                CFRelease(empty);
                CFRelease(attrs);
            }
            
            [[KMCVStab sharedInstance] process:sampleBuffer outBuffer:weakSelf.cacheBuffer];
            CVPixelBufferLockBaseAddress(weakSelf.cacheBuffer, 0);
            //得到修改后的pix地址
            void *px2data = CVPixelBufferGetBaseAddress(weakSelf.cacheBuffer);
            memcpy(pxdata, px2data, CVPixelBufferGetDataSize(weakSelf.cacheBuffer));
            //解锁
            CVPixelBufferUnlockBaseAddress(lockSampleBuffer, 0);
            CVPixelBufferUnlockBaseAddress(weakSelf.cacheBuffer, 0);
            
        };
    } else {
        self.recorder.videoProcessingCallback = nil;
        if (self.cacheBuffer) {
            CVPixelBufferRelease(self.cacheBuffer);
            self.cacheBuffer = NULL;
        }
    }
}



- (void)stopPreview{
    [_recorder stopPreview];
}

// 关闭
- (void)close{
    [self stopPreview];
    [self.navigationController popViewControllerAnimated:YES];
}

// 隐藏特效按钮
- (void)hideEffectBtns{
    _beautyBtn.hidden = YES;
    _bgmBtn.hidden = YES;
    _audioEffectBtn.hidden = YES;
    _recordBtn.hidden = YES;
}

// 展示特效按钮
- (void)displayEffectBtns{
    _beautyBtn.hidden = NO;
    _bgmBtn.hidden = NO;
    _audioEffectBtn.hidden = NO;
    self.recordBtn.hidden = NO;
    
    
    _beautyView.hidden = YES;
    _bgMusicView.hidden = YES;
    self.aeView.hidden = YES;
}

- (void)requestKCMAuth{
    //魔方防抖初始化
    [[KMCVStab sharedInstance] authWithToken:kKMCToken onSuccess:^{
        NSLog(@"魔方防抖鉴权成功");
    } onFailure:^(AuthorizeError iErrorCode) {
        NSString * errorMessage = [[NSString alloc]initWithFormat:@"魔方防抖鉴权失败，错误码:%@", @(iErrorCode)];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:errorMessage delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }];
}
#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (UIImageView *)foucsCursor{
    if (!_foucsCursor) {
        _foucsCursor = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"camera_focus_red"]];
        _foucsCursor.frame = CGRectMake(80, 80, 80, 80);
        _foucsCursor.alpha = 0;
    }
    return _foucsCursor;
}
#pragma mark -
#pragma mark - UITableViewDelegate

#pragma mark -
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.beautyCollectionView) {
        UICollectionViewCell *beautyCell = nil;
        if (indexPath.row == 0) {
            //美颜
            KSYBeautyFilterCell *beautyFilterCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYBeautyFilterCell className] forIndexPath:indexPath];
            beautyFilterCell.delegate = self;
            beautyCell = beautyFilterCell;
        } else if (indexPath.row == 1) {
            //动态特效
            KSYDynamicEffectCell* Cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYDynamicEffectCell className] forIndexPath:indexPath];
            Cell.stickerView.delegate = self;
            beautyCell = Cell;
        } else {
            //滤镜
            KSYFilterCell *beautyFilterCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYFilterCell className] forIndexPath:indexPath];
            beautyFilterCell.delegate = self;
            beautyCell = beautyFilterCell;
        }
        return beautyCell;
    }
    return [[UICollectionViewCell alloc] init];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = kScreenWidth;
    float currentPage = scrollView.contentOffset.x / pageWidth;
    if (scrollView == self.beautyCollectionView) {
        [self.beaurtySegment setSelectedSegmentIndex:currentPage animated:YES];
    }
    
}

#pragma mark -
#pragma mark - CustomDelegate 自定义的代理


#pragma mark - StickerViewDelegate

- (void)StickerChanged:(KMCArMaterial*)material{
    if(material){
        
        if(material.strTriggerActionTip && material.strTriggerActionTip.length != 0){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.color = [UIColor clearColor];
            hud.label.text = material.strTriggerActionTip;
            hud.label.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
            hud.label.font = [UIFont systemFontOfSize:24];
            hud.label.shadowColor = [UIColor blackColor];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            });
        }
        
        if([[FilterManager instance].kmcFitler isMaterialDownloaded:material]){
            [[FilterManager instance].kmcFitler startShowingMaterial:material];
        }
        
        [_recorder setFilter:[FilterManager instance].kmcFitler.filter];
    }else{
        KSYBeautifyProFilter* beautyFilter = [[KSYBeautifyProFilter alloc] init];
        beautyFilter.grindRatio  = 0.5;
        beautyFilter.whitenRatio = 0.5;
        beautyFilter.ruddyRatio  = 0.5;
        [_recorder setFilter:beautyFilter];
    }
    
}

#pragma mark - KSYBeautyFilterCell Delegate 美颜代理
- (void)beautyFilterCell:(KSYBeautyFilterCell *)cell
              filterType:(KSYMEBeautyKindType)type
             filterIndex:(CGFloat)value{
    GPUImageOutput <GPUImageInput> *filter = [_recorder filter];
    KSYBeautifyProFilter* bf;
    
    if (![filter isMemberOfClass:[GPUImageFilterGroup class]]) {
        if([filter isMemberOfClass:[KSYBeautifyProFilter class]])
            bf = (KSYBeautifyProFilter*)filter;
        else{
            // TODO: 删除现存贴纸，改成美颜
        }
    }else{
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)filter;
        bf = (KSYBeautifyProFilter *)[fg filterAtIndex:0];
    }
    
    if (type == KSYMEBeautyKindTypeFaceWhiten) {
        bf.whitenRatio = value;
    } else if (type == KSYMEBeautyKindTypeGrind) {
        bf.grindRatio = value;
    } else if (type == KSYMEBeautyKindTypeRuddy) {
        bf.ruddyRatio = value;
    }
}

#pragma mark - KSYFilterCell Delegate 滤镜代理
- (void)filterCell:(KSYFilterCell *)cell filterType:(KSYMEFilterType)type filterIndex:(NSUInteger)index{
    //滤镜
    if (index == 0){//原型
        KSYBeautifyProFilter *bf = [[KSYBeautifyProFilter alloc] init];
        _curFilter = bf;
    }else{ // filter graph : proFilter->builtInSpecialEffects
        if (![_curFilter isMemberOfClass:[GPUImageFilterGroup class]]){
            KSYBeautifyProFilter    * bf = [[KSYBeautifyProFilter alloc] init];
            KSYBuildInSpecialEffects * sf = [[KSYBuildInSpecialEffects alloc] initWithIdx:index];
            if (_curFilter && [_curFilter isKindOfClass:[KSYBeautifyProFilter class]]) {
                KSYBeautifyProFilter *old_bf = (KSYBeautifyProFilter *)_curFilter;
                bf.grindRatio  = old_bf.grindRatio;
                bf.whitenRatio = old_bf.whitenRatio;
                bf.ruddyRatio  = old_bf.ruddyRatio;
            }
            [bf addTarget:sf];
            // 用滤镜组 将 滤镜 串联成整体
            GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
            [fg addFilter:bf];
            [fg addFilter:sf];
            
            [fg setInitialFilters:[NSArray arrayWithObject:bf]];
            [fg setTerminalFilter:sf];
            _curFilter = fg;
        }
        else{
            GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
            KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)[fg filterAtIndex:1];
            [sf setSpecialEffectsIdx: index];
        }
    }
    
    [_recorder setFilter:_curFilter];
}

#pragma mark - KSYBGMusicView 背景音乐代理
/**
 背景音乐的代理方法
 
 @param view 背景音乐的视图
 @param filePath 音乐本地路径
 */
- (void)bgMusicView:(UIView *)view
       songFilePath:(NSString *)filePath{
    _curBgmPath = filePath;
    if (!filePath || filePath.length == 0) {
        [_recorder.bgmPlayer stopPlayBgm:nil];
    }else{
        [_recorder.bgmPlayer stopPlayBgm:nil];
        [_recorder.bgmPlayer startPlayBgm:filePath isLoop:YES];
    }
}

/**
 麦克风音量和背景音乐的音量 代理方法
 
 @param view 背景音乐的视图
 @param type 音量类型
 @param value 变化的value
 */
- (void)bgMusicView:(UIView *)view
    audioVolumnType:(KSYMEAudioVolumnType)type
           andValue:(CGFloat)value{
    if (type == KSYMEAudioVolumnTypeMicphone) {
        [_recorder adjustMicrophoneVolume:value];
    } else if (type == KSYMEAudioVolumnTypeBgm) {
        [_recorder adjustBGMVolume:value];
    }
}


/**
 处理音效的代理方法
 @param type 音效类型
 @param value 变调级别
 */
- (void)audioEffectType:(KSYMEAudioEffectType)type
           andValue:(NSInteger)value{
    if (type == KSYMEAudioEffectTypeChangeTone) {
        _recorder.bgmPlayer.bgmPitch = value * 8;
        NSLog(@"变调级别:%zd",value);
    } else if (type == KSYMEAudioEffectTypeChangeVoice){
        _recorder.effectType = (KSYAudioEffectType)type;
        NSLog(@"变声:%zd",value);
    } else if (type == KSYMEAudioEffectTypeChangeReverb){
        _recorder.reverbType = (int)value;
        NSLog(@"混响:%zd",value);
    }
}

#pragma mark - KSYCameraRecorder
/**
 开始录制
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder startRecord:(OSStatus)status{
    if (status == noErr) {
        NSLog(@"开始写入文件");
    }
}

- (void)cameraRecorder:(KSYCameraRecorder *)recorder didFinishRecord:(NSTimeInterval)length videoURL:(NSURL *)url{
    NSLog(@"录制完成，视频时长：%f：url：%@ ", length, url);
    if (!_videoList) {
        _videoList = [NSMutableArray arrayWithCapacity:1];
    }
    [_videoList addObject:url];
}

- (void)cameraRecorder:(KSYCameraRecorder *)recorder lastRecordLength:(NSTimeInterval)lastRecordLength totalLength:(NSTimeInterval)totalLength{
    if (totalLength > 5.0) {
        _finishBtn.hidden = NO;
    }
    // 视频时间请以cameraRecorder:didFinishRecord:videoURL:回调为准
    NSLog(@"record last:%f total:%f", lastRecordLength, totalLength);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView updateLastRangeView:(lastRecordLength/_recorder.maxRecDuration)];
    });
}

- (void)cameraRecorder:(KSYCameraRecorder *)recorder didReachMaxDurationLimit:(NSTimeInterval)maxRecDuration{
    dispatch_async(dispatch_get_main_queue(), ^{
        _recordBtn.selected = NO;
        _deleteBtn.hidden = NO;
        _deleteBtn.enabled = YES;
        _finishBtn.enabled = YES;
    });
    NSLog(@"录制到达最大时长，自动结束");
}

#pragma mark - KSYMEConcatorDelegate
- (void)onConcatError:(KSYMEConcator *)concator error:(KSYStatusCode)error extraStr:(NSString *)extraStr{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [hud hideAnimated:YES];
    NSLog(@"concat error %@",extraStr);
}

- (void)onConcatFinish:(NSURL *)path{
    //    KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithVideoURL:path];
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [hud hideAnimated:YES];
    
//    VideoEditorViewController *editVC = [[VideoEditorViewController alloc] initWithUrl:path];
    KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithNibName:[KSYEditViewController className] bundle:[NSBundle mainBundle] VideoURL:path];

    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)onConcatProgressChanged:(float)value{
    NSLog(@"concat progrese : %f",value);
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.progress = value;
    hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%", value];
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)didClickRecordBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        [_recorder startRecord];
        _deleteBtn.enabled = NO;
        _finishBtn.enabled = NO;
        [_progressView addRangeView];
    }else{
        __weak typeof(self) weakSelf = self;
        [_recorder stopRecord:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.deleteBtn.enabled = YES;
                weakSelf.deleteBtn.hidden = NO;
                weakSelf.finishBtn.enabled = YES;
            });
        }];
    }
}

- (IBAction)didClickTorchBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_recorder toggleTorch];
}

- (IBAction)didClickSwitchBtn:(UIButton *)sender {
    [_recorder switchCamera];
    if (_recorder.cameraPosition == AVCaptureDevicePositionBack && _recorder.isTorchSupported){
        _torchBtn.hidden = NO;
    }else{
        _torchBtn.hidden = YES;
    }
}

- (IBAction)didClickBeautyBtn:(UIButton *)sender {
    [self hideEffectBtns];
    
    self.beautyView.hidden = NO;
    self.bgMusicView.hidden = YES;
    self.aeView.hidden = YES;
}

//音乐 点击
- (IBAction)didClickBgmBtn:(UIButton *)sender {
    [self hideEffectBtns];
    
    self.beautyView.hidden = YES;
    self.bgMusicView.hidden = NO;
    self.aeView.hidden = YES;
}

- (IBAction)didClickAudioEffectBtn:(UIButton *)sender {
    [self hideEffectBtns];
    
    self.beautyView.hidden = YES;
    self.bgMusicView.hidden = YES;
    self.aeView.hidden = NO;
}

- (IBAction)didClickDeleteBtn:(UIButton *)sender {
    if (_recorder.recordedVideos.count > 0) {
        if (![_progressView lastRangeViewSelected]) {
            [_progressView setLastRangeViewSelected:YES];
        }else{
            [_progressView removeLastRangeView];
            [_recorder deleteRecordedVideoAt:(_recorder.recordedVideos.count - 1)];
            // 隐藏delete按钮
            if (_recorder.recordedVideos.count == 0) {
                _deleteBtn.hidden = YES;
            }
            // 小于minRecDuration隐藏完成按钮
            __block Float64 totalLength = 0;
            [_recorder.recordedVideos enumerateObjectsUsingBlock:^(__kindof KSYMediaUnit * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                totalLength += CMTimeGetSeconds(obj.duration);
            }];
            if (totalLength < _recorder.minRecDuration) {
                _finishBtn.hidden = YES;
            }
        }
    }
}

- (IBAction)didClickFinishBtn:(UIButton *)sender {
    if (!_concator){
        _concator = [[KSYMEConcator alloc] init];
        _concator.delegate = self;
    }
    if (![_concator isConcating]) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeDeterminate;
        hud.label.text = @"视频拼接中...";
        hud.detailsLabel.text = @"0.00 %";
        hud.animationType = MBProgressHUDAnimationZoomIn;
        
        if ([_concator addVideos:_videoList] == noErr){
            [_concator startConcat];
        }
    }
}

- (IBAction)didClickBackBtn:(UIButton *)sender {
    if ([_recorder isRecording]) {
        __weak typeof(self) weakSelf = self;
        [_recorder stopRecord:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf close];
            });
        }];
    }else{
        [self close];
    }
}

- (void)onTapBGView:(UITapGestureRecognizer *)tap{
    // 其他手势接触删除选中状态
    if (![_deleteBtn pointInside:[tap locationInView:_deleteBtn] withEvent:nil]) {
        [_progressView setLastRangeViewSelected:NO];
    }
    
    if (!_beautyView.hidden && [self responseGestureTest:tap inView:_beautyView]){
        return;
    }
    if (!_bgMusicView.hidden && [self responseGestureTest:tap inView:_bgMusicView]) {
        return;
    }
    if (!self.aeView.hidden && [self responseGestureTest:tap inView:self.aeView]) {
        return;
    }
    
    [self displayEffectBtns];
}

//设置摄像头对焦位置
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    [_recorder focusAtPoint:point];
    [_recorder exposureAtPoint:point];
    if (!_foucsCursor) {
        [self.view addSubview:self.foucsCursor];
    }
    _foucsCursor.center = point;
    _foucsCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    _foucsCursor.alpha=1.0;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.foucsCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        weakSelf.foucsCursor.alpha=0;
    }];
}

//添加缩放手势，缩放时镜头放大或缩小
- (void)addPinchGestureRecognizer{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinch];
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _currentPinchZoomFactor = _recorder.pinchZoomFactor;
    }
    CGFloat zoomFactor = _currentPinchZoomFactor * recognizer.scale;//当前触摸缩放因子*坐标比例
    [_recorder setPinchZoomFactor:zoomFactor];
}

- (IBAction)exposureValueDidChange:(UISlider *)sender {
    [_recorder setExposureCompensation:sender.value];
}

/**
  检测视图是否能响应事件

 @param gesture 收拾
 @param view 视图
 @return 返回
 */
- (BOOL)responseGestureTest:(UIGestureRecognizer *)gesture inView:(UIView *)view{
    CGPoint point = [gesture locationInView:view];
    if ([view pointInside:point withEvent:nil]){
        [view hitTest:point withEvent:nil];
        return YES;
    }
    return NO;
}
//美颜分段控件切换事件
- (IBAction)beautySegmentChangedValue:(HMSegmentedControl *)control{
    //TODO: 待判断美颜collectionView在显示的时候
    if (!self.beautyCollectionView.hidden) {
        NSIndexPath *scrollIndex = [NSIndexPath indexPathForRow:control.selectedSegmentIndex inSection:0];
        [self.beautyCollectionView scrollToItemAtIndexPath:scrollIndex
                                          atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
    }
}

- (IBAction)onAntiShakeClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self enableAntiShakeFeature:sender.selected];
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
