//
//  PreviewViewController.m
//  demo
//
//  Created by 张俊 on 05/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "PreviewViewController.h"
#import "PreviewView.h"
#import "VideoParamCache.h"

#import "VideoEditorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "EffectView.h"
#import "STFilterManager.h"

#import "AERootView.h"

#define kBeautyCFGViewHideFrame CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, kEffectCFGViewHeight)
#define kBeautyCFGViewShowFrame CGRectMake(0, kScreenSizeHeight - kEffectCFGViewHeight, kScreenSizeWidth, kEffectCFGViewHeight)

// 美颜、参数、滤镜选择控件

@interface PreviewViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
BeautyConfigViewDelegate,
FilterViewDelegate,
StickerViewDelegate,
KSYCameraRecorderDelegate,
KSYMediaEditorDelegate
>
{
    CGFloat _grindRatio; //不保存美颜filter，只保存值
    CGFloat _whitenRatio;
    CGFloat _ruddyRatio;
}
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) PreviewView  *previewView;

@property (nonatomic, strong) NSURL *filePath;

@property (nonatomic, assign) long startTime;

@property (nonatomic, strong) KSYCameraRecorder *recorder;
// 美颜算法/参数调节控件
@property (nonatomic, strong) EffectView * effectConfigView;

@property (nonatomic, strong) AERootView *aeRootView;
// 滤镜效果
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>* curFilter;

@end


@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.previewView];
    
    [self.view addSubview:self.effectConfigView];
    
    [self.view addSubview:self.aeRootView];
    
    [self p_setupPreViewEvent];
    [self p_initCamera];
    _previewView.videoMgrBtn.videoMgrState = kLoadfileState;
    [KSYMediaEditor sharedInstance].delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _previewView.frame = self.view.frame;
    [_previewView initRecrdProgress:self.recorder.minRecDuration/self.recorder.maxRecDuration];
    [_recorder startPreview:self.previewView.previewView];
    _recorder.delegate = self;
    [KSYMediaEditor sharedInstance].delegate = self;
    
    float origin, bgm;
    [_recorder getVolume:&origin bgm:&bgm];
    self.aeRootView.bgmView.originVolumeSlider.value = origin;
    self.aeRootView.bgmView.dubVolumeSlider.value    = bgm;
    // 设置默认美颜
    if (!_curFilter) {
        KSYBeautifyProFilter *bf = [[KSYBeautifyProFilter alloc] init];
        _curFilter   = bf;
        _grindRatio  = bf.grindRatio;
        _whitenRatio = bf.whitenRatio;
        _ruddyRatio  = bf.ruddyRatio;
    }
    [_recorder setupFilter:_curFilter];
    
    if (_recorder.cameraPosition == AVCaptureDevicePositionBack){
        // 显示闪光灯按钮
        if (_recorder.isTorchSupported) {
            self.previewView.flashBtn.hidden = NO;
        }
    }else{
        // 隐藏闪光灯按钮
        self.previewView.flashBtn.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_recorder stopPreview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PreviewView *)previewView
{
    if (!_previewView){
        _previewView =[[PreviewView alloc] init];
    }
    return _previewView;
}

- (EffectView *)effectConfigView{
    if (!_effectConfigView) {
        _effectConfigView = [[EffectView alloc] init];
        _effectConfigView.beautyConfigView.delegate = self;
        _effectConfigView.filterView.delegate = self;
        _effectConfigView.stickerView.delegate = self;
        _effectConfigView.frame = kBeautyCFGViewHideFrame;
        _effectConfigView.userInteractionEnabled = YES;
    }
    return _effectConfigView;
}

- (AERootView *)aeRootView
{
    if (!_aeRootView){
        _aeRootView = [[AERootView alloc] init];
        [(UIView *)[_aeRootView valueForKey:@"decalBtn"] setHidden:YES];
        _aeRootView.frame = kAERootViewHideFrame;
        _aeRootView.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        _aeRootView.BgmBlock = ^(AEModelTemplate *model) {
            //
            if (model.idx == 0){
                weakSelf.aeRootView.bgmView.dubVolumeSlider.enabled = NO;
                [weakSelf.recorder.bgmPlayer stopPlayBgm];
            }else{
                if (weakSelf.recorder.bgmPlayer.isRunning){
                    [weakSelf.recorder.bgmPlayer stopPlayBgm:^() {
                        [weakSelf.recorder.bgmPlayer startPlayBgm:model.path isLoop:YES];
                    }];
                }else{
                    [weakSelf.recorder.bgmPlayer startPlayBgm:model.path isLoop:YES];
                }
                weakSelf.aeRootView.bgmView.dubVolumeSlider.value   = 0.5;
                weakSelf.aeRootView.bgmView.dubVolumeSlider.enabled = YES;
                [weakSelf.recorder adjustVolume:weakSelf.aeRootView.bgmView.originVolumeSlider.value bgm:0.5];

            }
            
        };
        _aeRootView.BgmVolumeBlock = ^(float origin, float dub){
            //
            [weakSelf.recorder adjustVolume:origin bgm:dub];
        };
        
        _aeRootView.AEBlock = ^(AEModelTemplate *model){
            if (model){
                if (model.type == 0){
                    weakSelf.recorder.reverbType = (int)model.idx;
                }
                if (model.type == 1){
                    weakSelf.recorder.effectType = (KSYAudioEffectType)model.idx;
                }
                
            }
        };
    }
    return _aeRootView;
}

- (void)p_setupPreViewEvent
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    __weak typeof(self) weakSelf = self;
    self.previewView.onEvent = ^(PreViewSubViewIdx idx, int ext){
        
        switch (idx) {
            case PreViewSubViewIdx_Close:{
                
                [weakSelf.recorder stopPreview];
                [weakSelf.recorder stopRecord:^{

                }];
                weakSelf.recorder = nil;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];

                
            }break;
            case PreViewSubViewIdx_ToggleCamera:{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.recorder switchCamera];
                if (strongSelf.recorder.cameraPosition == AVCaptureDevicePositionBack){
                    // 显示闪光灯按钮
                    if (strongSelf.recorder.isTorchSupported) {
                        weakSelf.previewView.flashBtn.hidden = NO;
                    }
                }else{
                    // 隐藏闪光灯按钮
                    weakSelf.previewView.flashBtn.hidden = YES;
                }
            }break;
            case PreViewSubViewIdx_Flash:{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.recorder.cameraPosition == AVCaptureDevicePositionBack){
                    if ([strongSelf.recorder isTorchSupported]){
                        weakSelf.previewView.flashBtn.selected = !weakSelf.previewView.flashBtn.selected;
                        [strongSelf.recorder toggleTorch];
                    }
                }
            }break;
            case PreViewSubViewIdx_Record:{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (ext == 0){//开始录制
                    if (weakSelf.previewView.progress.lastRangeViewSelected){
                        weakSelf.previewView.progress.lastRangeViewSelected = NO;
                        weakSelf.previewView.videoMgrBtn.videoMgrState = kBackSelect;
                    }
                    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                    if (status != AVAuthorizationStatusAuthorized){
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = @"获取mic权限失败，无法录制";
                        [hud hideAnimated:YES afterDelay:1.5f];
                        return ;
                    }else{
                        status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                        if (status == AVAuthorizationStatusDenied){
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                            hud.mode = MBProgressHUDModeText;
                            hud.label.text = @"获取摄像头权限失败，无法录制";
                            [hud hideAnimated:YES afterDelay:1.5f];
                            return ;
                        }
                    }
                
                    NSString *fileName = [NSString stringWithFormat:@"%ld.mp4", time(nil)];
                    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"KSYShortVideoCache"];
                    if (![fileMgr fileExistsAtPath:path]){
                        [fileMgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    NSString *strFilePath = [NSString stringWithFormat:@"%@/%@", path,fileName];
                    weakSelf.filePath = [NSURL URLWithString:strFilePath];
                    weakSelf.startTime = time(0);
                    weakSelf.previewView.recordTimeLabel.text = [NSString stringWithHMS:0];
                    weakSelf.previewView.recordTimeLabel.hidden = NO;
                    //weakSelf.recorder.outputPath = strFilePath;
                    [weakSelf.recorder startRecord];
                    if (!weakSelf.recordTimer){
                        weakSelf.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                                target:weakSelf
                                                                              selector:@selector(onCountUp:)
                                                                              userInfo:nil
                                                                               repeats:YES];
                    }

                    
                    [weakSelf.previewView.progress addRangeView];
                    
                    //disable forbid touchs
                    weakSelf.previewView.closeBtn.enabled    = NO;
                    weakSelf.previewView.videoMgrBtn.enabled = NO;
                    
                    weakSelf.previewView.videoMgrBtn.videoMgrState = kBackSelect;
                    
                    
                }
                if (ext ==1){//停止录制
                    //最短录制500ms
//                    if(time(0) - weakSelf.startTime < 3){
//                    
//                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
//                        
//                        hud.mode = MBProgressHUDModeText;
//                        hud.label.text = @"最短录制3s";
//                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
//                        [hud hideAnimated:YES afterDelay:2.f];
//                    }
                    weakSelf.previewView.recordBtn.enabled = NO;
                    [weakSelf.recorder stopRecord:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(weakSelf.recorder.recordedLength < weakSelf.recorder.maxRecDuration){
                                weakSelf.previewView.recordBtn.enabled   = YES;
                            }
                            
                            weakSelf.previewView.closeBtn.enabled    = YES;
                            weakSelf.previewView.videoMgrBtn.enabled = YES;
                        });

                    }];
                    weakSelf.previewView.recordTimeLabel.hidden = YES;
                    
                    if (strongSelf.recordTimer && strongSelf.recordTimer.isValid){
                        [strongSelf.recordTimer invalidate];
                        strongSelf.recordTimer = nil;
                    }
                }
            }break;
            case PreViewSubViewIdx_LoadFile:
                [weakSelf p_importVideoFromAlbum];
                break;
            case PreViewSubViewIdx_BackRecFile:
                weakSelf.previewView.progress.lastRangeViewSelected = YES;
                weakSelf.previewView.videoMgrBtn.videoMgrState = kDeleteState;
                break;
            case PreViewSubViewIdx_DeleteRecFile:{
                //删除该文件
                [weakSelf.recorder deleteRecordedVideoAt:weakSelf.recorder.recordedVideos.count -1];
                [weakSelf.previewView.progress removeLastRangeView];
                if (weakSelf.recorder.recordedVideos.count > 0){
                    weakSelf.previewView.videoMgrBtn.videoMgrState = kBackSelect;
                }else{
                    weakSelf.previewView.videoMgrBtn.videoMgrState = kLoadfileState;
                }
                if(weakSelf.recorder.recordedLength < weakSelf.recorder.maxRecDuration){
                    weakSelf.previewView.recordBtn.enabled   = YES;
                }
                
            }break;
            case PreViewSubViewIdx_Save2Edit:
            {
                NSArray<KSYMediaUnit *> * recordedVideos = weakSelf.recorder.recordedVideos;
                if (recordedVideos.count <= 0) return ;
                else{
                    
                    
                    if (recordedVideos.count == 1){
                        VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:recordedVideos.firstObject.path];
                        [weakSelf presentViewController:vc animated:YES completion:nil];
                        
                    }else{
                        MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                        progressHud.mode = MBProgressHUDModeDeterminate;
                        progressHud.label.text = @"正在处理...";
                        progressHud.detailsLabel.text = @"0.00 %";
                        progressHud.animationType = MBProgressHUDAnimationZoomIn;
                        
                        NSMutableArray<__kindof NSString *> *urls = [[NSMutableArray alloc] init];
                        
                        [recordedVideos enumerateObjectsUsingBlock:^(KSYMediaUnit * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [urls addObject:obj.path];
                        }];
                        [[KSYMediaEditor sharedInstance] addVideos:urls];
                        [[KSYMediaEditor sharedInstance] startProcessVideo];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.aeRootView.bgmView.bgmView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                    });
                    if (weakSelf.recorder.bgmPlayer.isRunning){
                        [weakSelf.recorder.bgmPlayer stopPlayBgm];
                    }
                }


            }break;
            case PreViewSubViewIdx_beauty:
            {
                // slide out
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    weakSelf.effectConfigView.beautyConfigViewIsShowing = YES;
                    weakSelf.effectConfigView.frame = kBeautyCFGViewShowFrame;
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
            case PreViewSubViewIdx_Bgm:
            {
                
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    weakSelf.aeRootView.tag = kAEShow;
                    weakSelf.aeRootView.frame = kAERootViewShowFrame;
                } completion:^(BOOL finished) {
                    
                }];
                
            }break;
            default:
                break;
        }
    };
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.effectConfigView.beautyConfigViewIsShowing) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.effectConfigView.frame = kBeautyCFGViewHideFrame;
        } completion:^(BOOL finished) {
            weakSelf.effectConfigView.beautyConfigViewIsShowing = NO;
        }];
    }
    if (self.aeRootView.tag == kAEShow){
        CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
        CGPoint aePoint = [self.aeRootView convertPoint:locationPoint fromView:self.view];
        if (![self.aeRootView pointInside:aePoint withEvent:event]) {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.aeRootView.frame = kAERootViewHideFrame;
            } completion:^(BOOL finished) {
                weakSelf.aeRootView.tag = kAEHidden;
            }];
        }

    }
}

- (void)p_initCamera
{
    if (!_recorder){
        _recorder = [[KSYCameraRecorder alloc] init];
        _recorder.delegate = self;
    }
    
    if([VideoParamCache sharedInstance].captureParam.level == k360P){
        _recorder.previewDimension     = CGSizeMake(640, 360);
        _recorder.outputVideoDimension = CGSizeMake(640, 360);
    }
    if([VideoParamCache sharedInstance].captureParam.level == k480P){
        _recorder.previewDimension     = CGSizeMake(640, 480);
        _recorder.outputVideoDimension = CGSizeMake(640, 480);
    }

    if([VideoParamCache sharedInstance].captureParam.level == k540P){
        _recorder.previewDimension     = CGSizeMake(960, 540);
        _recorder.outputVideoDimension = CGSizeMake(960, 540);
    }

    if([VideoParamCache sharedInstance].captureParam.level == k720P){
        _recorder.previewDimension     = CGSizeMake(1280, 720);
        _recorder.outputVideoDimension = CGSizeMake(1280, 720);
    }
    _recorder.videoFrameRate = (int)[VideoParamCache sharedInstance].captureParam.frame;

    _recorder.videoBitrate = (int)[VideoParamCache sharedInstance].captureParam.vbps;
    
    _recorder.audioBitrate = (int)[VideoParamCache sharedInstance].captureParam.abps;
    
    // 默认开启 前置摄像头
    _recorder.cameraPosition = AVCaptureDevicePositionFront;
    _recorder.minRecDuration = 10;
    _recorder.maxRecDuration = 60;
}


-(void)p_importVideoFromAlbum
{

    BOOL isExist = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    if (!isExist) return ;
    
    UIImagePickerController *pickerCtl = [[UIImagePickerController alloc] init];
    pickerCtl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerCtl.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    pickerCtl.allowsEditing = NO;
    pickerCtl.delegate = self;

    [self presentViewController:pickerCtl animated:YES completion:nil];
}



#pragma mark -- UIImagePickerControllerDelegate 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSLog(@"url:%@", url);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) weakSelf = self;
        [self videoWithUrl:url withFileName:@"test.mp4" result:^(NSString *path){
            weakSelf.filePath = [NSURL fileURLWithPath:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:weakSelf.filePath.path];
                [self presentViewController:vc animated:YES completion:nil];
            });
        }];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName result:(void (^)(NSString *path)) block
{

    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"KSYShortVideoCache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@", path, fileName];

    if ([fileManager fileExistsAtPath:videoPath]) {
        [fileManager removeItemAtPath:videoPath error:nil];
    }
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                
                //NSString * videoPath = [KVideoUrlPath stringByAppendingPathComponent:fileName];
                const char *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 11024 * 1024;
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);
                    }
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    block(videoPath);
                }
                
            } failureBlock:^(NSError *error) {
                //
                NSLog(@"error:%@", error.description);

            }];
        }
    });
}

#pragma mark -

#pragma mark -
- (void)beautyParameter:(BeautyParameter)parameter valueDidChanged:(CGFloat)value {
    KSYBeautifyProFilter* bf;
    if ( ![_curFilter isMemberOfClass:[GPUImageFilterGroup class]]){
        if([_curFilter isMemberOfClass:[KSYBeautifyProFilter class]])
            bf = (KSYBeautifyProFilter*)_curFilter;
        else{
            //删除现存贴纸，改成美颜
            [_effectConfigView.stickerView selectStickerIdx:0];
        }
    }else{
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        bf = (KSYBeautifyProFilter *)[fg filterAtIndex:0];
    }
    switch (parameter) {
        case BeautyParameterWhitening:
            bf.whitenRatio = value;
            _whitenRatio = value;
            break;
        case BeautyParameterGrind:
            bf.grindRatio = value;
            _grindRatio = value;
            break;
        case BeautyParameterRuddy:
            bf.ruddyRatio = value;
            _ruddyRatio = value;
            break;
            
        default:
            break;
    }
}

- (void)StickerChanged:(int)StickerIndex {
    //渲染贴纸
    if (StickerIndex == 0){
        KSYBeautifyProFilter *bf = [[KSYBeautifyProFilter alloc] init];
        bf.grindRatio  = _grindRatio;
        bf.whitenRatio = _whitenRatio;
        bf.ruddyRatio  = _ruddyRatio;
        _curFilter = bf;
    }else{
        [[STFilterManager instance].ksySTFitler changeSticker:StickerIndex-1 onSuccess:^(SenseArMaterial * m){
            NSLog(@"completeCallback success");
            [[STFilterManager instance].ksySTFitler startShowingMaterial];
        } onFailure:nil onProgress:nil];
        
        _curFilter = [STFilterManager instance].ksySTFitler;
    }
    //由于贴纸自带美颜，刷掉其他的
    [_recorder setupFilter:_curFilter];
}

#pragma mark -
- (void)specialEffectFilterChanged:(int)effectIndex {
    if (effectIndex == 0){//原型
        KSYBeautifyProFilter *bf = [[KSYBeautifyProFilter alloc] init];
        bf.grindRatio  = _grindRatio;
        bf.whitenRatio = _whitenRatio;
        bf.ruddyRatio  = _ruddyRatio;
        _curFilter = bf;
    }else{ //特效图
        
        if (![_curFilter isMemberOfClass:[GPUImageFilterGroup class]]){
            KSYBeautifyProFilter    * bf = [[KSYBeautifyProFilter alloc] init];
            KSYBuildInSpecialEffects * sf = [[KSYBuildInSpecialEffects alloc] initWithIdx:effectIndex];
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
            [sf setSpecialEffectsIdx: effectIndex];
        }
    }
    
    [_recorder setupFilter:_curFilter];
}

- (void)onCountUp:(NSTimer *)sender
{
    self.previewView.recordTimeLabel.text = [NSString stringWithHMS:(int)(time(0) - _startTime)];
}

-(void)cameraRecorder:(KSYCameraRecorder *)sender didFinishRecord:(NSTimeInterval)length
{
    //self.previewView.progress addRangeView
}

-(void)cameraRecorder:(KSYCameraRecorder *)sender lastRecordLength:(NSTimeInterval)lastRecordLength totalLength:(NSTimeInterval)totalLength
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"record:%f", lastRecordLength);
        [self.previewView.progress updateLastRangeView:(lastRecordLength/_recorder.maxRecDuration)];
    });
    
}

-(void)cameraRecorder:(KSYCameraRecorder *)sender didReachMaxDurationLimit:(NSTimeInterval)maxRecDuration
{
    //
    _previewView.recordBtn.enabled   = NO;
    _previewView.closeBtn.enabled    = YES;
    _previewView.videoMgrBtn.enabled = YES;
 
    //TODO, use camera delegate to replace recordTimer, remove it
    if (self.recordTimer && self.recordTimer.isValid){
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

-(void)onComposeProgressChanged:(float)value
{
    WeakSelf(PreviewViewController);
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:weakSelf.view];
        hud.progress = value;
        hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%",(value * 100)];
    });
}

- (void)onComposeFinish:(NSString *)path thumbnail:(UIImage *)thumbnail
{
    WeakSelf(PreviewViewController);
    dispatch_async(dispatch_get_main_queue(), ^{

        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:path];
        [weakSelf presentViewController:vc animated:YES completion:nil];
    });

}

- (void)onErrorOccur:(KSYMediaEditor *)editor err:(KSYStatusCode)err extraStr:(NSString *)extraStr
{
    WeakSelf(PreviewViewController);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = extraStr?:@"合成失败";
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:2.f];
    });

}


-(void)dealloc
{
    if (self.recorder){
        [self.recorder stopPreview];
        [self.recorder stopRecord:nil];
        self.recorder = nil;
    }
    
    if (self.recordTimer && self.recordTimer.isValid){
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }

}

@end
