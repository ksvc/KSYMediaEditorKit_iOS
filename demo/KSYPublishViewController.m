//
//  KSYPublishViewController.m
//  demo
//
//  Created by iVermisseDich on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYPublishViewController.h"
#import "KSYPlayViewController.h"
#import <WebKit/WebKit.h>

// 获取KS3Token地址（仅用于demo，使用者请替换为自己的app server地址）
#define kKS3AuthURI     @"http://ksvs-demo.ks-live.com:8720/api/upload/ks3/sig"
// 短视频KS3存储bucket名称（仅用于demo，使用者请替换为自己账户下的bucket）
#define kBucketName     @"ksvsdemo"
// 获取上传后的文件播放地址（仅用于demo，使用者请替换为自己的app server地址）
#define kGetKS3PlayURL @"http://ksvs-demo.ks-live.com:8720/api/upload/ks3/signurl"

@interface KSYPublishViewController ()
<
KSYMediaEditorUploadDelegate
>
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
// ks3上传工具类
@property (nonatomic, strong) KSYMEUploader *uploader;
// 用于展示封面
@property(nonatomic, strong) UIImageView *coverView;
// 用于展示gif
@property(nonatomic, strong) WKWebView *webview;

@property(nonatomic, copy) NSString *objKey;

@property(nonatomic, assign) BOOL isComposingGif;
@end

@implementation KSYPublishViewController

- (instancetype)initWithUrl:(NSURL *)path coverImage:(UIImage *)coverImage;
{
    if (self = [super init]){
        NSLog(@"path:%@", path);
        if ([coverImage isKindOfClass:[UIImage class]]){
            self.coverView.image = coverImage;
            
            [self.view addSubview:self.coverView];
            [self.view sendSubviewToBack:self.coverView];
            
            [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
                make.width.equalTo(self.view).multipliedBy(0.75);
                make.height.equalTo(self.view.mas_width).multipliedBy(0.75 * coverImage.size.height/coverImage.size.width);
            }];
            
            _uploader = [[KSYMEUploader alloc] initWithFilePath:path.path];
            _uploader.delegate = self;
        }
    }
    return self;
}

- (instancetype)initWithGif:(NSURL *)path{
    if (self = [super init]){
        NSLog(@"path:%@", path);
        _isComposingGif = YES;
        NSData *data = [NSData dataWithContentsOfURL:path];
        if (self.webview == nil) {
            self.webview = [[WKWebView alloc] initWithFrame:CGRectZero];
        }
        self.webview.backgroundColor = [UIColor blackColor];
        self.webview.scrollView.scrollEnabled = NO;
        self.webview.opaque = NO;
        
        [self.view addSubview:self.webview];
        [self.view sendSubviewToBack:self.webview];
        [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backBtn.mas_bottom).offset(20);
            make.left.equalTo(self.view).offset(40);
            make.right.bottom.equalTo(self.view).offset(-40);
        }];
        
        [self.webview loadData:data MIMEType:@"image/gif" characterEncodingName:@"UTF-8" baseURL:path];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubviews];
}

- (void)dealloc{
//    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
}

#pragma mark -
#pragma mark - Private Methods
- (void)configSubviews{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#18181D"];

    if (_isComposingGif) {
        [_uploadBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(20);
        make.width.height.mas_equalTo(30);
    }];
    
    [_uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.view).offset(20);
    }];
}

-(void)requestPlayUrlWithObjKey:(NSString *)objKey block:(void (^)(NSString *path)) block
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?objkey=%@",kGetKS3PlayURL,objKey]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dict && [[dict valueForKey:@"errno"] integerValue] == 0) {
                NSString *urlStr = [dict valueForKey:@"presigned_url"];
                if (![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"]) {
                    urlStr = [NSString stringWithFormat:@"https://%@",urlStr];
                }
                if (block){
                    NSLog(@"play url:%@",urlStr);
                    block(urlStr);
                }
            }else{
                NSLog(@"get play url fail : %@",dict);
                block(nil);
                // get play url fail
            }
        }else{
            NSLog(@"get play url fail : %@",error);
            block(nil);
            // get play url fail
        }
    }] resume];
}

#pragma mark -
#pragma mark - Getter & Setter
- (UIImageView *)coverView{
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
        _coverView.backgroundColor = [UIColor blackColor];
    }
    return _coverView;
}
/**
 向APP Server请求ks3Token
 */
- (void)getKS3AuthInfo{
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *objKey = [NSString stringWithFormat:@"%@/%ld.mp4",bundleId,time(NULL)];
    // 保存objKey用于获取上传后的播放地址
    _objKey = objKey;
    NSDictionary *uploadparams = @{KSYUploadBucketName : kBucketName,
                                   KSYUploadObjKey : objKey
                                   };
    __weak typeof(self) weakSelf = self;
    //设置上传参数 block
    [_uploader setUploadParams:uploadparams uploadParamblock:^(NSDictionary *params, KSYUploadWithTokenBlock block) {
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

#pragma mark -
#pragma mark - Actions & Gestures
- (IBAction)didClickBackBtn:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didClickUploadBtn:(UIButton *)sender {
    // gif
    if (_isComposingGif) {
        [self.navigationController popToViewController:self.navigationController.viewControllers.firstObject animated:YES];
        return;
    }
    
    // hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"文件上传中...";
    hud.detailsLabel.text = @"0.00 %";
    hud.animationType = MBProgressHUDAnimationZoomIn;
    
    // 请求上传地址
    [self getKS3AuthInfo];
}

- (IBAction)thumbSelectSliderValueDidChange:(UISlider *)sender {
    // 封面选择逻辑
}

#pragma mark -
#pragma mark - KSYMediaEditorUploadDelegate

- (void)onUploadProgressChanged:(float)value{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        hud.progress = value;
        hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f %%", value * 100];
    });
}

- (void)onUploadFinish{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES];
        // 1. 请求播放地址
        [self requestPlayUrlWithObjKey:_objKey block:^(NSString *path) {
            // 2. push 出播放页面
            KSYPlayViewController *vc = [[KSYPlayViewController alloc] initWithURL:[NSURL URLWithString:path]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:vc animated:YES];
            });
        }];
    });
}

- (void)onUploadError:(KSYStatusCode)err extraStr:(NSString *)extraStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Set the text mode to show only text.
        hud.mode = MBProgressHUDModeText;
        hud.label.text = extraStr?:@"未知错误";
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        
        [hud hideAnimated:YES afterDelay:2.f];
    });
}
@end
