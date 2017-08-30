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

#import "UIView+BLLandscape.h"

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
@property (nonatomic, strong) IBOutlet UIImageView *foucsCursor;
//当前触摸缩放因子
@property (nonatomic, assign) CGFloat currentPinchZoomFactor;

@property (nonatomic, assign) CVPixelBufferRef cacheBuffer; //解决防抖内存过高问题

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UIView *canRotateView; //所有UI控件的super view

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



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}


#pragma mark -
#pragma mark - private methods 私有方法
- (void)configSubviews{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self.canRotateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
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
    
    //音效
    [self.canRotateView addSubview:self.aeView];
    
    self.aeView.backgroundColor = self.bgMusicView.backgroundColor;
    self.aeView.delegate = self;
    
    //旋转滑动
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.exposureSlider.transform = trans;
    self.exposureSlider.right = kScreenWidth - 20;
    self.exposureSlider.centerY = self.canRotateView.centerY;
    
    RecordConfigModel *recordModel = self.models.firstObject;
    [self layoutSubviewByOrientation:recordModel.orientation];
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
        
        
        //曝光 纵向
        self.exposureSlider.frame = CGRectMake(self.closeBtn.left, self.closeBtn.bottom+50, 20, 200);
        
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
        
        [_beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.canRotateView).offset(90);
            make.bottom.equalTo(_progressView.mas_top).offset(-17);
        }];
        
        [_bgmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_beautyBtn);
            make.centerX.equalTo(self.canRotateView);
        }];
        
        [_audioEffectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_beautyBtn);
            make.right.equalTo(self.canRotateView).offset(-90);
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
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
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



- (void)stopPreview{
    [_recorder stopPreview];
}

// 关闭
- (void)close{
    [self stopPreview];
    [self.navigationController popViewControllerAnimated:YES];
    [self.canRotateView bl_protraitAnimated:NO animations:nil complete:nil];
    
    //屏幕回正
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

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}
/**
 处理屏幕旋转

 @param orientation 旋转方向
 */
- (void)handleScreenRotate:(UIDeviceOrientation)orientation{
    
    if ([self isLandscape]) {
       
        [self.recorder rotateStreamTo:UIInterfaceOrientationLandscapeRight];
        //转 view
        [self.canRotateView bl_landscapeAnimated:NO animations:nil complete:nil];;
        [self.canRotateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.equalTo(self.view.mas_height);
            make.height.equalTo(self.view.mas_width);
        }];
        
        //曝光 纵向
        self.exposureSlider.frame = CGRectMake(self.closeBtn.left, self.closeBtn.bottom+50, 20, 200);
    }
    NSLog(@"屏幕开始方向:%tu",orientation);
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
            hud.color = [UIColor clearColor];
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
        
        [_recorder setFilter:[FilterManager instance].kmcFitler.filter];
    }else{
        [_recorder setFilter:nil];
    }
    
}

#pragma mark - KSYBeautyFilterCell Delegate 美颜代理
- (void)beautyFilterCell:(KSYBeautyFilterCell *)cell
              filterType:(KSYMEBeautyKindType)type{
    GPUImageOutput <GPUImageInput> *filter = [_recorder filter];
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
        _curFilter = bf;
    if (![filter isMemberOfClass:[GPUImageFilterGroup class]]) {
        // 当前为滤镜，组成bf -> sf
        if ([filter isMemberOfClass:[KSYBuildInSpecialEffects class]] && bf) {
            KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)filter;
            [bf addTarget:sf];
            // 用滤镜组 将 滤镜 串联成整体
            GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
            [fg addFilter:bf];
            [fg addFilter:sf];
            
            [fg setInitialFilters:[NSArray arrayWithObject:bf]];
            [fg setTerminalFilter:sf];
            _curFilter = fg;
        }else{
            if ([filter isMemberOfClass:[KSYBuildInSpecialEffects class]] && bf) {
                GPUImageFilterGroup *fg = [[GPUImageFilterGroup alloc] init];
                [bf addTarget:filter];
                [fg addFilter:bf];
                [fg addFilter:filter];
                [fg setInitialFilters:@[bf]];
                [fg setTerminalFilter:filter];
                _curFilter = fg;
            }else{
                _curFilter = bf;
            }
        }
    }else{
        if (bf) {
            GPUImageOutput<GPUImageInput>* otherFilter = (KSYBeautifyProFilter *)[(GPUImageFilterGroup *)filter filterAtIndex:1];
            [bf addTarget:otherFilter];
            // bf -> stFinter / sf
            GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
            [fg addFilter:bf];
            [fg addFilter:otherFilter];
            
            [fg setInitialFilters:@[bf]];
            [fg setTerminalFilter:otherFilter];
            
            _curFilter = fg;
        }else {
            if(![filter isMemberOfClass:[KSYBuildInSpecialEffects class]]){
                GPUImageOutput<GPUImageInput>* otherFilter = (KSYBeautifyProFilter *)[(GPUImageFilterGroup *)filter filterAtIndex:1];
                _curFilter = otherFilter;
            }
            _curFilter = nil;
        }
    }
    [self.recorder setFilter:_curFilter];
}

#pragma mark - KSYFilterCell Delegate 滤镜代理
- (void)filterCell:(KSYFilterCell *)cell filterType:(KSYMEFilterType)type filterIndex:(NSUInteger)index{
    //滤镜
    if (index == 0){//原型
        if ([_curFilter isMemberOfClass:[GPUImageFilterGroup class]]){
            GPUImageOutput<GPUImageInput> *bf = [(GPUImageFilterGroup *)_curFilter filterAtIndex:0];
            _curFilter = bf;
        }else if ([_curFilter isMemberOfClass:[KSYBuildInSpecialEffects class]]){
            _curFilter = nil;
        }
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
    if ([self isLandscape]) {
        [self resetBeautyView];
    } else {
        [self hideEffectBtns];
    }
    self.beautyView.hidden = NO;
    self.bgMusicView.hidden = YES;
    self.aeView.hidden = YES;
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
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.canRotateView animated:YES];
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


- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
//    [self handleScreenRotate:deviceOrientation];
}

//强制转屏（这个方法最好放在BaseVController中）
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        // 从2开始是因为前两个参数已经被selector和target占用
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}


#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //为了解决横屏问题
//    [self.canRotateView bl_protraitAnimated:NO animations:nil complete:nil];
    
    [_recorder startPreview:self.view];
    [self.view bringSubviewToFront:self.canRotateView];
    [_recorder.bgmPlayer startPlayBgm:_curBgmPath isLoop:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 摄像头启动后获取曝光补偿度
    _exposureSlider.value = [_recorder exposureCompensation];
    
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [self handleScreenRotate:[UIDevice currentDevice].orientation];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    //判断是否是横屏 修复横屏旋转的 bug
    if ([self isLandscape]) {
        [self.canRotateView bl_protraitAnimated:NO animations:nil complete:nil];
    }
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    //    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
}


#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //当前支持的旋转类型
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    // 是否支持旋转
    return NO;
}



@end
