//
//  PublishViewController.m
//  demo
//
//  Created by 张俊 on 08/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "NavigateView.h"
#import "UIImage+Add.h"
#import "KSYPlayerVC.h"
#import "PublishViewController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
// 获取KS3Token地址
#define kKS3AuthURI     @"http://ksvs-demo.ks-live.com:8720/api/upload/ks3/sig"

/// 短视频KS3存储bucket名称
#define kBucketName @"ksvsdemo"

typedef NS_ENUM(NSInteger, kPublishType) {
    kPublishType_MP4 = 0,
    kPublishType_GIF
};

@interface PublishViewController ()<KSYMediaEditorDelegate>

@property(nonatomic, strong)NavigateView *naviView;

@property(nonatomic, strong)FLAnimatedImageView *coverView;

@property(nonatomic, strong)MBProgressHUD *hudView;

// 0: mp4 1:gif
@property (nonatomic, assign) NSInteger type;
@end

@implementation PublishViewController

- (instancetype)initWithUrl:(NSURL *)path coverImage:(UIImage *)coverImage;
{
    if (self = [super init]){
        NSLog(@"path:%@", path);
        if ([coverImage isKindOfClass:[UIImage class]]){
            self.coverView.image = coverImage;
            self.coverView.bounds = CGRectMake(0, 0, kScreenSizeWidth*3/4, kScreenSizeWidth*3/4*coverImage.size.height/coverImage.size.width);
            self.coverView.center = self.view.center;
            [self.view addSubview:self.coverView];
        }
    }
    return self;
}

- (instancetype)initWithGif:(NSURL *)path{
    if (self = [super init]){
        NSLog(@"path:%@", path);
        _type = kPublishType_GIF;
//        UIImage *gif = [UIImage animatedImageWithAnimatedGIFURL:path];
        NSData *data1 = [NSData dataWithContentsOfURL:path];
        FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data1];
        
        self.coverView.animatedImage = animatedImage1;
        [self.coverView startAnimating];
        self.coverView.bounds = CGRectMake(0, 0, kScreenSizeWidth*3/4, kScreenSizeWidth*3/4*animatedImage1.size.height/animatedImage1.size.width);
        self.coverView.center = self.view.center;
        [self.view addSubview:self.coverView];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.naviView = [[NavigateView alloc] init];
    self.naviView.frame = CGRectMake(0, 0, kScreenSizeWidth, 64);
    self.naviView.backgroundColor = [UIColor  blackColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
    WeakSelf(PublishViewController);
    if (_type == kPublishType_GIF) {
        [self.naviView.nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    self.naviView.onEvent = ^(int idx, int ext){
        if (idx == 0){//取消
            [weakSelf onCancel];
        }
        if (idx == 1){//发布
            if (weakSelf.type == kPublishType_GIF) {
                [weakSelf onClose];
            }else{
                [weakSelf onPublish];
            }
        }
    
    };
    
    [self.view addSubview:self.naviView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancel
{
    //TODO
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onPublish
{
    //TODO
    [self getKS3AuthInfo];
    _hudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hudView.mode = MBProgressHUDModeAnnularDeterminate;
    _hudView.label.text = @"正在上传中";
}

- (void)onClose{
    UIViewController * presentingViewController = self.presentingViewController;
    do {
        if ([presentingViewController isKindOfClass:NSClassFromString(@"ViewController")]) {
            break;
        }
        presentingViewController = presentingViewController.presentingViewController;
        
    } while (presentingViewController.presentingViewController);
    NSLog(@"presentingViewController:%@", NSStringFromClass(presentingViewController.class));
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gettet/Setter
- (UIImageView *)coverView{
    if (!_coverView) {
        _coverView = [[FLAnimatedImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
        _coverView.layer.borderWidth = 8;
        _coverView.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return _coverView;
}

#pragma mark - ks3 auth

/**
 向APP Server请求ks3Token
 */
- (void)getKS3AuthInfo{
    
    KSYMediaEditor *editor = [KSYMediaEditor sharedInstance];
    editor.delegate = self;
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *objKey = [NSString stringWithFormat:@"%@/%ld.mp4",bundleId,time(NULL)];
    
    NSDictionary *uploadparams = @{KSYUploadBucketName : kBucketName,
                                   KSYUploadObjKey : objKey
                                   };
    __weak typeof(self) weakSelf = self;
    //设置上传参数 block
    [editor setUploadParams:uploadparams uploadParamblock:^(NSDictionary *params, KSYUploadWithTokenBlock block) {
        [weakSelf requestKS3TokenWith:params complete:^(NSString *ks3Token, NSString *strDate) {
            //客户获取到token及date信息后调用block设置这些信息，发起上传
            block(ks3Token, strDate);
        }];
    }];
}

- (void)requestKS3TokenWith:(NSDictionary *)dict complete:(void(^)(NSString *ks3Token, NSString *strDate))complete{
    NSString *strUrl = [[NSString stringWithFormat:@"%@?"
                         "headers=%@"
                         "&md5=%@"
                         "&res=%@"
                         "&type=%@"
                         "&verb=%@",
                         kKS3AuthURI,
                         [dict valueForKey:@"Headers"],
                         [dict valueForKey:@"ContentMd5"],
                         [dict valueForKey:@"Resource"],
                         [dict valueForKey:@"ContentType"],
                         [dict valueForKey:@"HttpMethod"]
                         ] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *encodedUrl = @"".mutableCopy;
    
    while (index < strUrl.length) {
        NSUInteger length = MIN(strUrl.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        range = [strUrl rangeOfComposedCharacterSequencesForRange:range];
        NSString *substring = [strUrl substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [encodedUrl appendString:encoded];
        
        index += range.length;
    }
    
    NSURL *url = [NSURL URLWithString:encodedUrl];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dict && [[dict valueForKey:@"RetCode"] integerValue] == 0) {
                NSString *ks3Token = dict[@"Authorization"];
                NSString *strDate = dict[@"Date"];
                
                if (complete){
                    complete(ks3Token, strDate);
                }
            }
        }else {
            if (complete){
                complete(nil, nil);
            }
        }
    }] resume];

}

#pragma mark - KS3 delegate


- (void)onUploadProgressChanged:(float)value
{
    _hudView.progress = value;
}

- (void)onKS3UploadFinish:(NSString *)path
{
    WeakSelf(PublishViewController);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hudView hideAnimated:YES];
        KSYPlayerVC *vc = [[KSYPlayerVC alloc] initWithURL:[NSURL URLWithString:path]];
        
        [weakSelf presentViewController:vc animated:YES completion:nil];
    });
}



- (void)onErrorOccur:(KSYMediaEditor*)editor err:(KSYStatusCode)err  extraStr:(NSString*)extraStr
{
    [_hudView hideAnimated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set the text mode to show only text.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = extraStr?:@"未知错误";
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    
    [hud hideAnimated:YES afterDelay:2.f];
    
}

-(void)dealloc
{

}

@end
