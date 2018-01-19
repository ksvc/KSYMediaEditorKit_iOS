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
#import "KSYMVView.h"
#import "KSYAgent.h" //copy 文件使用
#import "NSDictionary+NilSafe.h"
#import "KSYPreEditViewController.h"

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
KSYAudioEffectDelegate,
KSYMVDelegate
>



// recorder
@property (nonatomic, strong) KSYCameraRecorder *recorder;
// concator
@property (nonatomic, strong) KSYMEConcator *concator;
// recorded video list
@property (nonatomic, strong) NSMutableArray *videoList;
// 当前使用的美颜滤镜
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>* curBeautyFilter;
// 当前使用的特效滤镜
@property (nonatomic, strong) KSYBuildInSpecialEffects* curEffectsFilter;

// UI

@property (weak, nonatomic) IBOutlet UIButton *antiShakeBtn;

@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UIButton *beautyBtn;
@property (weak, nonatomic) IBOutlet UIButton *bgmBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioEffectBtn;
@property (weak, nonatomic) IBOutlet UIButton *mvBtn;


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
@property (nonatomic, strong) IBOutlet UIImageView *foucsCursor;
//当前触摸缩放因子
@property (nonatomic, assign) CGFloat currentPinchZoomFactor;

@property (nonatomic, assign) CVPixelBufferRef cacheBuffer; //解决防抖内存过高问题

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *safeAreaView;

@property (weak, nonatomic) IBOutlet UIView *canRotateView; //所有UI控件的super view
@property (weak, nonatomic) IBOutlet UISegmentedControl *recordRateSeg;

@property (strong, nonatomic) IBOutlet KSYMVView *mvView;

@property (nonatomic, strong) KSYAgent *agent; //主要用于一些冗余不重要的代码(和demo没太大关系)

//定时拍摄
@property (weak, nonatomic) IBOutlet UIButton *countDownBtn;
@property (weak, nonatomic) IBOutlet UIImageView *countDownBackground;
@property (nonatomic, assign) NSUInteger countTime;//计时时间(秒)

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


#pragma mark -
#pragma mark - private methods 私有方法
- (void)configSubviews{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    if ((@available(iOS 11.0, *)) && IS_IPHONEX) {
        //适配预览视图
        [self.safeAreaView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        }];
        
        [self.canRotateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        }];
        
    } else {
        [self.safeAreaView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];

        [self.canRotateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).mas_offset(UIEdgeInsetsZero);
        }];
    }
    
    self.beautyView.backgroundColor = [UIColor ksy_colorWithHex:0x07080b andAlpha:0.8];
    
    if ([self isLandscape]) {
        self.beaurtySegment.sectionTitles = @[@"美颜",@"滤镜"];
    } else {
        self.beaurtySegment.sectionTitles = @[@"美颜",@"动态特效",@"滤镜"];
    }
    self.beaurtySegment.frame = CGRectMake(0, 20, self.canRotateView.width, 40);
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
    
    //注册cell
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYBeautyFilterCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYBeautyFilterCell className]];
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYDynamicEffectCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYDynamicEffectCell className]];
    [self.beautyCollectionView registerNib:[UINib nibWithNibName:[KSYFilterCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYFilterCell className]];
    
    //布局
    self.beautyCollectionView.collectionViewLayout = [[KSYBeautyFlowLayout alloc] initSize:CGSizeMake(kScreenWidth, 140)];
    self.beautyCollectionView.multipleTouchEnabled = NO;
    self.beautyCollectionView.allowsMultipleSelection = NO;
    
    //音乐
    [self.canRotateView addSubview:self.bgMusicView];
    
    self.bgMusicView.backgroundColor = self.beautyView.backgroundColor;
    //设置代理回调
    self.bgMusicView.delegate = self;
    //设置音效代理回调
    self.bgMusicView.audioEffectDelegate = self;

    //旋转滑动
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI_2);
    self.exposureSlider.transform = trans;
    self.exposureSlider.right = kScreenWidth - 20;
    self.exposureSlider.centerY = self.canRotateView.centerY;

    //音效
    [self.canRotateView addSubview:self.aeView];
    
    self.aeView.backgroundColor = self.bgMusicView.backgroundColor;
    self.aeView.delegate = self;
    
    //MV
    [self.canRotateView addSubview:self.mvView];
    self.mvView.delegate = self;
    
    // recordRate set
    [_recordRateSeg setTitleTextAttributes:@{
                                             NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f],
                                             NSForegroundColorAttributeName:[UIColor ksy_colorWithHexString:@"#ff2e4e"]
                                             }
                                  forState:UIControlStateSelected];
    [_recordRateSeg setTitleTextAttributes:@{
                                             NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f],
                                             NSForegroundColorAttributeName : [UIColor ksy_colorWithHexString:@"#ffffff"]
                                             }
                                  forState:UIControlStateNormal];
    
    _recordRateSeg.layer.cornerRadius = 4;
    _recordRateSeg.clipsToBounds = YES;
    
    RecordConfigModel *recordModel = self.models.firstObject;
    [self layoutSubviewByOrientation:recordModel.orientation];
    if (recordModel.orientation == KSYOrientationHorizontal) {
        self.mvBtn.hidden = YES;
    } else {
        self.mvBtn.hidden = NO;
    }
    
    
    //创建agent实例用于 copy 文件到沙盒(不是重要代码可忽略)
    if (self.agent == nil) { self.agent = [[KSYAgent alloc] init]; }
    
    self.countTime = 3;//倒计时从3开始 到 1结束
 }


/**
 两套代码布局 支持横竖屏

 @param orientation 方向
 */
- (void)layoutSubviewByOrientation:(KSYOrientation)orientation{
    if (orientation == KSYOrientationHorizontal) {
        //关闭按钮
        [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.canRotateView.mas_top).offset(20);
            make.left.equalTo(self.canRotateView.mas_left).offset(30);
            make.width.height.mas_equalTo(30);
        }];
        
        CGFloat pandding = kScreenMaxLength/5.0 -20;
        //防抖
        [self.antiShakeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.closeBtn.mas_centerY);
            make.left.equalTo(self.canRotateView.mas_left).offset(pandding);
            make.width.equalTo(@36);
            make.height.equalTo(@24);
        }];
        
        //闪光灯
        [self.torchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.closeBtn.mas_centerY);
            make.centerX.equalTo(self.antiShakeBtn.mas_centerX).offset(pandding);
        }];
        
        //切换摄像头
        [self.switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.torchBtn.mas_centerY);
            make.centerX.equalTo(self.torchBtn.mas_centerX).offset(pandding);
        }];
        
        //定时拍摄按钮
        [self.countDownBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.switchBtn.mas_centerY);
            make.centerX.equalTo(self.switchBtn.mas_right).offset(pandding);
        }];
        
        CGFloat rightPadding = kScreenMinLength / 5.0;
        [self.finishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.canRotateView.mas_top).offset(rightPadding);
            make.right.equalTo(self.canRotateView.mas_right).offset(-54);
        }];
        
        [self.recordBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.canRotateView.mas_centerY);
            make.centerX.equalTo(self.finishBtn.mas_centerX);
        }];
        
        [self.deleteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.canRotateView.mas_bottom).offset(-rightPadding);
            make.centerX.equalTo(self.recordBtn.mas_centerX);
        }];
        
        [self.audioEffectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.canRotateView.mas_right).offset(-(kScreenMaxLength/4.0));
            make.centerY.equalTo(self.recordBtn.mas_centerY);
        }];
        
        CGFloat funcPadding = kScreenMinLength / 4.0;
        [self.bgmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.audioEffectBtn.mas_centerX);
            make.centerY.equalTo(self.canRotateView.mas_top).offset(funcPadding);
        }];
        
        [self.beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.audioEffectBtn.mas_centerX);
            make.centerY.equalTo(self.canRotateView.mas_bottom).offset(-funcPadding);
        }];
        
        [_recordRateSeg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_progressView.mas_top).offset(-20);
            make.centerX.equalTo(_progressView);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(216);
        }];
        
        [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.closeBtn.mas_centerX).offset(57);
            make.bottom.equalTo(self.canRotateView.mas_bottom).offset(-24);
            make.right.equalTo(self.beautyBtn.mas_centerX);
            make.height.equalTo(@4);
        }];
        //
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.torchBtn.mas_centerX);
            make.top.equalTo(self.torchBtn.mas_bottom).offset(0);
            make.width.equalTo(@80);
            make.height.equalTo(@20);
        }];
        
        //曝光 纵向
        [self.exposureSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.closeBtn);
            make.top.equalTo(self.closeBtn.mas_bottom).offset(120);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(200);
        }];
        
        //倒计时背景视图
        [self.countDownBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.canRotateView);
        }];
        
        
    } else {
        [_closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.canRotateView.mas_top).offset(20);
            make.left.equalTo(self.canRotateView.mas_left).offset(30);
            make.width.height.mas_equalTo(30);
        }];
        
        [self.antiShakeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.closeBtn.mas_centerY);
            make.centerX.equalTo(self.canRotateView.mas_centerX);
            make.width.equalTo(@36);
            make.height.equalTo(@24);
        }];
        CGFloat merginOffset = kScreenMinLength/3.0;
        CGFloat countDownBtnOffset = merginOffset * 1;
        [self.countDownBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.antiShakeBtn.mas_centerY);
            make.centerX.equalTo(self.canRotateView.mas_left).offset(countDownBtnOffset);
            make.width.equalTo(@38);
            make.height.equalTo(@24);
        }];
        
        [_switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_closeBtn);
            make.right.equalTo(self.canRotateView.mas_right).offset(-30);
        }];
        
        [_torchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_closeBtn);
            make.right.equalTo(_switchBtn.mas_left).offset(-34);
        }];
        
        [_deleteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.canRotateView).offset(52);
            make.bottom.equalTo(self.canRotateView).offset(-53);
        }];
        
        [_recordBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.canRotateView);
            make.centerY.equalTo(_deleteBtn);
        }];
        
        [_finishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.canRotateView.mas_right).offset(-52);
            make.bottom.equalTo(self.canRotateView.mas_bottom).offset(-53);
        }];
        
        [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.canRotateView);
            make.bottom.equalTo(_deleteBtn.mas_top).offset(-56);
            make.height.mas_equalTo(4);
        }];
        
        
        CGFloat btnWidth = 30.0; //按钮图宽高35*75
        CGFloat widthX = kScreenMinLength/4.0;

        //宽度4等分 + 宽度4等分之后的1/2
        CGFloat beautyBtnLeftOffset = widthX * 0 + (widthX - btnWidth) / 2.0;
        [_beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.canRotateView.mas_left).offset(beautyBtnLeftOffset);
            make.bottom.equalTo(_progressView.mas_top).offset(-17);
        }];
        
        CGFloat bgmBtnLeftOffset = widthX * 1 + (widthX - btnWidth) / 2.0;
        [_bgmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_beautyBtn);
            make.left.equalTo(self.canRotateView.mas_left).offset(bgmBtnLeftOffset);
        }];
        
        CGFloat audioEffectBtnLeftOffset = widthX * 2 + (widthX - btnWidth) / 2.0;
        [_audioEffectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_beautyBtn);
            make.left.equalTo(self.canRotateView.mas_left).offset(audioEffectBtnLeftOffset);
        }];
        
        CGFloat mvBtnLeftOffset = widthX * 3 + (widthX - btnWidth) / 2.0;
        [self.mvBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_beautyBtn);
            make.left.equalTo(self.canRotateView.mas_left).offset(mvBtnLeftOffset);
        }];
        
        
        [_recordRateSeg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_canRotateView).offset(80);
            make.right.equalTo(_canRotateView).offset(-80);
            make.bottom.mas_equalTo(_beautyBtn.mas_top).offset(-20);
            make.height.mas_equalTo(30);
        }];
        
        //美颜相关视图
        [self.beautyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.canRotateView);
            make.height.equalTo(@184);
        }];
        
        [self.beaurtySegment mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.beautyView);
            make.height.equalTo(@44);
        }];
        
        //美颜所有视图切换的collectionView
        [self.beautyCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.beautyView);
            make.bottom.mas_equalTo(self.beaurtySegment.mas_top);
        }];
        //背景音乐相关视图
        [self.bgMusicView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self.canRotateView);
            make.height.equalTo(@(253));
        }];
        
        [self.aeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self.canRotateView);
            make.height.equalTo(@(186));
        }];
        
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.canRotateView.mas_centerX);
            make.width.equalTo(@80);
            make.height.equalTo(@20);
            make.top.equalTo(self.canRotateView.mas_top).offset(64);
        }];
        
        //MV视图
        [self.mvView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self.canRotateView);
            make.height.equalTo(@(150));
        }];
        
        //倒计时背景视图
        [self.countDownBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.canRotateView);
        }];
    }
}

- (void)addGestures{
    // tap
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBGView:)];
    [self.canRotateView addGestureRecognizer:tapGes];
    tapGes.cancelsTouchesInView = NO;
    
    // pinch
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDetected:)];
    [self.canRotateView addGestureRecognizer:pinch];
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

#pragma mark -
- (void)generateRecorder{
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
    // 视频方向
    if (recordModel.orientation == KSYOrientationHorizontal){
        // 1. set video orientation, which will default set video's preview orientation
        _recorder.videoOrientation = UIInterfaceOrientationLandscapeRight;
        // 2. set video preview orientation
        [_recorder rotatePreviewTo:UIInterfaceOrientationPortrait];
    }
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
    }
}

// 关闭预览
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
    self.mvBtn.hidden = YES;
    _recordBtn.hidden = YES;
    _recordRateSeg.hidden = YES;
}

// 展示特效按钮
- (void)displayEffectBtns{
    _beautyBtn.hidden = NO;
    _bgmBtn.hidden = NO;
    _audioEffectBtn.hidden = NO;
    _recordBtn.hidden = NO;
    RecordConfigModel *recordModel = self.models.firstObject;
    if (recordModel.orientation == KSYOrientationVertical) {
        self.mvBtn.hidden = NO;
    }
    
    if (![_recorder isRecording]) {
        _recordRateSeg.hidden = NO;
    }
    
    _beautyView.hidden = YES;
    _bgMusicView.hidden = YES;
    _aeView.hidden = YES;
    self.mvView.hidden = YES;
}

// 魔方防抖鉴权
- (void)requestKCMAuth{
    //魔方防抖初始化
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[KMCVStab sharedInstance] authWithToken:kKMCToken onSuccess:^{
            NSLog(@"魔方防抖鉴权成功");
        } onFailure:^(AuthorizeError iErrorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * errorMessage = [[NSString alloc]initWithFormat:@"魔方防抖鉴权失败，错误码:%@", @(iErrorCode)];
                NSLog(@"魔方防抖鉴权失败:%@",errorMessage);
            });
        }];
    });
}

/**
 返回当前录制的时间格式 HH:mm:ss
 @return 返回组装好的字符串
 */
- (NSString *)formattedCurrentTime:(NSTimeInterval)currentTime {
    NSUInteger time = (NSUInteger)currentTime;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format, hours, minutes, seconds];
}

#pragma mark - record orientation
/**
 处理屏幕旋转
 */
- (void)handleScreenRotate{
    if ([self isLandscape]) {
        self.canRotateView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        [self.canRotateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.equalTo(IS_IPHONEX?@(self.view.height- 44 - 39):self.view.mas_height);
            make.height.equalTo(self.view.mas_width);
        }];
    }
}

/**
 判断是否横屏
 
 @return 判断结果
 */
- (BOOL)isLandscape{
    RecordConfigModel *recordModel = self.models.firstObject;
    return (recordModel.orientation == KSYOrientationHorizontal);
}

- (void)resetBGMView{
    //背景音乐相关视图
    [self.bgMusicView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timerLabel.mas_bottom);
        make.left.equalTo(self.progressView.mas_left);
        make.right.equalTo(self.progressView.mas_right).offset(-40);
        make.bottom.equalTo(self.progressView.mas_top).offset(-20);
    }];
    self.bgMusicView.layer.cornerRadius = 5.0;
    self.bgMusicView.layer.masksToBounds = YES;
}

- (void)resetAEView{
    [self.aeView resetLayoutWithSize:CGSizeMake(self.progressView.right-40 - self.progressView.left, 120)];
    [self.aeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressView.mas_left);
        make.right.equalTo(self.progressView.mas_right).offset(-40);
        make.centerY.equalTo(self.canRotateView.mas_centerY);
        make.height.equalTo(@186);
    }];
    self.aeView.layer.cornerRadius = 5.0;
    self.aeView.layer.masksToBounds = YES;
}

- (void)resetBeautyView{
    [self.beautyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressView.mas_left);
        make.height.equalTo(@160);
        make.right.equalTo(self.progressView.mas_right).offset(-40);
        make.bottom.equalTo(self.progressView.mas_top).offset(-20);
    }];
    [self.beaurtySegment mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.beautyView);
        make.height.equalTo(@44);
    }];
    
    //美颜所有视图切换的collectionView
    self.beautyCollectionView.collectionViewLayout = [[KSYBeautyFlowLayout alloc] initSize:CGSizeMake(self.bgmBtn.left-self.progressView.left, 140)];
    [self.beautyCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.beautyView);
        make.bottom.mas_equalTo(self.beaurtySegment.mas_top);
    }];
    self.beautyView.layer.cornerRadius = 5.0;
    self.beautyView.layer.masksToBounds = YES;
}


//递归调用  check倒计时
- (void)startCountDownRecord{
    //取出素材图
    if (self.countTime < 1) {
        self.countDownBackground.hidden = YES;
        [_recorder startRecord];
        _deleteBtn.enabled = NO;
        _finishBtn.enabled = NO;
        [_progressView addRangeView];
        self.countTime = 3;
    } else {
        UIImage *countImage = [UIImage imageNamed:[NSString stringWithFormat:@"ksy_count_down%zd",self.countTime]];
        self.countDownBackground.image = countImage;
        self.countTime--;
        [self performSelector:@selector(startCountDownRecord) withObject:nil afterDelay:1];
    }
}


/**
 启动 MV 之后需要恢复一些按钮的点击 防止逻辑冲突
 */
- (void)enableSomeButtons{
    self.beautyBtn.enabled = YES;
    self.bgmBtn.enabled = YES;
    self.recordRateSeg.enabled = YES;

}


/**
 关闭 MV 之后需要恢复一些按钮的点击 防止逻辑冲突
 */
- (void)disableSomeButtons{
    self.beautyBtn.enabled = NO;
    self.bgmBtn.enabled = NO;
    
    // 重置倍速录制
    [self.recordRateSeg setSelectedSegmentIndex:1];
    self.recordRateSeg.enabled = NO;
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
            if ([self isLandscape]) {
                //滤镜
                KSYFilterCell *beautyFilterCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYFilterCell className] forIndexPath:indexPath];
                beautyFilterCell.delegate = self;
                beautyCell = beautyFilterCell;
            } else {
                //动态特效
                KSYDynamicEffectCell* Cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYDynamicEffectCell className] forIndexPath:indexPath];
                Cell.stickerView.delegate = self;
                beautyCell = Cell;
            }
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
    CGFloat pageWidth = kScreenMaxLength;
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
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.canRotateView animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.bezelView.color = [UIColor clearColor];
            hud.label.text = material.strTriggerActionTip;
            hud.label.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
            hud.label.font = [UIFont systemFontOfSize:24];
            hud.label.shadowColor = [UIColor blackColor];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.canRotateView animated:NO];
            });
        }
        
        if([[FilterManager instance].kmcFitler isMaterialDownloaded:material]){
            [[FilterManager instance].kmcFitler startShowingMaterial:material];
        }
        
        GPUImageOutput<GPUImageInput> *arFilter = [FilterManager instance].kmcFitler.filter;
        // 使用人脸贴纸（也可以同时使用美颜+滤镜+人脸贴纸，参考-setupFilterGroup 方法）
        [_recorder setFilter:arFilter];
    }else{
        [_recorder setFilter:[self setupFilterGroup]];
    }
}

#pragma mark - KSYBeautyFilterCell Delegate 美颜代理
- (void)beautyFilterCell:(KSYBeautyFilterCell *)cell
              filterType:(KSYMEBeautyKindType)type{
    GPUImageOutput <GPUImageInput> * bf = nil;
    
    if (type == KSYMEBeautyKindTypZiran) {
        KSYGPUBeautifyExtFilter *extFilter = [[KSYGPUBeautifyExtFilter alloc] init];
        [extFilter setBeautylevel:3];
        bf = extFilter;
    } else if (type == KSYMEBeautyKindTypeWeimei) {
        KSYBeautifyProFilter *proFilter = [[KSYBeautifyProFilter alloc] init];
        proFilter.grindRatio = 0.5;
        proFilter.whitenRatio = 0.5;
        proFilter.ruddyRatio = -1.0;
        bf = proFilter;
    } else if (type == KSYMEBeautyKindTypeHuayan) {
        KSYBeautifyProFilter *proFilter = [[KSYBeautifyProFilter alloc] initWithIdx:3];
        proFilter.grindRatio = 0.5;
        proFilter.whitenRatio = 0.5;
        proFilter.ruddyRatio = -0.7;
        bf = proFilter;
        
    } else if (type == KSYMEBeautyKindTypeFennen) {
        KSYBeautifyProFilter *proFilter = [[KSYBeautifyProFilter alloc] initWithIdx:3];
        proFilter.grindRatio = 0.5;
        proFilter.whitenRatio = 0.5;
        proFilter.ruddyRatio = -0.4;
        bf = proFilter;
    }
    _curBeautyFilter = bf;
    [self.recorder setFilter:[self setupFilterGroup]];
}

#pragma mark - KSYFilterCell Delegate 滤镜代理
- (void)filterCell:(KSYFilterCell *)cell filterType:(KSYMEFilterType)type filterIndex:(NSUInteger)index{
    //滤镜
    if (index == 0){//原型
        _curEffectsFilter = nil;
    }else{ // filter graph : proFilter->builtInSpecialEffects
        if (_curEffectsFilter) {
            [_curEffectsFilter setSpecialEffectsIdx:index];
        }else{
            _curEffectsFilter = [[KSYBuildInSpecialEffects alloc] initWithIdx:index];
        }
    }
    [self.recorder setFilter:[self setupFilterGroup]];
}

- (GPUImageOutput<GPUImageInput>*)setupFilterGroup{
    GPUImageOutput<GPUImageInput>* filter = _curBeautyFilter;
    if (_curEffectsFilter) {
        if (_curBeautyFilter) {
            GPUImageFilterGroup *fg = [[GPUImageFilterGroup alloc] init];
            [_curBeautyFilter removeAllTargets];
            [_curBeautyFilter addTarget:_curEffectsFilter];
            [fg addFilter:_curBeautyFilter];
            [fg addFilter:_curEffectsFilter];
            
            [fg setInitialFilters:@[_curBeautyFilter]];
            [fg setTerminalFilter:_curEffectsFilter];
            
            filter = fg;
        }else{
            filter = _curEffectsFilter;
        }
    }
    return filter;
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
        _recorder.effectType = (KSYAudioEffectType)value;
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
    _recordRateSeg.hidden = YES;
    if (status == noErr) {
        NSLog(@"开始写入文件");
    }
}

- (void)cameraRecorder:(KSYCameraRecorder *)recorder didFinishRecord:(NSTimeInterval)length videoURL:(NSURL *)url{
    
    _recordRateSeg.hidden = NO;
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
    [_progressView updateLastRangeView:(lastRecordLength/_recorder.maxRecDuration)];
    self.timerLabel.text = [self formattedCurrentTime:totalLength];
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
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.canRotateView];
    [hud hideAnimated:YES];
    NSLog(@"concat error %@",extraStr);
}

- (void)onConcatFinish:(NSURL *)path{
    //    KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithVideoURL:path];
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.canRotateView];
    [hud hideAnimated:YES];
    
//    VideoEditorViewController *editVC = [[VideoEditorViewController alloc] initWithUrl:path];
    KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithNibName:[KSYEditViewController className] bundle:[NSBundle mainBundle] VideoURL:path];

    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)onConcatProgressChanged:(float)value{
    NSLog(@"concat progrese : %f",value);
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.canRotateView];
    hud.progress = value;
    hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%", value];
}

#pragma mark -
#pragma mark - KSYMVDelegate
- (void)mvDidSelectedMVPathName:(NSString *)mvResName{
    
    if (mvResName.length > 0) {
        //发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kMVSelectedNotificationKey object:@(mvResName.length > 0)];
        
        [self disableSomeButtons];
        NSLog(@"%@",mvResName);
        @weakify(self)
        [self.agent copyMVFiletoSandBox:mvResName completeBlock:^(NSString *mvFilePath, NSString *configFilePath) {
            NSLog(@"MV 资源目录:%@",mvFilePath);
            @strongify(self);
            [self.recorder applyMVFromeFilePath:mvFilePath];
        } failedBlock:^(NSError *error) {
            [self.recorder applyMVFromeFilePath:nil];
            NSLog(@"MV Error:%@",error);
        }];
    } else {
        [self.recorder applyMVFromeFilePath:nil];
        NSLog(@"取消 MV 效果");
        [self enableSomeButtons];
    }
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)didClickRecordBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        //check 是否定时拍摄
        if (self.countDownBtn.selected) {
            self.countDownBackground.hidden = NO;
            [self  startCountDownRecord];
        } else{
            self.countDownBackground.hidden = YES;
            [_recorder startRecord];
            _deleteBtn.enabled = NO;
            _finishBtn.enabled = NO;
            [_progressView addRangeView];
        }
        
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
    if ([self isLandscape]) {
        [self resetBeautyView];
    } else {
        [self hideEffectBtns];
    }
    self.beautyView.hidden = NO;
    self.bgMusicView.hidden = YES;
    self.aeView.hidden = YES;
    self.mvView.hidden = YES;
    self.recordRateSeg.hidden = YES;
}

//音乐 点击
- (IBAction)didClickBgmBtn:(UIButton *)sender {
    if ([self isLandscape]) {
        [self resetBGMView];
    } else {
        [self hideEffectBtns];
    }
    self.beautyView.hidden = YES;
    self.bgMusicView.hidden = NO;
    self.aeView.hidden = YES;
    self.mvView.hidden = YES;
    self.recordRateSeg.hidden = YES;
}

- (IBAction)didClickAudioEffectBtn:(UIButton *)sender {
    if ([self isLandscape]) {
        [self resetAEView];
    } else {
        [self hideEffectBtns];
    }
    self.beautyView.hidden = YES;
    self.bgMusicView.hidden = YES;
    self.aeView.hidden = NO;
    self.mvView.hidden = YES;
    self.recordRateSeg.hidden = YES;
}

- (IBAction)mvButtonAction:(UIButton *)sender {
    if ([self isLandscape]) {
        //TODO:横屏的布局
    } else {
        [self hideEffectBtns];
    }
    self.beautyView.hidden = YES;
    self.bgMusicView.hidden = YES;
    self.aeView.hidden = YES;
    self.mvView.hidden = NO;
    self.recordRateSeg.hidden = YES;
}

- (IBAction)didClickDeleteBtn:(UIButton *)sender {
    if (_recorder.recordedVideos.count > 0) {
        if (![_progressView lastRangeViewSelected]) {
            [_progressView setLastRangeViewSelected:YES];
        }else{
            [_progressView removeLastRangeView];
            [_videoList removeObjectAtIndex:(_videoList.count-1)];
            [_recorder deleteRecordedVideoAt:(_recorder.recordedVideos.count - 1)];
            
            CGFloat totalLength = [_recorder recordedLength];
            self.timerLabel.text = [self formattedCurrentTime:totalLength];
            
            // 小于minRecDuration隐藏完成按钮
            if (totalLength < _recorder.minRecDuration) {
                _finishBtn.hidden = YES;
            }
        }
    }
}

- (IBAction)didClickFinishBtn:(UIButton *)sender {
//    if (!_concator){
//        _concator = [[KSYMEConcator alloc] init];
//        _concator.delegate = self;
//    }
//    if (![_concator isConcating]) {
//
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.canRotateView animated:YES];
//        hud.mode = MBProgressHUDModeDeterminate;
//        hud.label.text = @"视频拼接中...";
//        hud.detailsLabel.text = @"0.00 %";
//        hud.animationType = MBProgressHUDAnimationZoomIn;
//
//        if ([_concator addVideos:_videoList] == noErr){
//            [_concator startConcat];
//        }
//    }
    if (_videoList == nil || _videoList.count == 0) {
        NSLog(@"至少选择一个视频进行导入");
        return;
    }
    
    KSYPreEditViewController *preEditVC = [[KSYPreEditViewController alloc] initWithNibName:[KSYPreEditViewController className] bundle:[NSBundle mainBundle]];
    preEditVC.originAssets = [NSMutableArray arrayWithArray:_videoList];
    [self.navigationController showViewController:preEditVC sender:nil];
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
    
    if ((!_beautyView.hidden && [self responseGestureTest:tap inView:_beautyView]) || [self responseGestureTest:tap inView:_beautyBtn]){
        return;
    }
    if ((!_bgMusicView.hidden && [self responseGestureTest:tap inView:_bgMusicView]) || [self responseGestureTest:tap inView:_bgmBtn]) {
        return;
    }
    if ((!self.aeView.hidden && [self responseGestureTest:tap inView:_aeView]) || [self responseGestureTest:tap inView:_audioEffectBtn]) {
        return;
    }
    if ((!self.mvView.hidden && [self responseGestureTest:tap inView:self.mvView]) || [self responseGestureTest:tap inView:self.mvBtn]) {
        return;
    }
    
    if ((!self.countDownBackground.hidden && [self responseGestureTest:tap inView:self.countDownBackground]) || [self responseGestureTest:tap inView:self.countDownBtn]) {
        return;
    }
    
    [self displayEffectBtns];
}

//设置摄像头对焦位置
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.canRotateView];
    
    [_recorder focusAtPoint:point];
    [_recorder exposureAtPoint:point];
    if (!_foucsCursor) {
        [self.canRotateView addSubview:self.foucsCursor];
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

- (IBAction)recordRateDidChanged:(UISegmentedControl *)sender {
    [_recorder setRecordRate:(sender.selectedSegmentIndex + 1 ) * 0.5];
}



- (IBAction)onCountDownShootClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
}



#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 开启预览
    [_recorder startPreview:self.safeAreaView];
    
    
    [self.view bringSubviewToFront:self.canRotateView];
    [self handleScreenRotate];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 摄像头启动后获取曝光补偿度
    _exposureSlider.value = [_recorder exposureCompensation];
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
}

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
