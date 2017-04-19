//
//  ViewController.m
//  demo
//
//  Created by 张俊 on 30/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "ViewController.h"
#import "PreviewViewController.h"
#import "VideoParamCache.h"

#define kGetAkURI       @"http://10.64.7.106:8321/Auth"

FOUNDATION_EXTERN NSString *KSYMECompositionFinish;

@interface ViewController ()<UITextViewDelegate>{}

@property (nonatomic, strong)UIButton *startBtn;

//配置参数
@property (nonatomic, strong)UISegmentedControl *titleSegmentedControl;
//分辨率
@property (nonatomic, strong)UISegmentedControl *resolutionSegmentedControl;
//编码方式
@property (nonatomic, strong)UISegmentedControl *codecSegmentedControl;
//帧率
@property (nonatomic, strong)UITextField *frameRateTextView;
//视频码率
@property (nonatomic, strong)UITextField *vbpsTextView;
//音频码率
@property (nonatomic, strong)UITextField *abpsTextView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = YES;
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"录制",@"输出",nil];
    
    self.titleSegmentedControl = [[UISegmentedControl alloc]initWithItems:array];
    self.titleSegmentedControl.selectedSegmentIndex = 1;
    
    self.navigationItem.titleView = self.titleSegmentedControl;
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave:)];
    self.navigationItem.rightBarButtonItem=item;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self p_initSubViews];
    // 短视频SDK鉴权
    [self registerClipSDK];
}


- (UIButton *)startBtn
{
    if (!_startBtn){
        _startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_startBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(onJump:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _startBtn;
}

- (void)p_initSubViews
{
    [self.view addSubview:self.startBtn];
    
    //
    UILabel *title = [[UILabel alloc] init];
    title.text = @"视频输出参数设置";
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.view).offset(16);
        make.top.mas_equalTo(self.view).offset(42);
    }];
    
    UILabel *reslabel = [[UILabel alloc] init];
    reslabel.text = @"分辨率";
    [self.view addSubview:reslabel];
    [reslabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(title);
        make.top.mas_equalTo(title.mas_bottom).offset(16);
    }];
    
    if (!_resolutionSegmentedControl){
        NSArray *array = [[NSArray alloc] initWithObjects:@"360p",@"480p",@"540p",@"720p",nil];
        
        _resolutionSegmentedControl = [[UISegmentedControl alloc]initWithItems:array];
        _resolutionSegmentedControl.selectedSegmentIndex = 3;
        //[_resolutionSegmentedControl addTarget:self action:@selector(didSelectResolution:) forControlEvents:UIControlEventValueChanged];
        
    }
    [self.view addSubview:self.resolutionSegmentedControl];
    [_resolutionSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(reslabel.mas_right).offset(8);
        make.centerY.mas_equalTo(reslabel);
    }];
    
    UILabel *codecLabel = [[UILabel alloc] init];
    codecLabel.text = @"编码";
    [self.view addSubview:codecLabel];
    [codecLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(reslabel);
        make.top.mas_equalTo(reslabel.mas_bottom).offset(16);
    }];
    
    if (!_codecSegmentedControl){
        NSArray *array = [[NSArray alloc] initWithObjects:@"H.264",@"H.265",nil];
        _codecSegmentedControl = [[UISegmentedControl alloc]initWithItems:array];
        _codecSegmentedControl.selectedSegmentIndex = 0;
        //[_codecSegmentedControl addTarget:self action:@selector(didSelectCodec:) forControlEvents:UIControlEventValueChanged];
        
    }
    [self.view addSubview:self.codecSegmentedControl];
    [_codecSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(codecLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(codecLabel);
    }];
    
    //帧率
    UILabel *frameLabel = [[UILabel alloc] init];
    frameLabel.text = @"帧率";
    [self.view addSubview:frameLabel];
    [frameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(codecLabel);
        make.top.mas_equalTo(codecLabel.mas_bottom).offset(16);
    }];
    
    if (!_frameRateTextView){
        _frameRateTextView = [[UITextField alloc] init];
        _frameRateTextView.tag = 0;
        _frameRateTextView.keyboardType = UIKeyboardTypeNumberPad;
        _frameRateTextView.borderStyle = UITextBorderStyleRoundedRect;
        _frameRateTextView.placeholder = @"30";
        //_frameRateTextView.delegate = self;
    }
    [self.view addSubview:self.frameRateTextView];
    [_frameRateTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(frameLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(frameLabel);
    }];
    
    //视频码率
    UILabel *vbpsLabel = [[UILabel alloc] init];
    vbpsLabel.text = @"视频码率(kbps)";
    [self.view addSubview:vbpsLabel];
    [vbpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(codecLabel);
        make.top.mas_equalTo(frameLabel.mas_bottom).offset(16);
    }];
    
    if (!_vbpsTextView){
        _vbpsTextView = [[UITextField alloc] init];
        _vbpsTextView.tag = 1;
        _vbpsTextView.keyboardType = UIKeyboardTypeNumberPad;
        _vbpsTextView.borderStyle = UITextBorderStyleRoundedRect;
        _vbpsTextView.placeholder = @"4096";
        //_vbpsTextView.delegate = self;
    }
    [self.view addSubview:self.vbpsTextView];
    [_vbpsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(vbpsLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(vbpsLabel);
    }];
    
    //音频码率
    UILabel *abpsLabel = [[UILabel alloc] init];
    abpsLabel.text = @"音频码率(kbps)";
    [self.view addSubview:abpsLabel];
    [abpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(codecLabel);
        make.top.mas_equalTo(vbpsLabel.mas_bottom).offset(16);
    }];
    
    if (!_abpsTextView){
        _abpsTextView = [[UITextField alloc] init];
        _abpsTextView.keyboardType = UIKeyboardTypeNumberPad;
        _abpsTextView.borderStyle = UITextBorderStyleRoundedRect;
        _abpsTextView.tag = 2;
        _abpsTextView.placeholder = @"96";
        //_abpsTextView.delegate = self;
    }
    [self.view addSubview:self.abpsTextView];
    [_abpsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(abpsLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(abpsLabel);
    }];
    
    [_startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
}


- (void)didSelectResolution:(UISegmentedControl *)sender
{
    NSInteger Index = sender.selectedSegmentIndex;
    switch (Index) {
        default:  
        break;
    
    }
}

- (void)onSave:(id)sender
{
    //录制
    if (self.titleSegmentedControl.selectedSegmentIndex == 0){
        [VideoParamCache sharedInstance].captureParam.level = self.resolutionSegmentedControl.selectedSegmentIndex;
        
        [VideoParamCache sharedInstance].captureParam.codec = self.codecSegmentedControl.selectedSegmentIndex;
        if ([self.frameRateTextView.text integerValue] > 0){
            [VideoParamCache sharedInstance].captureParam.frame = [self.frameRateTextView.text integerValue];
        }
        if ([self.abpsTextView.text integerValue] > 0){
            [VideoParamCache sharedInstance].captureParam.abps = [self.abpsTextView.text integerValue];
        }
        if ([self.vbpsTextView.text integerValue] > 0){
            [VideoParamCache sharedInstance].captureParam.vbps = [self.vbpsTextView.text integerValue];
        }
    }
    //输出
    if (self.titleSegmentedControl.selectedSegmentIndex == 1){
        [VideoParamCache sharedInstance].exportParam.level = self.resolutionSegmentedControl.selectedSegmentIndex;
        
        [VideoParamCache sharedInstance].exportParam.codec = self.codecSegmentedControl.selectedSegmentIndex;
        if ([self.frameRateTextView.text integerValue] > 0){
            [VideoParamCache sharedInstance].exportParam.frame = [self.frameRateTextView.text integerValue];
        }
        if ([self.abpsTextView.text integerValue] > 0){
            [VideoParamCache sharedInstance].exportParam.abps = [self.abpsTextView.text integerValue];
        }
        if ([self.vbpsTextView.text integerValue] > 0){
            [VideoParamCache sharedInstance].exportParam.vbps = [self.vbpsTextView.text integerValue];
        }
    }
}

- (void)onJump:(id)sender
{
    PreviewViewController *vc = [[PreviewViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
    //PublishViewController *vc1 = [[PublishViewController alloc] init];
    //[self presentViewController:vc1 animated:YES completion:nil];
    //KSYPlayerVC *vc = [[KSYPlayerVC alloc] initWithURL:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]];
    //[self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - SDK鉴权相关
/**
 @abstract 从服务端获取AccessKey
 
 @param complete 获取成功将返回短视频SDK的AccessKey，用于SDK鉴权
 @discussion 示例从app server获取ak，用于SDK鉴权
 */
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


/**
 @abstract 使用ak进行短视频SDK鉴权
 */
- (void)registerClipSDK {
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
}

- (void)uploadWithPutObjReq:(KS3PutObjectRequest *)req{
    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:req];
    NSLog(@"%@",response);
}


@end
