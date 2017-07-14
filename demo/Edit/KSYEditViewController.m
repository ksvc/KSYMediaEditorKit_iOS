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

@interface KSYEditViewController ()
<
KSYMEPreviewDelegate,
KSYMEComposeDelegate,
KSYEditPanelViewDelegate,
KSYAudioEffectDelegate,
KSYEditStickDelegate,
KSYEditWatermarkCellDelegate
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


@property (weak, nonatomic) IBOutlet HMSegmentedControl *panelTabbar;
@property (strong, nonatomic) IBOutlet KSYEditPanelView *panelView;


@end

@implementation KSYEditViewController

- (instancetype)initWithVideoURL:(NSURL *)url{
    self = [self initWithNibName:nil bundle:nil VideoURL:url];
    if (self) {
        
    }
    return self;
}

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
        
        [self startPreview];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubviews];
    
    // bgview add gesture
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBGView:)];
    [self.view addGestureRecognizer:tapGes];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dealloc{
    [_editor stopPreview];
    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
}

#pragma mark -
#pragma mark - Private Methods
- (void)configSubviews{
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(30);
    }];
    
    [_composeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(18);
        make.right.equalTo(self.view.mas_right).offset(-18);
    }];
    
    //底部segement
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
    
    self.panelView.trimVideoURL = self.videoUrl;
}

- (void)startPreview{
    [_editor startPreview:self.view loop:YES];
}

- (void)pausePreview{
    [_editor pausePreview];
}

- (void)startCompose{
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
    
    NSString *outStr = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%ld.mp4",time(NULL)];
    
    _editor.outputSettings = @{kSYVideoOutputWidth:@(w),
                               kSYVideoOutputHeight:@(h),
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

- (IBAction)didClickComposeBtn:(UIButton *)sender {
    [self pausePreview];
    [self startCompose];
}

- (IBAction)tabbarPanelChange:(HMSegmentedControl *)sender {
    [self updatePanelConstrains:sender.selectedSegmentIndex];
    [self.panelView changeLayoutByIndex:sender.selectedSegmentIndex];
    
    NSString *title = self.panelView.titles[sender.selectedSegmentIndex];
    if ([title isEqualToString:@"美颜"]) {
        _editor.filter = !_editor.filter ? [KSYBeautifyProFilter new] : nil;
    }else{
        NSLog(@"%@",title);
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
    if (type == KSYMEAudioEffectTypeChangeTone) {
        [_editor setBgmPitch:(value * 8)];
        NSLog(@"变调级别:%zd",value);
    } else if (type == KSYMEAudioEffectTypeChangeVoice){
        [_editor setEffectType:(KSYAudioEffectType)value];
        NSLog(@"变声:%zd",value);
    } else if (type == KSYMEAudioEffectTypeChangeReverb){
        [_editor setReverbType:(KSYMEReverbType)value];
        NSLog(@"混响:%zd",value);
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
    UIImage *waterMark = nil;
    if (isShowWatermark) {
        waterMark = [UIImage imageNamed:@"watermark"];
    }
    CGRect waterRect = CGRectMake(0.1, 0.1, 0.2, 0);
    [_editor setWaterMarkImage:waterMark waterMarkRect:waterRect andAplpha:1.0];;
}
@end
