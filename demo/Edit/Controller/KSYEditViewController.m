//
//  KSYEditViewController.m
//  demo
//
//  Created by iVermisseDich on 2017/7/7.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditViewController.h"
#import "KSYPlayViewController.h"
#import "KSYPublishViewController.h"

// Decals
#import "KSYDecalView.h"
#import "KSYDecalBGView.h"

#import "KSYEditPanelView.h"
#import "KSYEditAudioTrimView.h"

#import "KSYOutputCfgViewController.h"
#import "SlideInPresentationManager.h"  //转场
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>

#import "KSYTimelineView.h"
#import "NSDictionary+NilSafe.h"

#import "KSYEffectLineView.h"
#import "THControlKnob.h"

@interface KSYEditViewController ()
<
KSYMEPreviewDelegate,
KSYMEComposeDelegate,
KSYEditPanelViewDelegate,
KSYAudioEffectDelegate,
KSYEditStickDelegate,
KSYEditWatermarkCellDelegate,
KSYEditTrimDelegate,
KSYEditLevelDelegate,
KSYEditOutputConfigView,
KSYTimelineViewDelegate,
UIGestureRecognizerDelegate,
KSYDecalViewDelegate,
KSYEffectLineViewProtocol,
KSYEditFilterEffectCellDelegate
>
@property (weak, nonatomic  ) IBOutlet UIButton *backBtn;
@property (weak, nonatomic  ) IBOutlet UIButton *composeBtn;
// Editor
@property (strong, nonatomic) KSYMediaEditor *editor;
// URL
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) MediaMetaInfo *videoMeta;
// 当前选中的贴纸
@property (nonatomic) KSYDecalView *curDecalView;
// 所有 decal添加到该view上
@property (nonatomic) KSYDecalBGView *decalBGView;
// 贴纸 gesture 交互相关
@property (nonatomic, assign) CGPoint loc_in;
@property (nonatomic, assign) CGPoint ori_center;
@property (nonatomic, assign) CGFloat curScale;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *previewBGView;
// 水印
@property (nonatomic, strong) CALayer *waterMarkLayer;
@property (weak, nonatomic) IBOutlet HMSegmentedControl *panelTabbar;

@property (strong, nonatomic) IBOutlet KSYEditPanelView *panelView;
@property (strong, nonatomic) IBOutlet KSYEditAudioTrimView *audioTrimView;
// 当前预览resize模式（默认为填充）
@property (assign, nonatomic) KSYMEResizeMode            resizeMode;
// 当前预览resize比例（默认9:16）
@property (assign, nonatomic) KSYMEResizeRatio           resizeRatio;
// 视频时间裁剪
@property (assign, nonatomic) CMTimeRange                videoRange;
// bgm 裁剪
@property (assign, nonatomic) CMTimeRange                bgmRange;
// 输出参数模型
@property (nonatomic, strong) OutputModel                *outputModel;
// 输出配置 相关
@property (nonatomic, strong) SlideInPresentationManager *slideInTransitioningDelegate;
@property (nonatomic, strong) KSYOutputCfgViewController *outputCfgVC;
// 时间线编辑视频组件
@property (nonatomic, strong) KSYTimelineView *timelineView;
// 添加tap手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong) KSYTimelineMediaInfo *mediaInfo;

@property (nonatomic, strong) KSYEffectLineView *effectLineView;
// 记录添加的特效滤镜时间线
@property (nonatomic, strong) NSMutableArray *effectFilterTimelineArray;
@property (nonatomic, strong) KSYMETimeLineFilterItem *tmpItem;

@property (nonatomic, weak) IBOutlet UIView *audioFilterView;
@property (weak, nonatomic) IBOutlet THGreenControlKnob *reverbKnob;
@property (weak, nonatomic) IBOutlet THGreenControlKnob *pitchKnob;
@property (weak, nonatomic) IBOutlet THGreenControlKnob *delayKnob;

@end

@implementation KSYEditViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       VideoURL:(NSURL *)url{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _videoUrl                = url;
        _editor                  = [[KSYMediaEditor alloc] initWithURL:url];
        _editor.previewDelegate  = self;
        _editor.delegate         = self;
        _videoMeta = [KSYMediaHelper videoMetaFrom:_videoUrl];
        
        // 贴纸交互 相关
        _loc_in                  = CGPointZero;
        _curScale                = 1.0f;

        self.view.frame          = [UIScreen mainScreen].bounds;
        self.previewBGView.frame = self.view.bounds;
        [self startPreview];
        
        self.effectFilterTimelineArray = [[NSMutableArray alloc] init];
        self.fd_interactivePopDisabled = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupModels];
    [self configSubviews];
    
    [self addGestures];
}

- (void)addGestures{
    // bgview add gesture
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBGView:)];
    self.tapGes.cancelsTouchesInView = NO;
    self.tapGes.delegate = self;
    [self.view addGestureRecognizer:self.tapGes];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    _playBtn.hidden = YES;
    _waterMarkLayer.hidden = NO;
    [_editor resumePreview];
    [self resizePreviewBGViewWithResizeMode:_resizeMode Ratio:_resizeRatio];
    
    self.timelineView.actualDuration = 0; //为了让导航条播放时长匹配，必须在这里设置时长
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_editor pausePreview];
}

- (void)dealloc{
    [_editor stopPreview];
//    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
}

#pragma mark -
#pragma mark - Private Methods
- (void)setupModels{
    OutputModel *outputModel = [[OutputModel alloc] init];
    outputModel.resolution = KSYRecordPreset720P;
    outputModel.videoCodec = KSYVideoCodec_AUTO;
    outputModel.audioCodec = KSYAudioCodec_AAC_HE;
    outputModel.videoKbps = 2048;
    outputModel.audioKbps = 64;
    outputModel.videoFormat = KSYOutputFormat_MP4;
    
    _outputModel = outputModel;
}

- (void)configSubviews{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#18181D"];
    self.previewBGView.backgroundColor = [UIColor blackColor];
    
    // preview bgview
    [self decalBGView];
    _previewBGView.autoresizingMask = UIViewAutoresizingNone;
    _previewBGView.autoresizesSubviews = NO;
    
    if (@available(iOS 11.0, *)) {
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
            make.width.height.mas_equalTo(30);
        }];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(20);
            make.bottom.equalTo(self.panelTabbar.mas_top).offset(-40);
            make.width.height.equalTo(@56);
        }];
        
        [_composeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(18);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-18);
        }];
        
        // 底部segement
        [self.panelTabbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.height.equalTo(@44);
        }];
        
        [self.audioFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@200);
        }];
    } else {
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(20);
            make.left.equalTo(self.view.mas_left).offset(30);
            make.width.height.mas_equalTo(30);
        }];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(20);
            make.bottom.equalTo(self.panelTabbar.mas_top).offset(-40);
            make.width.height.equalTo(@56);
        }];
        
        [_composeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(18);
            make.right.equalTo(self.view.mas_right).offset(-18);
        }];
        
        // 底部segement
        [self.panelTabbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.equalTo(@44);
        }];
        
        [self.audioFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@200);
        }];
    }
    
    
    //所有tabbar的标题都来自面板里
    self.panelTabbar.sectionTitles = self.panelView.titles;
    self.panelTabbar.frame = CGRectMake(0, 20, self.view.width, 40);
    self.panelTabbar.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.panelTabbar.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.panelTabbar.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.panelTabbar.shouldAnimateUserSelection = NO;
    self.panelTabbar.selectionIndicatorColor = [UIColor redColor];
    self.panelTabbar.selectionIndicatorBoxColor = [UIColor redColor];
    self.panelTabbar.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 0, 20);
    [self.panelTabbar setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    
    //编辑面板视图
    [self.view addSubview:self.panelView];
    CGFloat height = [self.panelView panelHeightForIndex:0];
    [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.panelTabbar.mas_top);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(height));
    }];
    self.panelView.backgroundColor = [UIColor ksy_colorWithHex:0x07080b andAlpha:0.8];
    self.panelView.delegate = self; //代理
    self.panelView.audioEffectDelegate = self; //音效代理
    self.panelView.stickerDelegate = self; //贴纸字幕代理
    self.panelView.watermarkDelegate = self;
    self.panelView.videoTrimDelegate = self;
    self.panelView.levelDelegate = self; //倍速
    self.panelView.trimVideoURL = self.videoUrl;
    self.panelView.filterEffectDelegate = self;
    
    //音频剪裁相关
    [self.view addSubview:self.audioTrimView];
    self.audioTrimView.delegate = self;
    [self.audioTrimView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.left.right.equalTo(self.view);
        }
        make.bottom.equalTo(self.panelView.mas_top).offset(0);
        make.height.mas_equalTo(@60);
    }];
    
    [self.view bringSubviewToFront:self.audioTrimView];
    
    
    //时间线视图
    self.timelineView = [[KSYTimelineView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenWidth / 8)];
    self.timelineView.backgroundColor = [UIColor whiteColor];
    self.timelineView.delegate = self;
    [self.view addSubview:self.timelineView];
    [self.timelineView updateTimelineViewAlpha:0.5];
    [self.timelineView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.backBtn.mas_bottom).offset(20);
            make.height.equalTo(@(kScreenWidth / 8));
        } else {
            make.top.equalTo(self.backBtn.mas_bottom).offset(20);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@(kScreenWidth / 8));
        }
    }];

    
    //装载当前视频到 时间线视图里面
    AVAsset *videoAsset = [AVAsset assetWithURL:self.videoUrl];
    KSYTimelineMediaInfo *mediaInfo = [[KSYTimelineMediaInfo alloc] init];
    mediaInfo.mediaType = KSYMETimelineMediaInfoTypeVideo;
    mediaInfo.path = [self.videoUrl path];
    mediaInfo.duration = CMTimeGetSeconds(videoAsset.duration);
    self.mediaInfo = mediaInfo;
    
    [self.timelineView setMediaClips:@[mediaInfo] segment:8.0 photosPersegent:8.0];
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGesture:)];
//    [self.view addGestureRecognizer:pan];
    
    //特效预览 view
    self.effectLineView = [[KSYEffectLineView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.effectLineView];
    [self.view bringSubviewToFront:self.effectLineView];
    [self.effectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.backBtn.mas_bottom).offset(20);
            make.height.equalTo(@40);
        } else {
            make.top.equalTo(self.backBtn.mas_bottom).offset(20);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@40);
        }
    }];
    self.effectLineView.delegate = self;
    [self.effectLineView startEffectByURL:self.videoUrl];
    self.effectLineView.hidden = YES;
    
    //变声
    self.reverbKnob.minimumValue = 0.0f;
    self.reverbKnob.maximumValue = 100.0f;
    self.reverbKnob.value = 0.0;
    self.reverbKnob.defaultValue = 0.0;

    self.pitchKnob.minimumValue = -2400.0f;
    self.pitchKnob.maximumValue = 2400.0f;
    self.pitchKnob.value = 1.0;
    self.pitchKnob.defaultValue = 1.0;
    
    self.delayKnob.minimumValue = 0.0f;
    self.delayKnob.maximumValue = 100.0f;
    self.delayKnob.value = 50.0f;
    self.delayKnob.defaultValue = 50.0f;
}

// 根据 resizeMode、resizeRatio 对 previewBGView、decalBGView、decalViews、GPUImageView 进行resize
- (void)resizePreviewBGViewWithResizeMode:(KSYMEResizeMode)mode Ratio:(KSYMEResizeRatio)ratio{
    _resizeMode = mode;
    _resizeRatio = ratio;
    // 1. 分辨率
    CGFloat pWidth, pHeight = 0.0;
    if (_videoMeta.degree == 90 || _videoMeta.degree == -90){
        pWidth  = _videoMeta.naturalSize.height;
        pHeight = _videoMeta.naturalSize.width;
    }else{
        pWidth  = _videoMeta.naturalSize.width;
        pHeight = _videoMeta.naturalSize.height;
    }
    
    // 2. 展示区域
    CGFloat vWidth, vHeight = 0.0;
    vWidth = kScreenMinLength;
    if (ratio == KSYMEResizeRatio_9_16) {
        vHeight = kScreenMinLength / 9. * 16.;
    }else if (ratio == KSYMEResizeRatio_3_4){
        vHeight = vWidth / 3. * 4.;
    }else if (ratio == KSYMEResizeRatio_1_1){
        vHeight = kScreenMinLength;
    }else {
        // 其他比例按同样方式计算即可
    }
    
    // 3. 画布frame
    CGFloat cX, cY, cWidth, cHeight = 0.0;
    if (mode == KSYMEResizeModeFill) {   // 填充模式
        if (pWidth / pHeight <= vWidth / vHeight) {
            cHeight = vHeight;
            cWidth = cHeight * (pWidth / pHeight);
            cX = (vWidth - cWidth) * 0.5;
            cY = 0;
        }else{
            cWidth = vWidth;
            cHeight = cWidth / (vWidth / vHeight);
            cX = 0;
            cY = (cHeight - vHeight) * 0.5;
        }
    }else{  // 裁剪模式
        if (pWidth / pHeight <= vWidth / vHeight) {
            cWidth = vWidth;
            cHeight = cWidth / (pWidth / pHeight);
            cX = 0;
            cY = (vHeight - cHeight) * 0.5;
        }else{
            cHeight = vHeight;
            cWidth = cHeight * (pWidth / pHeight);
            cX = (vWidth - cWidth) * 0.5;
            cY = 0;
        }
    }
    CGRect previewFrame;
    CGRect vFrame = CGRectMake(0, (kScreenMaxLength - vHeight) * 0.5, vWidth, vHeight);
    CGSize contentSize = CGSizeZero;
    CGPoint contentOffset = CGPointMake(-cX, -cY);
    if (mode == KSYMEResizeModeFill) {
        // TODO: 优化填充模式交互（增加手势滑动）
        previewFrame = CGRectMake(0, 0, cWidth, cHeight);
        contentSize = CGSizeMake(vWidth, vHeight);
    }else{
        previewFrame = CGRectMake(0, 0, cWidth, cHeight);
        contentSize = CGSizeMake(cWidth, cHeight);
    }
    
    // update _previewBGView constraints
    _previewBGView.frame = vFrame;
    
    _previewBGView.bounds = CGRectMake(0, 0, vWidth, vHeight);
    _previewBGView.contentSize = contentSize;
    _previewBGView.contentOffset = contentOffset;
    
    // decalBGView && decalViews
//    CGFloat decalBGView_X = (kScreenMinLength - MIN(cWidth, vWidth)) * 0.5;
    CGFloat decalBGView_Y = (kScreenMaxLength - vHeight) * 0.5;
// if (vWidth / vHeight < 9 : 16) { offset X = 0 }
//    CGFloat offsetX = _decalBGView.frame.origin.x - decalBGView_X;
    CGFloat offsetY = _decalBGView.frame.origin.y - decalBGView_Y;
    _decalBGView.frame = CGRectMake(0, (kScreenMaxLength - vHeight) * 0.5 , vWidth, vHeight);
    [_decalBGView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.bounds = CGRectMake(0 , 0, obj.bounds.size.width, obj.bounds.size.height);
        obj.center = CGPointMake(obj.frame.origin.x + obj.frame.size.width * 0.5, obj.frame.origin.y + offsetY + obj.frame.size.height * 0.5);
    }];
    
    // reframe preview view
    _editor.previewView.frame = previewFrame;
    
    [self.view layoutIfNeeded];
}
#pragma mark - Pan gesture

- (void)panWithGesture:(UIPanGestureRecognizer *)pan {
    CGPoint draggingPoint = [pan locationInView:self.view];
    CGPoint audioPoint = [self.view convertPoint:draggingPoint toView:self.audioTrimView];
    if ([self.audioTrimView pointInside:audioPoint withEvent:nil]) {
        NSLog(@"%@",NSStringFromCGPoint(draggingPoint));
        
//        _leftConstraint.offset = draggingPoint.x;
//        _topConstraint.offset = draggingPoint.y;
    } else {
        NSLog(@"其它View pan");
    }
}

- (void)startPreview{
    [_editor startPreview:self.previewBGView loop:NO];
}

- (void)pausePreview{
    _waterMarkLayer.hidden = NO;
    [_editor pausePreview];
}

- (void)startCompose{
    [self pausePreview];
    // hud
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.mode = MBProgressHUDModeDeterminate;
    progressHud.label.text = @"文件合成中...";
    progressHud.detailsLabel.text = @"0.00 %";
    progressHud.animationType = MBProgressHUDAnimationZoomIn;
    
    // 合成参数设置
    CGSize resolution = [_outputModel getResolutionFromPreset];
    resolution = [self checkOutPutSize:resolution];
    NSUInteger w = resolution.width;
    NSUInteger h = resolution.height;
    NSUInteger vb = _outputModel.videoKbps;
    NSUInteger ab = _outputModel.audioKbps;
    NSUInteger videoCodec = _outputModel.videoCodec;
    NSUInteger audioCodec = _outputModel.audioCodec;
    // 输出格式
    NSUInteger outputFmt = _outputModel.videoFormat;
    
    NSString *outStr;
    if (outputFmt == KSYOutputFormat_MP4) {
        outStr = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%ld.mp4",time(NULL)];
    }else{
        outStr = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%ld.gif",time(NULL)];
    }
    
    // 根据选择的ratio模式计算宽高（其他任意比例，按此方式计算即可）
    w = MIN(w, h);
    switch (_resizeRatio) {
        case KSYMEResizeRatio_1_1:
            h = w;
            break;
        case KSYMEResizeRatio_3_4:
            h = w / 3. * 4;
            break;
        case KSYMEResizeRatio_9_16:
            h = w / 9. * 16;
            break;
    }
    
    // 计算裁剪原点
    CGFloat x = 0;
    CGFloat y = 0;
    if (_resizeMode == KSYMEResizeModeClip) {
        x = _previewBGView.contentOffset.x / _previewBGView.contentSize.width;
        y = _previewBGView.contentOffset.y / _previewBGView.contentSize.height;
    }else{
        // 计算填充原点
    }
    
    // 片尾视频地址
    NSString *tailLeaderPath = [[NSBundle mainBundle] pathForResource:@"TailLeader" ofType:@"mp4"];
    
    _editor.outputSettings = @{kSYVideoOutputWidth:@(w),                    // 输出视频 宽
                               kSYVideoOutputHeight:@(h),                   // 输出视频 高
                               kSYVideoOutputResizeMode:@(_resizeMode),     // resize 模式
                               KSYVideoOutputClipOrigin:NSStringFromCGPoint(CGPointMake(x, y)),
                               KSYVideoOutputCodec:@(videoCodec),       // 视频编码器
                               KSYVideoOutputAudioCodec:@(audioCodec),  // 音频编码器
                               KSYVideoOutputVideoBitrate:@(vb),    // 视频码率
                               KSYVideoOutputAudioBitrate:@(ab),    // 音频码率
                               KSYVideoOutputFramerate:@(30),       // 帧率
                               KSYVideoOutputFormat:@(outputFmt),   // 输出格式
                               KSYVideoTailLeaderVideoPath:tailLeaderPath,      // 片尾
                               KSYVideoOutputPath:outStr            // 输出路径
                               };
    
    NSLog(@"合成参数:%@",_editor.outputSettings);
    if (self.decalBGView.subviews.count > 0) {
        _editor.uiElementView = self.decalBGView;
        _curDecalView.select = NO;
//        _editor.timeLineItems = [self.timelineView getAllAddedItems];
    }
    
    [_editor startProcessVideo];
}

-(CGSize)checkOutPutSize:(CGSize)size
{
    MediaMetaInfo *meta = [KSYMediaHelper videoMetaFrom:_videoUrl];
    
    CGFloat width;
    CGFloat height;
    if (meta.naturalSize.width < meta.naturalSize.height) {
        width = MIN(size.width, size.height);
        height = MAX(size.width, size.height);
    }else {
        width = MAX(size.width, size.height);
        height = MIN(size.width, size.height);
    }
    
    return CGSizeMake(width, height);
}

- (void)updatePanelConstrains:(NSUInteger)index {
    CGFloat height = [self.panelView panelHeightForIndex:index];
    [self.panelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.panelView layoutIfNeeded];
    }];
}


/**
 显示输出配置
 */
- (void)showOutputConfigVC{
    KSYOutputCfgViewController *cfgVC = [[KSYOutputCfgViewController alloc] initWithNibName:[KSYOutputCfgViewController className] bundle:[NSBundle mainBundle]];
    self.outputCfgVC = cfgVC;
    self.outputCfgVC.delegate = self;
    //配置转场
    self.outputCfgVC.outputModel = self.outputModel;
    //输出配置转场
    self.slideInTransitioningDelegate = nil;
    //控制现实遮盖的视图转场
    self.slideInTransitioningDelegate = [[SlideInPresentationManager alloc] init];
    self.slideInTransitioningDelegate.direction = PresentationDirectionBottom;
    self.slideInTransitioningDelegate.disableCompactHeight = NO;
    self.slideInTransitioningDelegate.sliderRate = 2.0/5.0;
    self.outputCfgVC.transitioningDelegate = self.slideInTransitioningDelegate;
    self.outputCfgVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:self.outputCfgVC animated:YES completion:nil];
}

#pragma mark - Decals
// 创建贴纸
- (void)genDecalViewWithImgName:(NSString *)imgName type:(DecalType)type{
    [self.editor pausePreview];

    // 1. 创建贴纸
    UIImage *image = [UIImage imageNamed:imgName];
    KSYDecalView *decalView = [[KSYDecalView alloc] initWithImage:image Type:type];
    decalView.delegate = self;
    if (type == DecalType_SubTitle) {
        // 气泡字幕需要计算文字的输入范围，每个气泡的展示区域不一样
        [decalView calcInputRectWithImgName:imgName];
    }
    _curDecalView.select = NO;
    decalView.select = YES;
    _curDecalView = decalView;
    
    // 2. 添加至decalBGView上
    [self.decalBGView addSubview:decalView];
    
    
    self.playBtn.hidden = NO;
    // 3. 添加timeLineItem 模型
    KSYMETimeLineItem *item = nil;
    if (type == DecalType_DyImage) {
        item = [[KSYMETimeLineDyImageItem alloc] init];
        item.target = decalView;
        item.effectType = KSYMETimeLineItemTypeDyImage;
        item.startTime = CMTimeGetSeconds([self.editor getPreviewCurrentTime]);
        CGFloat remainingTime = _mediaInfo.duration - item.startTime;
        item.endTime = remainingTime > 2 ? item.startTime + 2 : _mediaInfo.duration;
        [(KSYMETimeLineDyImageItem*)item setResource:imgName];
    } else{
        item =[[KSYMETimeLineItem alloc] init];
        item.target = decalView;
        item.effectType = KSYMETimeLineItemTypeDecal;
        item.startTime = CMTimeGetSeconds([self.editor getPreviewCurrentTime]);
        CGFloat remainingTime = _mediaInfo.duration - item.startTime;
        item.endTime = remainingTime > 2 ? item.startTime + 2 : _mediaInfo.duration;
    }
    [self.timelineView addTimelineItem:item];
    [self.timelineView editTimelineItem:item];
    [self.editor addTimeLineItem:item];
    
//    _editor.timeLineItems = [self.timelineView getAllAddedItems];
    
    decalView.frame = CGRectMake((self.decalBGView.frame.size.width - image.size.width * 0.5) * 0.5,
                                 (self.decalBGView.frame.size.height - image.size.height * 0.5) * 0.5,
                                 image.size.width * 0.5, image.size.height * 0.5);
    
    // 3. 贴纸对象手势交互
    // pan
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [decalView addGestureRecognizer:panGes];
    // tap
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [decalView addGestureRecognizer:tapGes];
    // pinch
    UIPinchGestureRecognizer *pinGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [decalView addGestureRecognizer:pinGes];
    // 旋转&缩放
    [decalView.dragBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleAndRotate:)]];
    // double click
    if (type == DecalType_SubTitle) {
        UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startEditing:)];
        doubleTapGes.numberOfTapsRequired = 2;
        [decalView addGestureRecognizer:doubleTapGes];
    }
}

- (void)startEditing:(UITapGestureRecognizer *)tapGes{
    _curDecalView = (KSYDecalView *)[tapGes view];
    _curDecalView.select = YES;
    [_curDecalView becomeFirstResponder];
}

- (void)scaleAndRotate:(UIPanGestureRecognizer *)gesture{
    if (_curDecalView.isSelected) {
        CGPoint curPoint = [gesture locationInView:self.view];
        if (gesture.state == UIGestureRecognizerStateBegan) {
            _loc_in = [gesture locationInView:self.view];
        }
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            _curDecalView.oriTransform = _curDecalView.transform;
        }
        
        // 计算缩放
        CGFloat preDistance = [self getDistance:_loc_in withPointB:_curDecalView.center];
        CGFloat curDistance = [self getDistance:curPoint withPointB:_curDecalView.center];
        CGFloat scale = curDistance / preDistance;
        //        NSLog(@"prePoint %@ curpoint %@ -----scale %f -----",NSStringFromCGPoint(_loc_in), NSStringFromCGPoint(curPoint), scale);
        
        // 计算弧度
        CGFloat preRadius = [self getRadius:_curDecalView.center withPointB:_loc_in];
        CGFloat curRadius = [self getRadius:_curDecalView.center withPointB:curPoint];
        CGFloat radius = curRadius - preRadius;
        radius = - radius;
        //        NSLog(@"preRaduis %f curRaduis %f --- radius %f---" ,preRadius, curRadius, radius);
        CGAffineTransform transform = CGAffineTransformScale(_curDecalView.oriTransform, scale, scale);
        //        _curDecalView.transform = transform;
        _curDecalView.transform = CGAffineTransformRotate(transform, radius);
        
        if (gesture.state == UIGestureRecognizerStateEnded ||
            gesture.state == UIGestureRecognizerStateCancelled) {
            _curDecalView.oriScale = scale * _curDecalView.oriScale;
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tapGes{
    if ([[tapGes view] isKindOfClass:[KSYDecalView class]]){
        [self.editor pausePreview];
        self.playBtn.hidden = NO;
        KSYDecalView *view = (KSYDecalView *)[tapGes view];
        [self.timelineView editTimelineComplete];
        KSYMETimeLineItem *item = [self.timelineView getTimelineItemWithOjb:view];

        if (view != _curDecalView) {
            [self.timelineView editTimelineItem:item];

            _curDecalView.select = NO;
            view.select = YES;
            _curDecalView = view;
        }else{
            view.select = !view.select;
            if (view.select) {
                [self.timelineView editTimelineItem:item];
                _curDecalView = view;
            }else{
                _curDecalView = nil;
            }
        }
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)pinGes{
    if ([[pinGes view] isKindOfClass:[KSYDecalView class]]){
        KSYDecalView *view = (KSYDecalView *)[pinGes view];
        
        if (pinGes.state ==UIGestureRecognizerStateBegan) {
            view.oriTransform = view.transform;
        }
        
        if (pinGes.state ==UIGestureRecognizerStateChanged) {
            _curScale = pinGes.scale;
            CGAffineTransform tr = CGAffineTransformScale(view.oriTransform, pinGes.scale, pinGes.scale);
            
            view.transform = tr;
        }
        
        // 当手指离开屏幕时,将lastscale设置为1.0
        if ((pinGes.state == UIGestureRecognizerStateEnded) || (pinGes.state == UIGestureRecognizerStateCancelled)) {
            view.oriScale = view.oriScale * _curScale;
            pinGes.scale = 1;
        }
    }
}

- (void)move:(UIPanGestureRecognizer *)panGes {
    if ([[panGes view] isKindOfClass:[KSYDecalView class]]){
        CGPoint loc = [panGes locationInView:self.view];
        KSYDecalView *view = (KSYDecalView *)[panGes view];
        if (_curDecalView.select) {
            if ([_curDecalView pointInside:[_curDecalView convertPoint:loc fromView:self.view] withEvent:nil]){
                view = _curDecalView;
            }
        }
        if (!view.select) {
            return;
        }
        if (panGes.state == UIGestureRecognizerStateBegan) {
            _loc_in = [panGes locationInView:self.view];
            _ori_center = view.center;
        }
        
        CGFloat x;
        CGFloat y;
        x = _ori_center.x + (loc.x - _loc_in.x);

        y = _ori_center.y + (loc.y - _loc_in.y);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0 animations:^{
                view.center = CGPointMake(x, y);
                //                NSLog(@"%@ - %@ - %@", NSStringFromCGPoint(_loc_in), NSStringFromCGPoint(loc), NSStringFromCGPoint(view.center));
            }];
        });
    }
}

// 距离
-(CGFloat)getDistance:(CGPoint)pointA withPointB:(CGPoint)pointB
{
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    
    return sqrt(x*x + y*y);
}

// 角度
-(CGFloat)getRadius:(CGPoint)pointA withPointB:(CGPoint)pointB
{
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    return atan2(x, y);
}

#pragma mark - Getter & Setter
- (UIView *)decalBGView{
    if (!_decalBGView) {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat width = 0;
        CGFloat height = 0;
        
        MediaMetaInfo *videoMeta = [KSYMediaHelper videoMetaFrom:_videoUrl];
        if (videoMeta.degree == 90 || videoMeta.degree == -90){
            width  = videoMeta.naturalSize.height;
            height = videoMeta.naturalSize.width;
        }else{
            width  = videoMeta.naturalSize.width;
            height = videoMeta.naturalSize.height;
        }
        // 视频分辨率
        CGSize vSize = CGSizeMake(width, height);
        
        CGFloat vWidth = kScreenSizeWidth;
        CGFloat vHeight = kScreenSizeHeight;
        
        if (vSize.width / vSize.height < kScreenSizeWidth / kScreenSizeHeight) {
            vWidth = vSize.width / vSize.height * kScreenSizeHeight;
            x = (kScreenSizeWidth - vWidth) * 0.5;
        }else if (vSize.width / vSize.height > kScreenSizeWidth / kScreenSizeHeight){
            vHeight = vSize.height / vSize.width * kScreenSizeWidth;
            y = (kScreenSizeHeight - vHeight) * 0.5;
        }
        
        _decalBGView = [[KSYDecalBGView alloc] initWithFrame:CGRectMake(x, y, vWidth, vHeight)];
        [self.view insertSubview:_decalBGView atIndex:1];
        _decalBGView.center = self.previewBGView.center;
    }
    return _decalBGView;
}


#pragma mark -
#pragma mark - Actions & Gestures
- (IBAction)didClickBackBtn:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)didClickPlayBtn:(UIButton *)sender {
    [_editor resumePreview];
    _playBtn.hidden = YES;
    [self.timelineView editTimelineComplete];
}

- (IBAction)didClickComposeBtn:(UIButton *)sender {
    [self showOutputConfigVC];
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan ) {
        [self.editor setEffectType:KSYAudioEffectType_COUSTOM];
        [self.editor setEffectTypeFlag:0];
        
        self.audioFilterView.hidden = !self.audioFilterView.hidden;
    }
}


- (IBAction)tabbarPanelChange:(HMSegmentedControl *)sender {
    self.panelView.hidden = NO; //切换tab时候显示功能面板
    [self updatePanelConstrains:sender.selectedSegmentIndex];
    [self.panelView changeLayoutByIndex:sender.selectedSegmentIndex];
    
    NSString *title = self.panelView.titles[sender.selectedSegmentIndex];
    [self handleTabbarClick:title];
}


/**
 处理各种需要底部分段控件点击回调需要触发事件,这里用的是字符串实际开发过程中可以用索引区分.
 
 @param title 当前点击的标题
 */
- (void)handleTabbarClick:(NSString *)title{
    //tabbar 点击 音乐控件底部
    if ([title isEqualToString:kKSYEditPanelTitleMusic] && self.audioTrimView.filePath.length > 0) {
        self.audioTrimView.hidden = NO;
    } else {
        self.audioTrimView.hidden = YES;
    }
    //tabbar 点击 特效滤镜控件底部
    if ([title isEqualToString:kKSYEditPanelTitleFilterEffect]) {
        if (!self.timelineView.hidden) { self.timelineView.hidden = YES; }
        if (self.effectLineView.hidden) { self.effectLineView.hidden = NO; }
    } else {
        if (!self.effectLineView.hidden) { self.effectLineView.hidden = YES; }
        if (self.timelineView.hidden) { self.timelineView.hidden = NO; }
    }
}

//KSYEditPanelView Delegate 面板代理
- (void)editPanelView:(KSYEditPanelView *)view scrollPage:(NSUInteger)page{
    [self updatePanelConstrains:page];
    [self.panelTabbar setSelectedSegmentIndex:page animated:YES];
}

// bgview 响应事件
- (void)onTouchBGView:(UITapGestureRecognizer *)touches{
    touches.cancelsTouchesInView = NO;
    
    // 取消贴纸、字幕的选中状态
    if (_curDecalView) {
        _curDecalView.select = NO;
        [self.timelineView editTimelineComplete];
    }
    
    // 回收键盘
    [self.view endEditing:YES];
    
    //隐藏显示底部功能面板
    self.panelView.hidden = !self.panelView.hidden;
    //判断是否是音乐点击
    if (self.panelTabbar.selectedSegmentIndex == 4 &&
        self.audioTrimView.filePath.length > 0) {
        self.audioTrimView.hidden = self.panelView.hidden;
    }
}

- (IBAction)knobAction:(THGreenControlKnob *)sender {
    if (sender.tag == 200) {
        //混响
        [self.editor setReverbParamID:kReverb2Param_DryWetMix value:sender.value];
    } else if (sender.tag == 201) {
        //pitch
        [self.editor setPitchParamID:kNewTimePitchParam_Pitch value:sender.value];
    } else if (sender.tag == 202) {
        //delay
        [self.editor setDelayParamID:kDelayParam_WetDryMix value:sender.value];
    }
}


- (IBAction)effectFlayValueChange:(UISegmentedControl *)sender {
    [self.editor setEffectTypeFlag:(int)sender.selectedSegmentIndex];
    
}

#pragma mark - 
#pragma mark - UIGestureRecognizer 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //忽略self.view 的tap点击视图
    if (gestureRecognizer == self.tapGes &&
        ([touch.view isDescendantOfView:self.panelView] ||
         [touch.view isDescendantOfView:self.audioTrimView] ||
         [touch.view isDescendantOfView:self.timelineView] ||
         [touch.view isDescendantOfView:self.playBtn] ||
         [touch.view isDescendantOfView:self.effectLineView])){
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark - KSYMEComposeDelegate
- (void)onComposeError:(KSYMediaEditor*)editor err:(KSYStatusCode)err extraStr:(NSString*)extraStr{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = extraStr;
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        
        [hud hideAnimated:YES afterDelay:2.f];
        
        [[[UIAlertView alloc] initWithTitle:@"composite fail" message:[NSString stringWithFormat:@"errCode:%ld\nmessage:%@",(long)err, extraStr] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [weakSelf.editor resumePreview];
    });
}

- (void)onComposeProgressChanged:(float)value{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud setProgress:value];
        hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%",(value * 100)];
    });
}

- (void)onComposeFinish:(NSURL *)path thumbnail:(UIImage *)thumbnail{
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        KSYPublishViewController *publishVC;
        if ([[path absoluteString] hasSuffix:@".gif"]) {
            publishVC = [[KSYPublishViewController alloc] initWithGif:path];
        }else{
            publishVC = [[KSYPublishViewController alloc] initWithUrl:path coverImage:thumbnail];
        }
        
        [weakSelf.navigationController pushViewController:publishVC animated:YES];
    });
}

#pragma mark - 
#pragma mark - KSYMEPreviewDelegate
/**
 编辑时开启预览失败, 当合成转码或准备视频文件情况下开启预览可能失败
 @param error 错误描述
 */
- (void)onPlayStartFail:(NSError *)error{
    NSLog(@"调用开始预览时发生错误:%@",[error localizedDescription]);
}

- (void)onPlayStatusChanged:(KSYMEPreviewStatus)status{
    NSLog(@"play status changed : %ld",status);
    
    if (status == KSYPreviewPlayerStop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playBtn.hidden = NO;
        });
    }
    
    if (status == KSYPreviewPlayerPause ||
        status == KSYPreviewPlayerStop){
        // tmpItem is not nil means effectLineView is drawing
        if (_tmpItem && self.effectLineView) {
            // 1. draw effectLineView
            [self.effectLineView drawViewByStatus:KSYELViewCursorStatusDrawEnd
                                         andColor:nil
                                          forType:-1];
            // 2. update tmp item
            _tmpItem.endTime = CMTimeGetSeconds([_editor getPreviewCurrentTime]);
            [self.editor updateTimeLineItem:_tmpItem];
            _tmpItem = nil;
        }
    }
    
}

- (void)onPlayProgressChanged:(CMTimeRange)time percent:(float)percent{
    Float64 currentTime = CMTimeGetSeconds(time.duration) * percent + CMTimeGetSeconds(time.start);
    
    [self.timelineView seekToTime:currentTime];
    
    [self.effectLineView seekToTime:currentTime];
}

//美颜代理
- (void)editPanelView:(KSYEditPanelView *)view
           filterType:(KSYMEBeautyKindType)type{
    // demo演示 KSYBeautifyProFilter 的使用，不同滤镜参数设置均类似
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
    [self.editor setFilter:bf];
    
}

//音乐代理
- (void)editPanelView:(KSYEditPanelView *)view songFilePath:(NSString *)filePath{
    NSLog(@"选择背景音乐:%@",filePath);
    [_editor pausePreview];
    [_editor seekToTime:kCMTimeZero range:kCMTimeRangeInvalid finish:nil];
    [_editor addBgm:filePath loop:YES];
    [_editor resumePreview];
    
    if (filePath.length > 0) {
        self.audioTrimView.hidden = NO;
        self.audioTrimView.filePath = filePath;
        [self.audioTrimView openFileWithFilePathURL:[NSURL URLWithString:filePath]];
    } else {
        self.audioTrimView.filePath = @"";
        self.audioTrimView.hidden = YES;
    }
}

- (void)editPanelView:(KSYEditPanelView *)view
      audioVolumnType:(KSYMEAudioVolumnType)type
             andValue:(float)value{
    if (type == KSYMEAudioVolumnTypeMicphone) {
        NSLog(@"原声:%f",value);
        [_editor adjustRawVolume:value];
    } else if (type == KSYMEAudioVolumnTypeBgm) {
        NSLog(@"配乐:%f",value);
        [_editor adjustBGMVolume:value];
    }
}

//变成和混响代理
- (void)audioEffectType:(KSYMEAudioEffectType)type
               andValue:(NSInteger)value{
    if (type == KSYMEAudioEffectTypeChangeVoice){
        [_editor setEffectType:(KSYAudioEffectType)value];
    } else if (type == KSYMEAudioEffectTypeChangeReverb){
        [_editor setReverbType:(KSYMEReverbType)value];
    }
}

//贴纸和字幕代理
- (void)editPanelStickerType:(KSYMEEditStickerType)type selectedIndex:(NSInteger)index{
    if (type == KSYMEEditStickerTypeSticker) {
        NSString *imgName = [NSString stringWithFormat:@"decal_%ld", index];
        [self genDecalViewWithImgName:imgName type:DecalType_Sticker];
    } else if (type == KSYMEEditStickerTypeSubtitle) {
        NSString *imgName = [NSString stringWithFormat:@"decal_t_%ld", index];
        [self genDecalViewWithImgName:imgName type:DecalType_SubTitle];
    } else if (type == KSYMEEditStickerTypeAnimatedImage){
        NSLog(@"选择贴纸%zd",index);
        NSString *ext = index >= 5 ?@"png":@"gif";
        NSString *gifName = [NSString stringWithFormat:@"dynamic_image%zd",index + 1];
        NSString *gifFilePath = [[NSBundle mainBundle] pathForResource:gifName ofType:ext];
        [self genDecalViewWithImgName:gifFilePath type:DecalType_DyImage];
    }
}

//水印
- (void)editWatermarkCell:(KSYEditWatermarkCell *)cell
            showWatermark:(BOOL)isShowWatermark{
    UIImage *waterMarkImg = nil;
    if (isShowWatermark) {
        waterMarkImg = [UIImage imageNamed:@"watermark"];
    }
    if (!_waterMarkLayer) {
        _waterMarkLayer = [CALayer layer];
        _waterMarkLayer.contents = (__bridge id _Nullable)(waterMarkImg.CGImage);
        // rect 为(0.1, 0.1, 0.2, 0) 根据需求设置x，y，width，height
        _waterMarkLayer.frame = CGRectMake(0.1 * _previewBGView.frame.size.width,
                                           0.1 * _previewBGView.frame.size.height,
                                           0.2 * _previewBGView.frame.size.width,
                                           0.2 * _previewBGView.frame.size.width / waterMarkImg.size.width * waterMarkImg.size.height);
    }
    
    
    if (isShowWatermark) {
        [self.decalBGView.layer addSublayer:_waterMarkLayer];
    }else{
        [_waterMarkLayer removeFromSuperlayer];
    }
    
    // rect 为(0.1, 0.1, 0.2, 0) 根据需求设置x，y，width，height(width, height 设置其中一个将按照图片宽高比进行resize)
    [_editor setWaterMarkImage:waterMarkImg waterMarkRect:CGRectMake(0.1, 0.1, 0.2, 0) andAplpha:1.0];
}

#pragma mark - KSYEditTrimDelegate
- (void)editTrimWillStartSeekType:(KSYMEEditTrimType)type{
    [_editor pausePreview];
    _playBtn.hidden = NO;
}

- (void)editTrimType:(KSYMEEditTrimType)type range:(CMTimeRange)range{
    NSLog(@"时长裁剪 from %f to %f",CMTimeGetSeconds(range.start), CMTimeGetSeconds(CMTimeRangeGetEnd(range)));
    self.videoRange = range;
    __weak typeof(self) weakSelf = self;
    if (type == KSYMEEditTrimTypeVideo) {
        [_editor pausePreview];
        [_editor seekToTime:range.start range:range finish:^{
            weakSelf.playBtn.hidden = NO;
        }];
    } else if (type == KSYMEEditTrimTypeAudio) {
        // 视频从头开始播放，确保预览效果与最终合成效果一致
        [_editor seekToTime:kCMTimeZero range:kCMTimeRangeInvalid finish:nil];
        [_editor seekBGMToTime:range.start range:range finish:nil];
        [_editor resumePreview];
        _playBtn.hidden = YES;
    }
}

- (void)didChangeResizeMode:(KSYMEResizeMode)mode{
    [self resizePreviewBGViewWithResizeMode:mode Ratio:_resizeRatio];
}

- (void)didChangeRatio:(KSYMEResizeRatio)ratio{
    [self resizePreviewBGViewWithResizeMode:_resizeMode Ratio:ratio];
}

//倍速代理
- (void)editLevel:(NSInteger)index{
    [self.editor setPlayerRate:(index+1)*0.5];
}

- (void)editTimeEffect:(NSInteger)index{
    NSDictionary *params;
    KSYTEType type = (KSYTEType)index;
    switch (type) {
        case KSYTEType_NONE:
            break;
        case KSYTEType_Reverse:
            break;
        case KSYTEType_Repeat:
            // 从视频中间开始,长度0.5s,重复2次
            params = @{@"startTime":@(_mediaInfo.duration / 2.0),
                       @"duration":@(0.5),
                       @"repeatCount":@(2)
                       };
            break;
        case KSYTEType_SlowMotion:
            // 从视频中间开始,长度3s，0.5倍速
            params = @{@"startTime":@(_mediaInfo.duration / 2.0),
                       @"duration":@(3),
                       @"ratio":@(0.5)
                       };
            break;
    }
    [self.editor setTimeEffect:type parameters:params];
    [self.editor resumePreview];
    _playBtn.hidden = YES;
}

#pragma mark -
#pragma mark - KSYOutputCfgViewController Delegate
- (void)outputConfigVC:(KSYOutputCfgViewController *)vc
             withModel:(OutputModel *)model
              isCancel:(BOOL)isCancelClick{
    self.outputModel = model;
    [self.outputCfgVC dismissViewControllerAnimated:YES completion:nil];
    self.outputCfgVC = nil;
    self.slideInTransitioningDelegate = nil;
    [self startCompose];
}

#pragma mark -
#pragma mark - KSYTimelineViewDelegate 时间线代理
- (void)timelineDraggingTimelineItem:(KSYMETimeLineItem *)item {
//    self.editor.timeLineItems = [self.timelineView getAllAddedItems];
    [self.editor updateTimeLineItem:item];
}

- (void)timelineBeginDragging {
    [_editor pausePreview];
    self.playBtn.hidden = NO;
    [_curDecalView setSelect:NO];
}

//滑动
- (void)timelineDraggingAtTime:(CGFloat)time {
    // 确保精度达到0.001
    CMTime seekTime = CMTimeMakeWithSeconds(time, 1000);
    [self.editor seekToTime:seekTime range:kCMTimeRangeInvalid finish:nil];
    
    [self.effectLineView seekToTime:time];
}

- (void)timelineEndDraggingAndDecelerate:(CGFloat)time {
    
}

#pragma mark -
#pragma mark - KSYDecalView Delegate
- (void)decalViewClose:(KSYDecalView *)decalView{
    KSYMETimeLineItem *item = [self.timelineView getTimelineItemWithOjb:decalView];
    [self.timelineView removeTimelineItem:item];
    [_editor deleteTimeLineItem:item];
}


#pragma mark -
#pragma mark - KSYEffectLineView Delegate 时间特效控件相关代理
- (void)effectLineView:(KSYEffectLineView *)effectLineView
                 state:(UIGestureRecognizerState)state
       cursorMoveRatio:(CGFloat)ratio{
    if (state == UIGestureRecognizerStateBegan) {
        [self.editor pausePreview];
        self.playBtn.hidden = NO;
    } else if (state == UIGestureRecognizerStateChanged) {
        CMTime seek = CMTimeMake(effectLineView.duraiton.value * ratio, effectLineView.duraiton.timescale);
        [self.editor seekToTime:seek range:kCMTimeRangeInvalid finish:nil];
    }
}

- (void)effectLineView:(KSYEffectLineView *)effectLineView
           actionState:(KSYEffectLineCursorStatus)st
      completeDrawInfo:(KSYEffectLineInfo *)info{
}

- (KSYSEType)convertType:(KSYEffectLineType)effectLineType{
    return effectLineType - 1;
}

#pragma mark -
#pragma mark - 特效滤镜 代理
- (void)editFilterEffectCell:(KSYEditFilterEffectCell *)cell
               selectedModel:(KSYFilterEffectModel *)filterModel
                    andState:(UIGestureRecognizerState)state{
    if (state == UIGestureRecognizerStateBegan) {
        if (CMTimeGetSeconds([self.editor getPreviewCurrentTime]) == _mediaInfo.duration) {
            return;
        }
        [self.effectLineView drawViewByStatus:KSYELViewCursorStatusDrawBegan
                                     andColor:filterModel.drawColor forType:filterModel.filterEffectType];
        // 1. generate tmp filter item
        _tmpItem = [[KSYMETimeLineFilterItem alloc] init];
        _tmpItem.startTime = CMTimeGetSeconds([_editor getPreviewCurrentTime]);
        _tmpItem.endTime = CGFLOAT_MAX;
        KSYSEType fType = [self convertType:filterModel.filterEffectType];
        _tmpItem.params = @{@"idx":@(fType)};
        _tmpItem.filterID = KSYMEBuiltInFilter_SuperEffect;
        [self.effectFilterTimelineArray addObject:_tmpItem];
        [self.editor addTimeLineItem:_tmpItem];

        // 2. resume preview
        [self.editor resumePreview];
        _playBtn.hidden = YES;
    } else if (state == UIGestureRecognizerStateChanged) {
        [self.effectLineView drawViewByStatus:KSYELViewCursorStatusDrawing
                                     andColor:filterModel.drawColor forType:filterModel.filterEffectType];
    } else {
        // 1. pause preview
        [self.editor pausePreview];
        _playBtn.hidden = NO;
    }
}

- (void)editFilterEffectCell:(KSYEditFilterEffectCell *)cell
                   UndoModel:(KSYFilterEffectModel *)filterModel
                 isLongPress:(BOOL)isLongPress{
    //长按删除所有
    if (isLongPress) {
        for (KSYMETimeLineFilterItem *timeLineItem in self.effectFilterTimelineArray) {
            [self.editor deleteTimeLineItem:timeLineItem];
        }
        [self.effectFilterTimelineArray removeAllObjects];
        [self.effectLineView removeAllDrawViews];
    } else {
        KSYMETimeLineFilterItem *lastTimeLineItem = [self.effectFilterTimelineArray lastObject];
        if (lastTimeLineItem) {
            [self.editor deleteTimeLineItem:lastTimeLineItem];
            [self.effectFilterTimelineArray removeLastObject];
        }
        [self.effectLineView removeLastDrawViews];
    }
}

#pragma mark - 
#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
