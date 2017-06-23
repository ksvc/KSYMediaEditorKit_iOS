//
//  TestViewController.m
//  demo
//
//  Created by iVermisseDich on 2017/6/12.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "TestViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <KSYMediaEditorKit/KSYVideoClipKit.h>

#define kGetAkURI       @"http://ksvs-demo.ks-live.com:8321/Auth"
FOUNDATION_EXTERN NSString *KSYMECompositionFinish;

@interface TestViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

{
    NSURL *inputUrl;
    NSURL *outputUrl;
    KSYVideoClipKit *_kit;
    UITextView *tv;
    BOOL stop;
    int loopCount;
}
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(didClickImporBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"导入" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 140, 80, 30);
    btn.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:btn];
    tv = [[UITextView alloc] initWithFrame:CGRectMake(0, 180, self.view.frame.size.width, self.view.frame.size.height - 190)];
    tv.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    [self.view addSubview:tv];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [self.view addSubview:hud];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    
    outputUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%ld.mp4", time(NULL)]]];
    
    
    
    // 1. 从APP Server获取ak
    [self getAccessKey:^(NSString *ak, NSString *amzDate, NSError *error) {
        if (ak && !error) {
            // 2. 通过ak 对短视频sdk鉴权
            [KSYAuth sendClipSDKAuthRequestWithAccessKey:ak
                                                 amzDate:amzDate
                                                complete:^(KSYStatusCode rc, NSError *err) {
                                                    if (rc == KSYRC_OK) {
                                                        NSLog(@"鉴权成功");
                                                    }else{
                                                        NSLog(@"鉴权失败:%@",err);
                                                    }
                                                }];
        }else{
            NSLog(@"获取AK失败:%@",error);
        }
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotify:) name:KSYMECompositionFinish object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%@-%@",inputUrl, outputUrl);
    stop = !stop;
    if (stop) {
        tv.text = [NSString stringWithFormat:@"%@\n暂停",tv.text];
    }else{
        tv.text = [NSString stringWithFormat:@"%@\n开始",tv.text];
    }
}

- (void)startProcess{
    if (!_kit) {
        _kit = [[KSYVideoClipKit alloc] init];
        _kit.resolution = CGSizeMake(1280, 720);
        _kit.biterate = 3000;
        _kit.audiokBPS = 64;
        _kit.videoFPS = 20;
        _kit.vCodec = KSYVideoCodec_VT264;
        _kit.aCodec = KSYAudioCodec_AT_AAC;
    }
    _kit.inputUrl = inputUrl;
    _kit.outputUrl = outputUrl;
    
    [_kit startWriting];
    loopCount += 1;
    tv.text = [NSString stringWithFormat:@"%@开始转码第%d次\n", tv.text, loopCount];
    __weak typeof(self) bSelf = self;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:bSelf.view];
    [hud showAnimated:YES];
    _kit.progressBlock = ^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD HUDForView:bSelf.view];
            hud.progress = progress;
        });
        //        NSLog(@"%f",progress);
    };
}

- (void)getAccessKey:(void(^)(NSString *ak, NSString *amzDate, NSError *error))complete{
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?Pkg=%@", kGetAkURI, bundleId]]];
    request.HTTPMethod = @"GET";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *dict = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] valueForKey:@"Data"];
            if (dict) {
                NSString *ak = [dict valueForKey:@"Authorization"];
                NSString *amzDate = [dict valueForKey:@"x-amz-date"];
                if (complete) {
                    complete(ak, amzDate, error);
                }
            }else{
                if (complete) {
                    complete(nil, nil, error);
                }
            }
        }else {
            if (complete) {
                complete(nil, nil, error);
            }
        }
    }] resume];
}

- (void)handleNotify:(NSNotification *)notify{
    _kit = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!stop) {
            [self startProcess];
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
            [hud hideAnimated:YES];
        }
    });
}


- (void)didClickImporBtn:(id)sender{
    BOOL isExist = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    if (!isExist) return ;
    
    UIImagePickerController *pickerCtl = [[UIImagePickerController alloc] init];
    pickerCtl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSString *type = (NSString *)kUTTypeMovie;
    pickerCtl.mediaTypes = [[NSArray alloc] initWithObjects:type , nil];
    pickerCtl.allowsEditing = NO;
    pickerCtl.delegate = self;
    
    CFRelease((__bridge CFTypeRef)(type));
    [self presentViewController:pickerCtl animated:YES completion:nil];
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:nil];
    __weak typeof(self) bSelf = self;
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSLog(@"url:%@", url);
        inputUrl = url;
        [bSelf startProcess];
    }
    CFRelease((__bridge CFTypeRef)(mediaType));
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
