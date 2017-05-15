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

#define kBeautyCFGViewHideFrame CGRectMake(0, kScreenSizeHeight, kScreenSizeWidth, kEffectCFGViewHeight)
#define kBeautyCFGViewShowFrame CGRectMake(0, kScreenSizeHeight - kEffectCFGViewHeight, kScreenSizeWidth, kEffectCFGViewHeight)

// 美颜、参数、滤镜选择控件

@interface PreviewViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
BeautyConfigViewDelegate,
FilterViewDelegate,
StickerViewDelegate
>

@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) PreviewView  *previewView;

@property (nonatomic, strong) NSURL *filePath;

@property (nonatomic, assign) long startTime;

@property (nonatomic, strong) KSYCameraRecorder *recorder;
// 美颜算法/参数调节控件
@property (nonatomic, strong) EffectView * effectConfigView;
// 滤镜效果
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>* curFilter;;
@end


@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.view addSubview:self.previewView];

    [self.view addSubview:self.effectConfigView];
    
    [self p_setupPreViewEvent];
    [self p_initCamera];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _previewView.frame = self.view.frame;

    [_recorder startPreview:self.previewView.previewView];
    
    // 设置默认美颜
    _curFilter = [[KSYBeautifyProFilter alloc] init];
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

- (void)p_setupPreViewEvent
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    __weak typeof(self) weakSelf = self;
    self.previewView.onEvent = ^(PreViewSubViewIdx idx, int ext){
        
        switch (idx) {
            case PreViewSubViewIdx_Close:{
                [weakSelf.recorder stopPreview];
                [weakSelf.recorder stopRecord];
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
                    weakSelf.recorder.outputPath = strFilePath;
                    [weakSelf.recorder startRecord];
                    
                    weakSelf.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                              target:weakSelf
                                                            selector:@selector(onCountUp:)
                                                            userInfo:nil
                                                             repeats:YES];
                }
                if (ext ==1){//停止录制
                    //最短录制500ms
                    if(time(0) - weakSelf.startTime < 3){
                        //TODO remove this file
                        weakSelf.filePath = nil;
                        
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                        
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = @"最短录制3s";
                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                        [hud hideAnimated:YES afterDelay:2.f];
                    }
                    [weakSelf.recorder stopRecord];
                    weakSelf.previewView.deleteBtn.hidden = NO;
                    weakSelf.previewView.loadFileBtn.hidden = YES;
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
            case PreViewSubViewIdx_DeleteRecFile:{
                //删除该文件
                
                if ([fileMgr fileExistsAtPath:[weakSelf.filePath path]]){
                    [fileMgr removeItemAtPath:[weakSelf.filePath path] error:nil];
                    weakSelf.filePath = nil;
//                    weakSelf.previewView.deleteBtn.hidden = YES;
//                    weakSelf.previewView.loadFileBtn.hidden = NO;
                }
                weakSelf.previewView.deleteBtn.hidden = YES;
                weakSelf.previewView.loadFileBtn.hidden = NO;
            }break;
            case PreViewSubViewIdx_Save2Edit:
            {
                if (weakSelf.filePath){
                    //TODO 做文件大小校验为0或者不存在不能到下一个页面
                    NSLog(@"path:%@", weakSelf.filePath);
                    VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:weakSelf.filePath];
                    [weakSelf presentViewController:vc animated:YES completion:nil];
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
}

- (void)p_initCamera
{
    if (!_recorder){
        _recorder = [[KSYCameraRecorder alloc] init];
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
                
                VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:weakSelf.filePath];
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
        bf = (KSYBeautifyProFilter*)_curFilter;
    }else{
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        bf = (KSYBeautifyProFilter *)[fg filterAtIndex:0];
    }
    switch (parameter) {
        case BeautyParameterWhitening:
            bf.whitenRatio = value;
            break;
        case BeautyParameterGrind:
            bf.grindRatio = value;
            break;
        case BeautyParameterRuddy:
            bf.ruddyRatio = value;
            break;
            
        default:
            break;
    }
}

- (void)StickerChanged:(int)StickerIndex {
    //渲染贴纸
    if (StickerIndex == 0){
        KSYBeautifyProFilter *bf = [[KSYBeautifyProFilter alloc] init];
        bf.grindRatio  = 0.5f;
        bf.whitenRatio = 0.5f;
        bf.ruddyRatio  = 0.5f;
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

-(void)dealloc
{
    if (self.recorder){
        [self.recorder stopPreview];
        [self.recorder stopRecord];
        self.recorder = nil;
    }
    
    if (self.recordTimer && self.recordTimer.isValid){
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }

}

@end
