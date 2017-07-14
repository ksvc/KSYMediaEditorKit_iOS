//
//  VideoEditorViewController.m
//  demo
//
//  Created by 张俊 on 05/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "VideoEditorViewController.h"
#import "FilterChoiceView.h"
#import "KSYPublishViewController.h"
#import "TrimView.h"
#import "AERootView.h"
#import "KSYDecalView.h"
#import "KSYDecalBGView.h"

#import "UIView+XIB.h"
#import "TrimBgView.h"
#import "AudioTrimView.h"

#define kBeautyCFGViewHideFrame CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, kBeautyCFGViewHeight)
#define kBeautyCFGViewShowFrame CGRectMake(0, kScreenSizeHeight - kBeautyCFGViewHeight, kScreenSizeWidth, kBeautyCFGViewHeight)

#define kPlayRateArray @[@"0.5", @"1.0", @"1.5", @"2.0"]

@interface VideoEditorViewController ()
<
FilterChoiceViewDelegate,
KSYMEPreviewDelegate,
KSYMEComposeDelegate,
TrimViewDelegate,
TrimBgProtocol
>
{
    NSURL *_videoPath;
//    BOOL _isPlaying, isSeekDone, isThumbnailListAdd, _isAudioSeekDone;
    
    CGFloat width, height, thumbnailWidth, thumbnailHeight;
    CMTimeRange range;
    CMTimeRange audioTrimRange; //音频裁剪范围

    MediaMetaInfo *videoMeta;
}
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isSeekDone;
@property (nonatomic, assign) BOOL isThumbnailListAdd;
@property (nonatomic, assign) BOOL isAudioSeekDone;
@property (nonatomic, strong)MediaMetaInfo *audioMeta; //音频元数据
    
#pragma mark - UI
    
@property (nonatomic, strong)UIButton *backBtn;
//下一步
@property (nonatomic, strong)UIButton *nextBtn;

//背景音&变声
@property (nonatomic, strong)UIButton *aeBtn;
//倍速播放
@property (nonatomic, strong)UIButton *rateBtn;
//裁剪
@property (nonatomic, strong)UIButton *trimButton;

@property (nonatomic, strong)UIButton *fiterButton;

@property (nonatomic, strong)UIButton *waterMarkBtn;

@property(nonatomic, strong)UISwitch *waterMarkSwitch;

@property (nonatomic, strong)TrimBgView *trimBgView;

@property (nonatomic, strong)TrimView *trimView;

@property (nonatomic, strong)AudioTrimView *audioTrimView;

@property (nonatomic, strong) UISegmentedControl *rateSegCtl;

@property (nonatomic, strong)FilterChoiceView *filterChoiceView;

@property (nonatomic, assign)BOOL filterChoiceIsShowing;

@property (nonatomic, strong)KSYMediaEditor *editor;

@property (nonatomic, strong)GPUImageOutput <GPUImageInput>* filter;

@property (nonatomic, strong)UIImageView  *waterMarkView;

@property (nonatomic, strong)UIButton *playButton;

@property (nonatomic, strong)AERootView *aeRootView;

// 进度条
@property (nonatomic, weak) MBProgressHUD *progressHud;

@property (nonatomic) KSYDecalView *curDecalView;
// 所有 decal添加到该view上
@property (nonatomic) KSYDecalBGView *decalBGView;
    
// 贴纸gesture 相关
@property (nonatomic, assign) CGPoint loc_in;
@property (nonatomic, assign) CGPoint ori_center;
@property (nonatomic, assign) CGFloat curScale;

// 水印
@property (nonatomic, assign) CGRect logoRect;

/**
 记录当前选择的媒体类型用于裁剪判断
 */
@property (nonatomic, assign) TrimMeidaType currentMeidaType;

@end

@implementation VideoEditorViewController

-(instancetype)initWithUrl:(NSURL *)path
{
    if (self = [super init]){
        _videoPath = path;
        NSLog(@"path is: %@", _videoPath);
//        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"KSYShortVideoCache"];
//        NSString *videoPath = [NSString stringWithFormat:@"%@/%@", path, @"115462.025279.mp4"];
//        _videoPath = videoPath;
        
        _editor = [[KSYMediaEditor alloc] initWithURL:_videoPath];
        _editor.delegate = self;
        _editor.previewDelegate = self;
        
        videoMeta = [KSYMediaHelper videoMetaFrom:_videoPath];
        
        _isPlaying = false;
        _filterChoiceIsShowing = false;
        _isThumbnailListAdd = false;

        range = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
        _loc_in = CGPointZero;
        _curScale = 1.0f;
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBGView:)];
        [self.view addGestureRecognizer:tapGes];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.nextBtn];
    [self.view addSubview:self.trimButton];
    [self.view addSubview:self.fiterButton];
    [self.view addSubview:self.waterMarkBtn];
    [self.view addSubview:self.waterMarkSwitch];
    [self.view addSubview:self.playButton];
    
    [self.view addSubview:self.aeBtn];
    [self.view addSubview:self.rateBtn];
    
    //[self.view addSubview:self.aeRootView];
    
    // 美颜设置视图
    _filterChoiceView = [[FilterChoiceView alloc] init];
    _filterChoiceView.delegate = self;
    _filterChoiceView.frame = kBeautyCFGViewHideFrame;
    
    [self.view addSubview:self.filterChoiceView];
    [self.view addSubview:self.aeRootView];
    
    //编辑的背景视图
    self.trimBgView = [TrimBgView viewFromXIB];
    self.trimBgView.frame = CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, 155);
    self.trimBgView.delegate = self;
    [self.view addSubview:self.trimBgView];
    
    //音频裁剪视图
    self.audioTrimView = [AudioTrimView viewFromXIB];
    self.audioTrimView.frame = CGRectMake(0, 30, self.trimBgView.frame.size.width, 125);
    self.audioTrimView.audioTrim.delegate = self;
    [self.trimBgView addSubview:self.audioTrimView];
    
    //视频裁剪视图
    _trimView = [[TrimView alloc] initWithFrame:CGRectMake(0, 30, self.trimBgView.frame.size.width, 125)];
    _trimView.delegate = self;
//    [self.view addSubview:self.trimView];
    [self.trimBgView addSubview:_trimView];
    
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.mas_equalTo(self.view.mas_top).offset(42);
        make.left.mas_equalTo(self.view.mas_left).offset(16);
    }];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.mas_equalTo(self.view.mas_top).offset(42);
        make.right.mas_equalTo(self.view.mas_right).offset(-16);
    }];
    
    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.bottom.mas_equalTo(self.aeBtn.mas_top).offset(-10);
    }];
    
    [self.aeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-150);
    }];
    
    [self.trimButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.top.mas_equalTo(self.aeBtn.mas_bottom).offset(10);
    }];
    
    [self.fiterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.top.mas_equalTo(self.trimButton.mas_bottom).offset(10);
    }];
    
    [self.waterMarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.fiterButton.mas_left);
        make.top.mas_equalTo(self.fiterButton.mas_bottom).offset(10);
    }];
    
    [self.waterMarkSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.waterMarkBtn.mas_right).offset(8);
        make.bottom.mas_equalTo(self.waterMarkBtn.mas_bottom);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.playButton.hidden = YES;
    if(CMTIMERANGE_IS_EMPTY(range)){
        [_editor startPreview:self.view loop:YES];
    }else{
        [_editor startPreview:self.view range:range isLoop:YES];
    }
    self.aeRootView.bgmView.originVolumeSlider.value        = 1.0;
    self.aeRootView.bgmView.dubVolumeSlider.value           = 0.5;
    
    if (!_isThumbnailListAdd){
        if (videoMeta.degree == 90 || videoMeta.degree == -90){
            width  = videoMeta.naturalSize.height;
            height = videoMeta.naturalSize.width;
        }else{
            width  = videoMeta.naturalSize.width;
            height = videoMeta.naturalSize.height;
        }
        //这里为了简单，只作近似等比
        thumbnailHeight = 50;
        CGFloat tmpThumbnailWidth  = thumbnailHeight*width/height;
        
        CGFloat totalWidth = kScreenSizeWidth - 32;
        int thumbNum = (int)ceil(totalWidth/tmpThumbnailWidth);
        
        thumbnailWidth = totalWidth/thumbNum;
        self.trimView.minDuration = thumbnailWidth;
        NSMutableArray *times = [[NSMutableArray alloc] init];
        for (int j = 0; j < thumbNum; j++){
            NSValue *value = [NSValue valueWithCMTime:CMTimeMultiplyByFloat64(videoMeta.duration, j*1.0/thumbNum*1.0)];
            [times addObject:value];
            
        }
        __block int i = 0;
        
        NSLog(@"add thumbnail view");
        
        [KSYMediaHelper thumbnailForVideo:_videoPath atTimes:times attr:@{KSYThumbnailHeight:@(thumbnailHeight*2)} completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, KSYThumbnailGenResult result, NSError *error) {
            //
            if (result == KSYThumbnailGenSucceeded){
                CGImageRef img = CGImageRetain(image);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithCGImage:img]];
                    
                    tmpImageView.frame = CGRectMake(i*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                    
                    [self.trimView.thumbnailBgView addSubview:tmpImageView];
                    CGImageRelease(img);
                    i++;
                });
                
                //TODO  handle err situation
            }else{
                NSLog(@"Generate thumbnail errr:%@ %@", @(result), error.localizedDescription);
                i++;
            }
        }];
        _isThumbnailListAdd = true;
    }
    
    _isPlaying = true;
    _editor.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.trimView.startTime.text = [self stringWithTrimFormat:0];
    [self.trimView.startTime sizeToFit];
    long timeMS = CMTimeGetSeconds(videoMeta.duration)*1000;
    self.trimView.endTime.text = [self stringWithTrimFormat:timeMS];
    [self.trimView.endTime sizeToFit];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [_editor pausePreview];
    _isPlaying = false;
}

- (void)dealloc
{
    [_editor stopPreview];
    _isPlaying = false;
}

#define kAERootViewHideFrame CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, 212)
#define kAERootViewShowFrame CGRectMake(0, kScreenSizeHeight - 212, kScreenSizeWidth, 212)

- (AERootView *)aeRootView
{
    if (!_aeRootView){
        _aeRootView = [[AERootView alloc] init];
        _aeRootView.frame = kAERootViewHideFrame;
        _aeRootView.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        _aeRootView.BgmBlock = ^(AEModelTemplate *model) {
            //
            if (model.idx == 0){
                //remove bgm
//                weakSelf.aeRootView.bgmView.dubVolumeSlider.value    = 0.0;
                weakSelf.aeRootView.bgmView.dubVolumeSlider.enabled  = NO;
                [weakSelf.editor  addBgm:nil loop:YES];
            }else{
                [weakSelf.editor addBgm:model.path loop:YES];
//                weakSelf.aeRootView.bgmView.originVolumeSlider.value = 1;
//                weakSelf.aeRootView.bgmView.dubVolumeSlider.value    = 0.5;
                weakSelf.aeRootView.bgmView.dubVolumeSlider.enabled  = YES;
                [weakSelf.editor adjustRawVolume:weakSelf.aeRootView.bgmView.originVolumeSlider.value];
                [weakSelf.editor adjustBGMVolume:weakSelf.aeRootView.bgmView.dubVolumeSlider.value];
                //更新当前控制器持有的 音频元数据信息
                weakSelf.audioMeta = [KSYMediaHelper audioMetaFrom:[NSURL fileURLWithPath:model.path]];
                [weakSelf configAudioTrim:weakSelf.audioMeta];
                [weakSelf.audioTrimView showWaveByURL:[NSURL fileURLWithPath:model.path]];
            }
        };
        _aeRootView.BgmVolumeBlock = ^(float raw, float dub){
            //
            [weakSelf.editor adjustRawVolume:raw];
            [weakSelf.editor adjustBGMVolume:dub];
        };
        
        _aeRootView.AEBlock = ^(AEModelTemplate *model){
            if (model.type == 0){
                weakSelf.editor.reverbType = (int)model.idx;
            }
            if (model.type == 1){
                weakSelf.editor.effectType = model.idx;
            }
        };
        
        _aeRootView.DEBlock = ^(AEModelTemplate *model){
            if (model.type == KSYSelectorType_Decal) {
                [weakSelf genDecalViewWithImgName:[NSString stringWithFormat:@"decal_%lu",model.idx-1] type:DecalType_Sticker];
            }else if (model.type == KSYSelectorType_TextDecal) {
                [weakSelf genDecalViewWithImgName:[NSString stringWithFormat:@"decal_t_%lu", model.idx-1] type:DecalType_SubTitle];
            }
        };
    }
    return _aeRootView;
}
    

/**
 配置音频采集的配音 等调节信息给视图去绘制

 @param mediaMeta 多媒体model
 */
- (void)configAudioTrim:(MediaMetaInfo *)mediaMeta{
    if (mediaMeta == nil) {
        return;
    }
    self.audioTrimView.audioTrim.minDuration = self.trimView.minDuration;
    self.audioTrimView.audioTrim.startTime.text = [self stringWithTrimFormat:0];
    [self.audioTrimView.audioTrim.startTime sizeToFit];
    long timeMS = CMTimeGetSeconds(mediaMeta.duration)*1000;
    self.audioTrimView.audioTrim.endTime.text = [self stringWithTrimFormat:timeMS];
    [self.audioTrimView.audioTrim.endTime sizeToFit];
}

- (NSString *)stringWithTrimFormat:(long)duration
{
    //FIXME 忽略小时
    int min = (int)((duration%(1000 * 60 * 60))/(1000 * 60));
    int sec = (int)(((duration%(1000 * 60 * 60))%(1000 * 60))/1000);
    int ms  = (int)(duration%1000/100);
    
    return [NSString stringWithFormat:@"%02d:%02d.%d", min, sec, ms];
}

- (UIButton *)backBtn
{
    if (!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    
    }
    return _backBtn;
}

-(UIButton *)nextBtn{
    if (!_nextBtn){
    
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(onProcessVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)rateBtn{
    if (!_rateBtn){
        _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rateBtn setTitle:@"倍速" forState:UIControlStateNormal];
        [_rateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rateBtn addTarget:self action:@selector(onRate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateBtn;
}

- (UISegmentedControl *)rateSegCtl{
    if (!_rateSegCtl) {
        _rateSegCtl = [[UISegmentedControl alloc] initWithItems:kPlayRateArray];
        [_rateSegCtl setSelectedSegmentIndex:1];
        _rateSegCtl.hidden = YES;
        [_rateSegCtl addTarget:self action:@selector(onRateSegmentedControlDidChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _rateSegCtl;
}

- (UIButton *)aeBtn{
    if (!_aeBtn){
        _aeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_aeBtn setTitle:@"效果" forState:UIControlStateNormal];
        [_aeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_aeBtn addTarget:self action:@selector(onAE:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _aeBtn;
}

- (UIButton *)trimButton{
    if (!_trimButton){
        _trimButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trimButton setTitle:@"裁剪" forState:UIControlStateNormal];
        [_trimButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_trimButton addTarget:self action:@selector(onTrimVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _trimButton;
    
}

- (UIButton *)fiterButton{
    if (!_fiterButton){
        _fiterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fiterButton setTitle:@"美颜" forState:UIControlStateNormal];
        [_fiterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_fiterButton addTarget:self action:@selector(onFilter:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fiterButton;

}

- (UIButton *)waterMarkBtn{
    if (!_waterMarkBtn){
        _waterMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_waterMarkBtn setTitle:@"水印" forState:UIControlStateNormal];
        _waterMarkBtn.tag = 0; // 0 不显示， 1显示
        [_waterMarkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //[_waterMarkBtn addTarget:self action:@selector(onWaterMark:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _waterMarkBtn;
}

- (UISwitch *)waterMarkSwitch
{
    if (!_waterMarkSwitch){
    
        _waterMarkSwitch = [[UISwitch alloc] init];
        [_waterMarkSwitch addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _waterMarkSwitch;
}

- (UIButton *)playButton
{
    if (!_playButton){

        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"playBtn"]  forState:UIControlStateNormal];
        [_playButton setAdjustsImageWhenHighlighted:NO];
        [_playButton addTarget:self action:@selector(onPlay:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton sizeToFit];
        _playButton.center = self.view.center;
        _playButton.hidden = YES;
        
    }
    return _playButton;
}

- (UIImageView *)waterMarkView
{
    if (!_waterMarkView){
        UIImage *image = [UIImage imageNamed:@"watermark"];
        _waterMarkView = [[UIImageView alloc] initWithImage:image];
        _waterMarkView.frame = CGRectMake(30, 100, image.size.width,  image.size.height);
        //self.watermarkCfg.frame = _waterMarkView.frame;
        
    }
    return _waterMarkView;
}

- (void)onPlay:(id)sender
{
    CMTime start      = CMTimeMultiplyByFloat64(videoMeta.duration, self.trimView.startTimeRatio);
    CMTime dur        = CMTimeMultiplyByFloat64(videoMeta.duration, self.trimView.endTimeRatio - self.trimView.startTimeRatio);
    range = CMTimeRangeMake(start, dur);
    
    self.playButton.hidden = YES;
    
    [_editor startPreview:self.view range:range isLoop:YES];
}

- (void)onTouchBGView:(UITapGestureRecognizer *)touches{
    touches.cancelsTouchesInView = NO;
    CGPoint locationPoint = [touches locationInView:self.view];
    
    // aeRootView
    CGPoint aePoint = [self.aeRootView convertPoint:locationPoint fromView:self.view];
    if (![self.aeRootView pointInside:aePoint withEvent:nil]) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.aeRootView.frame = kAERootViewHideFrame;
        } completion:^(BOOL finished) {
            weakSelf.aeRootView.tag = kAEHidden;
        }];
    }
    if (_curDecalView) {
        _curDecalView.select = NO;
    }
    
    // rateSegCtl
    if (!_rateSegCtl.hidden) {
        CGPoint ratePoint = [_rateSegCtl convertPoint:locationPoint fromView:self.view];
        if ([_rateSegCtl pointInside:ratePoint withEvent:nil]){
            [_rateSegCtl hitTest:ratePoint withEvent:nil];
            return;
        }else{
            _rateSegCtl.hidden = YES;
        }
    }
    
    WeakSelf(VideoEditorViewController);
    if (_filterChoiceIsShowing){
        // 不截获filterChoiceView响应事件
        CGPoint filPoint = [self.filterChoiceView convertPoint:locationPoint fromView:self.view];
        if ([self.filterChoiceView pointInside:filPoint withEvent:nil]) {
            return;
        }
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.filterChoiceView.frame = kBeautyCFGViewHideFrame;
        } completion:^(BOOL finished) {
            weakSelf.filterChoiceIsShowing = NO;
        }];
    }
    
    CGPoint bgViewLoc = [self.trimBgView convertPoint:locationPoint fromView:self.view];
    if ([self.trimBgView pointInside:bgViewLoc withEvent:nil]) {
        [self.trimBgView hitTest:bgViewLoc withEvent:nil];
        return;
    }
    if (self.trimView.tag == 1){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            weakSelf.trimView.frame = CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, 125);
            weakSelf.trimBgView.frame = CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, 155);
        } completion:^(BOOL finished) {
            weakSelf.trimView.tag = 0;
        }];
    }
    [_curDecalView resignFirstResponder];
}

- (void)onBack:(id)sender
{
    [_editor stopPreview];
    //TODO 如果是正在处理视频，则该点无效
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onProcessVideo:(id)sender
{
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHud = progressHud;
    progressHud.mode = MBProgressHUDModeDeterminate;
    progressHud.label.text = @"正在合成...";
    progressHud.detailsLabel.text = @"0.00 %";
    progressHud.animationType = MBProgressHUDAnimationZoomIn;
    
    [_editor pausePreview];
    
    NSUInteger w = [self p_getOutputSize].width;
    NSUInteger h = [self p_getOutputSize].height;
    NSUInteger vb = _outputModel.videoKbps;
    NSUInteger ab = _outputModel.audioKbps;
    NSUInteger codec = _outputModel.videoCodec;
    // 输出格式
    NSUInteger outputFmt = _outputModel.videoFormat;
    
    _editor.outputSettings = @{kSYVideoOutputWidth:@(w),
                               kSYVideoOutputHeight:@(h),
                               KSYVideoOutputCodec:@(codec),
                               KSYVideoOutputVideoBitrate:@(vb),
                               KSYVideoOutputAudioBitrate:@(ab),
                               KSYVideoOutputFormat:@(outputFmt)
                               };
    
    NSLog(@"合成参数:%@",_editor.outputSettings);
    if (self.decalBGView.subviews.count > 0) {
        _editor.uiElementView = self.decalBGView;
    }
    _curDecalView.select = NO;
    _rateSegCtl.hidden = YES;
    [_editor startProcessVideo];
}

- (void)onTrimVideo:(id)sender
{
    WeakSelf(VideoEditorViewController);
    if (self.trimView.tag == 0){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            weakSelf.trimView.frame = CGRectMake(0, kScreenSizeHeight - 125, kScreenSizeWidth, 125);
            self.trimBgView.frame = CGRectMake(0, kScreenSizeHeight - 155, kScreenSizeWidth, 155);
        } completion:^(BOOL finished) {
            weakSelf.trimView.tag = 1;
        }];
    }

}

- (void)onRate:(UIButton *)sender{
    _rateSegCtl.hidden = !_rateSegCtl.hidden;
    
    self.rateSegCtl.frame = CGRectMake(CGRectGetMaxX(sender.frame) + 10, CGRectGetMinY(sender.frame), 200, CGRectGetHeight(sender.frame));
    [self.view addSubview:self.rateSegCtl];
}

- (void)onAE:(id)sender
{
    WeakSelf(VideoEditorViewController);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.aeRootView.tag = kAEShow;
        weakSelf.aeRootView.frame = kAERootViewShowFrame;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)onFilter:(id)sender
{
    _filterChoiceIsShowing = YES;
    WeakSelf(VideoEditorViewController);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.filterChoiceView.frame = kBeautyCFGViewShowFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)onWaterMark:(UIButton *)sender
{
    
    if (_filterChoiceIsShowing){
        WeakSelf(VideoEditorViewController);
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.filterChoiceView.frame = kBeautyCFGViewHideFrame;
        } completion:^(BOOL finished) {
            weakSelf.filterChoiceIsShowing = NO;
        }];
    }
    if(sender.tag == 0 ){
        [self.view addSubview:self.waterMarkView];
        sender.tag = 1;
    }else{
        [self.waterMarkView removeFromSuperview];
        sender.tag = 0;
    }
}

- (void)onRateSegmentedControlDidChanged:(UISegmentedControl *)segCtl{
    float rate = [(NSString *)kPlayRateArray[[segCtl selectedSegmentIndex]] floatValue];
    [_editor setPlayerRate:rate];
}

-(void)onValueChanged:(UISwitch *)sender
{
    if (sender.isOn){
        _logoRect = CGRectMake(0.05, 0.05, 0, 0.05);
        [_editor setWaterMarkImage:[UIImage imageNamed:@"watermark"] waterMarkRect:_logoRect andAplpha:1.0];
    }else{
        [_editor setWaterMarkImage:nil waterMarkRect:CGRectZero andAplpha:0];
    }
}

- (void)beautyFilterDidSelected:(KSYFilter)type
{
    GPUImageOutput<GPUImageInput> *filter = nil;
    switch (type) {
        case KSYFilterBeautifyPRO:
            filter = [[KSYBeautifyProFilter alloc] init];
            break;
        case KSYFilterBeautifyPlus:
            filter = [[KSYBeautifyFaceFilter alloc] init];
            break;
        default:
            break;
    }
    [_editor setFilter:filter];
    self.playButton.hidden = YES;
}

- (void)beautyParameter:(BeautyParameter)parameter valueDidChanged:(CGFloat)value{
    GPUImageOutput<GPUImageInput> *filter = [_editor filter];

    switch (parameter) {
        case BeautyParameterWhitening:
            [filter setValue:@(value) forKey:@"whitenRatio"];
            break;
        case BeautyParameterGrind:
            [filter setValue:@(value) forKey:@"grindRatio"];
            break;
        case BeautyParameterRuddy:
            [filter setValue:@(value) forKey:@"ruddyRatio"];
            break;
            
        default:
            break;
    }
}

#pragma mark - 合成状态回调
- (void)onComposeProgressChanged:(float)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressHud.progress = value;
        _progressHud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%",(value * 100)];
    });
}

- (void)onComposeFinish:(NSURL *)path thumbnail:(UIImage *)thumbnail
{
    WeakSelf(VideoEditorViewController);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //[_editor stopPreView];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        //
        KSYPublishViewController *publishVC;
        if ([[path absoluteString] hasSuffix:@".gif"]) {
            publishVC = [[KSYPublishViewController alloc] initWithGif:path];
        }else{
            publishVC = [[KSYPublishViewController alloc] initWithUrl:path coverImage:thumbnail];
        }
        
        [weakSelf.navigationController pushViewController:publishVC animated:YES];
        
    });
}

- (void)onErrorOccur:(KSYMediaEditor*)editor err:(KSYStatusCode)err  extraStr:(NSString*)extraStr
{
    NSLog(@"%@",extraStr);
    WeakSelf(VideoEditorViewController);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = extraStr;
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        
        [hud hideAnimated:YES afterDelay:2.f];
        
        [[[UIAlertView alloc] initWithTitle:@"composite fail" message:[NSString stringWithFormat:@"errCode:%ld\nmessage:%@",err, extraStr] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    });
}

#pragma mark
#pragma mark - Trim Delegate
- (void)trim2Range:(CGFloat)from to:(CGFloat)to
{
    //[_editor seekToTime:(CMTime)]
    
}

- (void)onTrim:(TrimType)type from:(CGFloat)from to:(CGFloat)to dur:(CGFloat)dur
{
    CMTime dst = kCMTimeZero; long timeMS = 0;
    __weak typeof(self) weakSelf = self;
    //视频滑动
    if (self.currentMeidaType == TrimMeidaTypeVideo) {
        if (type == TrimLeft){
            dst = CMTimeMultiplyByFloat64(videoMeta.duration, from);
            timeMS = CMTimeGetSeconds(dst)*1000;
            self.trimView.startTime.text = [self stringWithTrimFormat:timeMS];
            [self.trimView.startTime sizeToFit];
            
        }else if (type == TrimRight){
            dst = CMTimeMultiplyByFloat64(videoMeta.duration, to);
            timeMS = CMTimeGetSeconds(dst)*1000;
            self.trimView.endTime.text   = [self stringWithTrimFormat:timeMS];
            [self.trimView.endTime sizeToFit];
        }else{
            NSAssert(type == TrimBoth, @"invalid call");
            dst = CMTimeMultiplyByFloat64(videoMeta.duration, to);
            long timeMS = CMTimeGetSeconds(dst)*1000;
            self.trimView.endTime.text = [self stringWithTrimFormat:timeMS];
            [self.trimView.endTime sizeToFit];
            //if both use left value for seek
            dst = CMTimeMultiplyByFloat64(videoMeta.duration, from);
            //CMTimeShow(dst);
            timeMS = CMTimeGetSeconds(dst)*1000;
            self.trimView.startTime.text   = [self stringWithTrimFormat:timeMS];
            [self.trimView.startTime sizeToFit];
            
        }
        long trimedDur = CMTimeGetSeconds(videoMeta.duration)*dur*1000;
        self.trimView.tipView.text      = [NSString stringWithFormat:@"裁剪后的时长：%@",[self stringWithTrimFormat:trimedDur]];
        self.trimView.tipView.textColor = [UIColor colorWithHexString:@"#ffa700"];
        
        CMTime start      = CMTimeMultiplyByFloat64(videoMeta.duration, self.trimView.startTimeRatio);
        CMTime duration   = CMTimeMultiplyByFloat64(videoMeta.duration, self.trimView.endTimeRatio - self.trimView.startTimeRatio);
        
        range = CMTimeRangeMake(start, duration);
        //self.playButton.hidden = YES;
        [_editor pausePreview];
        _isSeekDone = false;
        
        [_editor seekToTime:dst range:range finish:^{
            weakSelf.isSeekDone = true;
            weakSelf.playButton.hidden = NO;
        }];
    } else if (self.currentMeidaType == TrimMeidaTypeAudio) {
        //seek音频位置
        if (type == TrimLeft){
            dst = CMTimeMultiplyByFloat64(self.audioMeta.duration, from);
            timeMS = CMTimeGetSeconds(dst)*1000;
            self.audioTrimView.audioTrim.startTime.text = [self stringWithTrimFormat:timeMS];
            [self.audioTrimView.audioTrim.startTime sizeToFit];
            
        }else if (type == TrimRight){
            dst = CMTimeMultiplyByFloat64(self.audioMeta.duration, to);
            timeMS = CMTimeGetSeconds(dst)*1000;
            self.audioTrimView.audioTrim.endTime.text   = [self stringWithTrimFormat:timeMS];
            [self.audioTrimView.audioTrim.endTime sizeToFit];
        }else{
            NSAssert(type == TrimBoth, @"invalid call");
            dst = CMTimeMultiplyByFloat64(self.audioMeta.duration, to);
            long timeMS = CMTimeGetSeconds(dst)*1000;
            self.audioTrimView.audioTrim.endTime.text = [self stringWithTrimFormat:timeMS];
            [self.audioTrimView.audioTrim.endTime sizeToFit];
            //if both use left value for seek
            dst = CMTimeMultiplyByFloat64(self.audioMeta.duration, from);
            //CMTimeShow(dst);
            timeMS = CMTimeGetSeconds(dst)*1000;
            self.audioTrimView.audioTrim.startTime.text   = [self stringWithTrimFormat:timeMS];
            [self.audioTrimView.audioTrim.startTime sizeToFit];
            
        }
        long trimedDur = CMTimeGetSeconds(self.audioMeta.duration)*dur*1000;
        self.audioTrimView.audioTrim.tipView.text      = [NSString stringWithFormat:@"裁剪后的时长：%@",[self stringWithTrimFormat:trimedDur]];
        self.audioTrimView.audioTrim.tipView.textColor = [UIColor colorWithHexString:@"#ffa700"];
        
        CMTime start      = CMTimeMultiplyByFloat64(self.audioMeta.duration, self.audioTrimView.audioTrim.startTimeRatio);
        CMTime duration   = CMTimeMultiplyByFloat64(self.audioMeta.duration, self.audioTrimView.audioTrim.endTimeRatio - self.audioTrimView.audioTrim.startTimeRatio);
        
        range = CMTimeRangeMake(start, duration);
        //self.playButton.hidden = YES;
//        [_editor pausePreview];
        _isAudioSeekDone = YES;
//        [_editor seekToTime:dst range:range finish:^{
//            ;
//            self.playButton.hidden = NO;
//        }];
        [self.editor seekBGMToTime:dst range:range finish:^{
            weakSelf.isAudioSeekDone = NO;
            
        }];
    }
    
}

-(CGSize)p_getOutputSize
{
    
    MediaMetaInfo *meta = [KSYMediaHelper videoMetaFrom:_videoPath];
    
    KSYRecordPreset preset = _outputModel.resolution;
    
    CGFloat baseWitdh = MIN(meta.naturalSize.width, meta.naturalSize.height);
    BOOL isBaseWidth = (baseWitdh == meta.naturalSize.width)?:FALSE;
    CGFloat baseheight = MAX(meta.naturalSize.width, meta.naturalSize.height);
    
    switch (preset) {
        case KSYRecordPresetDefault:
            return meta.naturalSize;
        case KSYRecordPreset540P:{
            CGFloat dstH = 540*baseheight/baseWitdh;
            return CGSizeMake(isBaseWidth?540:dstH, isBaseWidth?dstH:540);
        }
        case KSYRecordPreset720P:{
            CGFloat dstH = 720*baseheight/baseWitdh;
            return CGSizeMake(isBaseWidth?720:dstH, isBaseWidth?dstH:720);
        }
        case KSYRecordPreset1080P:{
            CGFloat dstH = 1080*baseheight/baseWitdh;
            return CGSizeMake(isBaseWidth?1080:dstH, isBaseWidth?dstH:1080);
        }
        default:
            break;
    }
}

- (void)onPlayStatusChanged:(KSYMEPreviewStatus)status{
    NSLog(@"player status :%ld", (long)status);
}

- (void)onPlayProgressChanged:(CMTimeRange)time percent:(float)percent{
//    NSLog(@"onPlayProgressChanged :%f", percent);
}

#pragma mark - Decal 相关
- (UIView *)decalBGView{
    if (!_decalBGView) {
        CGFloat x = 0;
        CGFloat y = 0;
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

- (void)genDecalViewWithImgName:(NSString *)imgName type:(DecalType)type{
    UIImage *image = [UIImage imageNamed:imgName];
    KSYDecalView *decalView = [[KSYDecalView alloc] initWithImage:image Type:type];
    if (type == DecalType_SubTitle) {
        // 气泡字幕需要计算文字的输入范围，每个气泡的展示区域不一样
        [decalView calcInputRectWithImgName:imgName];
    }
    decalView.select = YES;
    _curDecalView = decalView;
    [self.decalBGView addSubview:decalView];
    
    decalView.frame = CGRectMake((self.decalBGView.frame.size.width - image.size.width * 0.5) * 0.5,
                                 (self.decalBGView.frame.size.height - image.size.height * 0.5) * 0.5,
                                 image.size.width * 0.5, image.size.height * 0.5);
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
//            if (pinGes.scale < 1) {
//                if (view.oriScale * pinGes.scale < 0.5) {
//                    return;
//                }
//            }else if (pinGes.scale > 1){
//                if (view.center.x - view.frame.size.width * 0.5 < 0 ){
//                    return;
//                }else if (view.center.y - view.frame.size.height * 0.5 < 0) {
//                    return;
//                }else if (view.center.x + view.frame.size.width * 0.5 > CGRectGetMaxX(self.view.frame)) {
//                    return;
//                }else if (view.center.y + view.frame.size.height * 0.5 > CGRectGetMaxY(self.view.frame)) {
//                    return;
//                }
//            }
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
//        if (view.frame.size.width - _loc_in.x + loc.x >= self.view.frame.size.width){ // right margin
//            x = self.view.frame.size.width - view.frame.size.width * 0.5;
//        }else if (loc.x - _loc_in.x <= 0) { // left margin
//            x = view.frame.size.width * 0.5;
//        }else {
            x = _ori_center.x + (loc.x - _loc_in.x);
//        }
        
//        if (view.frame.size.height - _loc_in.y + loc.y >= self.view.frame.size.height) { // bottom margin
//            y = self.view.frame.size.height - view.frame.size.height * 0.5;
//        }else if (loc.y - _loc_in.y <= 0){ // top margin
//            y = view.frame.size.height * 0.5;
//        }else {
            y = _ori_center.y + (loc.y - _loc_in.y);
//        }
        
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

#pragma mark -
#pragma mark - TrimBgView Delegate
- (void)trimBgView:(TrimBgView *)trimBgView clickIndex:(TrimMeidaType)type{
    self.currentMeidaType = type;
    if (type == TrimMeidaTypeVideo) {
        self.audioTrimView.hidden = YES;
        self.trimView.hidden = NO;
    } else if (type == TrimMeidaTypeAudio){
        self.audioTrimView.hidden = NO;
        self.trimView.hidden = YES;
    }
}
@end
