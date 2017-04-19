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
#import <libksygpulive/KSYGPUStreamerKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface PreviewViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSTimer *recordTimer;
}

@property (nonatomic, strong)PreviewView  *previewView;

@property (nonatomic, strong)KSYGPUStreamerKit *streamerKit;

@property (nonatomic, strong)NSURL *filePath;

@property (nonatomic, assign)long startTime;
@end


@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    // Do any additional setup after loading the view.
    [self.view addSubview:self.previewView];

    [self p_setupPreViewEvent];
    [self p_initCamera];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _previewView.frame = self.view.frame;
    [_streamerKit startPreview:self.previewView.previewView];
    _streamerKit.preview.frame = _previewView.frame;
    
    if (_streamerKit.cameraPosition == AVCaptureDevicePositionBack){
        // 显示闪光灯按钮
        if (_streamerKit.isTorchSupported) {
            self.previewView.flashBtn.hidden = NO;
        }
    }else{
        // 隐藏闪光灯按钮
        self.previewView.flashBtn.hidden = YES;
    }

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

- (void)p_setupPreViewEvent
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    __weak typeof(self) weakSelf = self;
    self.previewView.onEvent = ^(PreViewSubViewIdx idx, int ext){
        
        switch (idx) {
            case PreViewSubViewIdx_Close:{
                [weakSelf.streamerKit stopPreview];
                [weakSelf.streamerKit.streamerBase stopStream];
                weakSelf.streamerKit = nil;
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                
            }break;
            case PreViewSubViewIdx_ToggleCamera:{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf->_streamerKit switchCamera];
                if (strongSelf->_streamerKit.cameraPosition == AVCaptureDevicePositionBack){
                    // 显示闪光灯按钮
                    if (strongSelf->_streamerKit.isTorchSupported) {
                        weakSelf.previewView.flashBtn.hidden = NO;
                    }
                }else{
                    // 隐藏闪光灯按钮
                    weakSelf.previewView.flashBtn.hidden = YES;
                }
            }break;
            case PreViewSubViewIdx_Flash:{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (_streamerKit.cameraPosition == AVCaptureDevicePositionBack){
                    if ([strongSelf->_streamerKit isTorchSupported]){
                        weakSelf.previewView.flashBtn.selected = !weakSelf.previewView.flashBtn.selected;
                        [strongSelf->_streamerKit toggleTorch];
                    }
                }
            }break;
            case PreViewSubViewIdx_Record:{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (ext == 0){//开始直播
                    
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
                    _startTime = time(0);
                    weakSelf.previewView.recordTimeLabel.text = [NSString stringWithHMS:0];
                    weakSelf.previewView.recordTimeLabel.hidden = NO;
                    [weakSelf.streamerKit.streamerBase startStream:weakSelf.filePath];
                    
                    recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                              target:weakSelf
                                                            selector:@selector(onCountUp:)
                                                            userInfo:nil
                                                             repeats:YES];
                }
                if (ext ==1){//停止直播
                    [weakSelf.streamerKit.streamerBase stopStream];
                    weakSelf.previewView.deleteBtn.hidden = NO;
                    weakSelf.previewView.loadFileBtn.hidden = YES;
                    weakSelf.previewView.recordTimeLabel.hidden = YES;
                    if (strongSelf->recordTimer && strongSelf->recordTimer.isValid){
                        [strongSelf->recordTimer invalidate];
                        strongSelf->recordTimer = nil;
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
            default:
                break;
        }
        
    };
}

- (void)p_initCamera
{
    if (!_streamerKit){
        _streamerKit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    }
    // 采集相关设置初始化
    _streamerKit.capPreset          = AVCaptureSessionPreset1280x720;
    _streamerKit.previewDimension   = CGSizeMake(1280, 720);
    _streamerKit.streamDimension = CGSizeMake(1280, 720);
    _streamerKit.videoOrientation   = UIInterfaceOrientationPortrait;
    _streamerKit.streamOrientation  = UIInterfaceOrientationPortrait;
    _streamerKit.previewOrientation = UIInterfaceOrientationPortrait;
    
    //_streamerKit.streamerProfile = KSYStreamerProfile_720p_3;
    
    if([VideoParamCache sharedInstance].captureParam.level == k360P){
        _streamerKit.previewDimension   = CGSizeMake(640, 360);
        _streamerKit.streamDimension = CGSizeMake(640, 360);
    }
    if([VideoParamCache sharedInstance].captureParam.level == k480P){
        _streamerKit.previewDimension   = CGSizeMake(640, 480);
        _streamerKit.streamDimension = CGSizeMake(640, 480);
    }

    if([VideoParamCache sharedInstance].captureParam.level == k540P){
        _streamerKit.previewDimension   = CGSizeMake(960, 540);
        _streamerKit.streamDimension = CGSizeMake(960, 540);
    }

    if([VideoParamCache sharedInstance].captureParam.level == k720P){
        _streamerKit.previewDimension   = CGSizeMake(1280, 720);
        _streamerKit.streamDimension = CGSizeMake(1280, 720);
    }
    _streamerKit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    _streamerKit.videoFPS = (int)[VideoParamCache sharedInstance].captureParam.frame;
    _streamerKit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _streamerKit.streamerBase.videoInitBitrate = (int)[VideoParamCache sharedInstance].captureParam.vbps;
    _streamerKit.streamerBase.videoMinBitrate  =    0;
    
    _streamerKit.streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
    _streamerKit.streamerBase.audiokBPS  = (int)[VideoParamCache sharedInstance].captureParam.abps;
    
    // 默认开启 前置摄像头
    _streamerKit.cameraPosition = AVCaptureDevicePositionFront;
    
    // 开启默认美颜：柔肤
    //_filter = [[KSYBeautifyProFilter alloc] init];
    //[_streamerKit setupFilter:_filter];
    
    // 开启预览
    [_streamerKit startPreview:self.previewView.previewView];
    
    
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
    WeakSelf(PreviewViewController);
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSLog(@"url:%@", url);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self videoWithUrl:url withFileName:@"test.mp4" result:^(NSString *path){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:[NSURL fileURLWithPath:path]];
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


- (void)onCountUp:(NSTimer *)sender
{
    self.previewView.recordTimeLabel.text = [NSString stringWithHMS:(int)(time(0) - _startTime)];
}

-(void)dealloc
{
    if (self.streamerKit){
        [self.streamerKit stopPreview];
        [self.streamerKit.streamerBase stopStream];
        self.streamerKit = nil;
    }
    
    if (self->recordTimer && self->recordTimer.isValid){
        [self->recordTimer invalidate];
        self->recordTimer = nil;
    }

}

@end
