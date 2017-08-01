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
KSYEditOutputConfigView
>
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *composeBtn;

// Editor
@property (strong, nonatomic) KSYMediaEditor *editor;

// URL
@property (strong, nonatomic) NSURL *videoUrl;

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
@property (assign, nonatomic) KSYMEResizeMode resizeMode;
// 当前预览resize比例（默认9:16）
@property (assign, nonatomic) KSYMEResizeRatio resizeRatio;
// 视频时间裁剪
@property (assign, nonatomic) CMTimeRange videoRange;
// bgm 裁剪
@property (assign, nonatomic) CMTimeRange bgmRange;
// 输出参数模型
@property (nonatomic, strong) OutputModel *outputModel;
// 输出配置 相关
@property (nonatomic, strong)SlideInPresentationManager *slideInTransitioningDelegate;
@property (nonatomic, strong)KSYOutputCfgViewController *outputCfgVC;

@end

@implementation KSYEditViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       VideoURL:(NSURL *)url{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _videoUrl = url;
        _editor = [[KSYMediaEditor alloc] initWithURL:url];
        _editor.previewDelegate = self;
        _editor.delegate = self;
        
        // 贴纸交互 相关
        _loc_in = CGPointZero;
        _curScale = 1.0f;
        
        self.view.frame = [UIScreen mainScreen].bounds;
        self.previewBGView.frame = self.view.bounds;
        _editor.previewDelegate = self;
        _editor.delegate = self;
        [self startPreview];
        
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
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBGView:)];
    [self.view addGestureRecognizer:tapGes];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    _playBtn.hidden = YES;
    [_editor resumePreview];
    _waterMarkLayer.hidden = NO;
    [self resizePreviewBGViewWithResizeMode:_resizeMode Ratio:_resizeRatio];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.panelView reloadLevelCellIfNeeded];
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
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.width.height.mas_equalTo(30);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
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
    self.panelView.backgroundColor = [UIColor jk_colorWithHex:0x07080b andAlpha:0.8];
    self.panelView.delegate = self; //代理
    self.panelView.audioEffectDelegate = self; //音效代理
    self.panelView.stickerDelegate = self; //贴纸字幕代理
    self.panelView.watermarkDelegate = self;
    self.panelView.videoTrimDelegate = self;
    self.panelView.levelDelegate = self; //倍速
    self.panelView.trimVideoURL = self.videoUrl;
    
    
    //音频剪裁相关
    [self.view addSubview:self.audioTrimView];
    self.audioTrimView.delegate = self;
    [self.audioTrimView mas_makeConstraints:^(MASConstraintMaker *make) {
//        // 设置边界条件约束，保证内容可见，优先级1000
//        make.left.greaterThanOrEqualTo(self.view.mas_left);
//        make.right.lessThanOrEqualTo(self.view.mas_right);
//        make.top.greaterThanOrEqualTo(self.view.mas_top).offset(0);
//        make.bottom.lessThanOrEqualTo(self.view.mas_bottom);
//        
//        _leftConstraint = make.centerX.equalTo(self.view.mas_left).with.offset(0).priorityHigh(); // 优先级要比边界条件低
//        _topConstraint = make.centerY.equalTo(self.view.mas_top).with.offset(0).priorityHigh(); // 优先级要比边界条件低
//        
//        make.width.mas_equalTo(self.view.mas_width);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.panelView.mas_top).offset(0);
        make.height.mas_equalTo(@60);
    }];
    
    [self.view bringSubviewToFront:self.audioTrimView];
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGesture:)];
//    [self.view addGestureRecognizer:pan];
}

// 根据 resizeMode、resizeRatio 对 previewBGView、decalBGView、decalViews、GPUImageView 进行resize
- (void)resizePreviewBGViewWithResizeMode:(KSYMEResizeMode)mode Ratio:(KSYMEResizeRatio)ratio{
    _resizeMode = mode;
    _resizeRatio = ratio;
    // 1. 分辨率
    CGFloat pWidth, pHeight = 0.0;
    MediaMetaInfo *videoMeta = [KSYMediaHelper videoMetaFrom:_videoUrl];
    if (videoMeta.degree == 90 || videoMeta.degree == -90){
        pWidth  = videoMeta.naturalSize.height;
        pHeight = videoMeta.naturalSize.width;
    }else{
        pWidth  = videoMeta.naturalSize.width;
        pHeight = videoMeta.naturalSize.height;
    }
    
    // 2. 展示区域
    CGFloat vWidth, vHeight = 0.0;
    vWidth = kScreenMinLength;
    if (ratio == KSYMEResizeRatio_9_16) {
        vHeight = kScreenMaxLength;
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
    CGFloat decalBGView_X = (kScreenMinLength - MIN(cWidth, vWidth)) * 0.5;
    CGFloat decalBGView_Y = (kScreenMaxLength - vHeight) * 0.5;
#warning if vWidth / vHeight < 9 : 16 { offset X > 0 }
    CGFloat offsetX = _decalBGView.frame.origin.x - decalBGView_X;
    CGFloat offsetY = _decalBGView.frame.origin.y - decalBGView_Y;
    _decalBGView.frame = CGRectMake(0, (kScreenMaxLength - vHeight) * 0.5 , vWidth, vHeight);
    [_decalBGView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.bounds = CGRectMake(0 , 0, obj.bounds.size.width, obj.bounds.size.height);
        obj.center = CGPointMake(obj.frame.origin.x + obj.frame.size.width * 0.5, obj.frame.origin.y + offsetY + obj.frame.size.height * 0.5);
    }];
    
    // reframe GPUImageView
    [self.previewBGView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[GPUImageView class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.frame = previewFrame;
            });
        }
    }];
    
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
    [_editor startPreview:self.previewBGView loop:YES];
    // 开启预览后开启美颜滤镜
    [_editor setFilter:[[KSYBeautifyProFilter alloc] init]];
}

- (void)pausePreview{
    _waterMarkLayer.hidden = YES;
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
    
    _editor.outputSettings = @{kSYVideoOutputWidth:@(w),
                               kSYVideoOutputHeight:@(h),
                               kSYVideoOutputResizeMode:@(_resizeMode),
                               KSYVideoOutputClipOrigin:NSStringFromCGPoint(CGPointMake(x, y)),
                               KSYVideoOutputCodec:@(videoCodec),
                               KSYVideoOutputAudioCodec:@(audioCodec),
                               KSYVideoOutputVideoBitrate:@(vb),
                               KSYVideoOutputAudioBitrate:@(ab),
                               KSYVideoOutputFormat:@(outputFmt),
                               KSYVideoOutputPath:outStr
                               };
    
    NSLog(@"合成参数:%@",_editor.outputSettings);
    if (self.decalBGView.subviews.count > 0) {
        _editor.uiElementView = self.decalBGView;
        _curDecalView.select = NO;
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
    // 1. 创建贴纸
    UIImage *image = [UIImage imageNamed:imgName];
    KSYDecalView *decalView = [[KSYDecalView alloc] initWithImage:image Type:type];
    if (type == DecalType_SubTitle) {
        // 气泡字幕需要计算文字的输入范围，每个气泡的展示区域不一样
        [decalView calcInputRectWithImgName:imgName];
    }
    _curDecalView.select = NO;
    decalView.select = YES;
    _curDecalView = decalView;
    
    // 2. 添加至decalBGView上
    [self.decalBGView addSubview:decalView];
    
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

- (void)deleteDecal:(UIButton *)sender{
    if (_curDecalView.isSelected) {
        [_curDecalView removeFromSuperview];
    }else{
        NSLog(@"delete Btn display error");
    }
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
        KSYDecalView *view = (KSYDecalView *)[tapGes view];
        
        if (view != _curDecalView) {
            _curDecalView.select = NO;
            view.select = YES;
            _curDecalView = view;
        }else{
            view.select = !view.select;
            if (view.select) {
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
}

- (IBAction)didClickComposeBtn:(UIButton *)sender {
    [self showOutputConfigVC];
}

- (IBAction)tabbarPanelChange:(HMSegmentedControl *)sender {
    [self updatePanelConstrains:sender.selectedSegmentIndex];
    [self.panelView changeLayoutByIndex:sender.selectedSegmentIndex];
    
    NSString *title = self.panelView.titles[sender.selectedSegmentIndex];
    
    //特殊处理部分
    if ([title isEqualToString:@"美颜"]) {
        _editor.filter = !_editor.filter ? [KSYBeautifyProFilter new] : nil;
    } else if ([title isEqualToString:@"倍速"]){
        [self.panelView performSelector:@selector(reloadLevelCellIfNeeded) withObject:nil afterDelay:0.8];
    }
    
    if ([title isEqualToString:@"音乐"] && self.audioTrimView.filePath.length > 0) {
        self.audioTrimView.hidden = NO;
    } else {
        self.audioTrimView.hidden = YES;
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
    }
    
    // 回收键盘
    [_curDecalView resignFirstResponder];
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
}

- (void)onPlayProgressChanged:(CMTimeRange)time percent:(float)percent{
//    NSLog(@"play progress : %f",percent);
}

//美颜代理
- (void)editPanelView:(KSYEditPanelView *)view
           filterType:(KSYMEBeautyKindType)type
          filterIndex:(CGFloat)value{
    // demo演示 KSYBeautifyProFilter 的使用，不同滤镜参数设置均类似
    KSYBeautifyProFilter *bf = (KSYBeautifyProFilter *)[_editor filter];
    switch (type) {
        case KSYMEBeautyKindTypeFaceWhiten:
            bf.whitenRatio = value;
            break;
        case KSYMEBeautyKindTypeGrind:
            bf.whitenRatio = value;
            break;
        case KSYMEBeautyKindTypeRuddy:
            bf.whitenRatio = value;
            break;
    }
}

//音乐代理
- (void)editPanelView:(KSYEditPanelView *)view songFilePath:(NSString *)filePath{
    NSLog(@"选择背景音乐:%@",filePath);
    [_editor addBgm:filePath loop:YES];
    
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
    NSLog(@"from %f to %f",CMTimeGetSeconds(range.start), CMTimeGetSeconds(CMTimeRangeGetEnd(range)));
    __weak typeof(self) weakSelf = self;
    if (type == KSYMEEditTrimTypeVideo) {
        [_editor pausePreview];
        [_editor seekToTime:range.start range:range finish:^{
            weakSelf.playBtn.hidden = NO;
        }];
    } else if (type == KSYMEEditTrimTypeAudio) {
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
    [self.editor setPlayerRate:index*0.5];
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

@end
