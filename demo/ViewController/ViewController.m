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


//#define kGetAkURI       @"http://10.64.7.106:8321/Auth"
#define kGetAkURI       @"http://ksvs-demo.ks-live.com:8321/Auth"

FOUNDATION_EXTERN NSString *KSYMECompositionFinish;

@interface ViewController ()<UITextViewDelegate>{
    UILabel *frameLabel;
    UILabel *reslabel;
    UILabel *outputFmtLb;
}

@property (nonatomic, strong) UIButton *startBtn;

//配置参数
@property (nonatomic, strong) UISegmentedControl *titleSegmentedControl;
//分辨率
@property (nonatomic, strong) UISegmentedControl *resolutionSegmentedControl;

@property (nonatomic, strong) UILabel *codecLabel;
//编码方式
@property (nonatomic, strong) UISegmentedControl *codecSegmentedControl;
//帧率
@property (nonatomic, strong) UITextField *frameRateTextView;
//视频码率
@property (nonatomic, strong) UITextField *vbpsTextView;
//音频码率
@property (nonatomic, strong) UITextField *abpsTextView;
//输出格式
@property (nonatomic, strong) UISegmentedControl *outputFmtSegCtl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = YES;
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"录制",@"输出",nil];
    
    self.titleSegmentedControl = [[UISegmentedControl alloc]initWithItems:array];
    self.titleSegmentedControl.selectedSegmentIndex = 1;
    [self.titleSegmentedControl addTarget:self action:@selector(onParamTypeChange:) forControlEvents:UIControlEventValueChanged];
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
    
    reslabel = [[UILabel alloc] init];
    reslabel.text = @"分辨率";
    [self.view addSubview:reslabel];
    [reslabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.mas_equalTo(self.view).offset(16);
        make.top.mas_equalTo(self.view).offset(70);
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
    
    _codecLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    _codecLabel.text = @"编码";
    [self.view addSubview:_codecLabel];
    [_codecLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.left.mas_equalTo(reslabel.mas_right).offset(8);
        make.centerY.mas_equalTo(_codecLabel);
    }];
    
    // 输出类型
    outputFmtLb = [[UILabel alloc] init];
    outputFmtLb.text = @"格式";
    [self.view addSubview:outputFmtLb];
    [outputFmtLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(reslabel);
        make.top.mas_equalTo(_codecLabel.mas_bottom).offset(16);
    }];
    
    [self.view addSubview:self.outputFmtSegCtl];
    [_outputFmtSegCtl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_codecSegmentedControl.mas_left);
        make.centerY.mas_equalTo(outputFmtLb);
    }];
    
    //帧率
    frameLabel = [[UILabel alloc] init];
    frameLabel.text = @"帧率";
    frameLabel.hidden = YES;
    [self.view addSubview:frameLabel];
    [frameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(reslabel);
        make.top.mas_equalTo(_codecLabel.mas_bottom).offset(16);
    }];
    
    if (!_frameRateTextView){
        _frameRateTextView = [[UITextField alloc] init];
        _frameRateTextView.tag = 0;
        _frameRateTextView.keyboardType = UIKeyboardTypeNumberPad;
        _frameRateTextView.borderStyle = UITextBorderStyleRoundedRect;
        _frameRateTextView.placeholder = @"30";
        //_frameRateTextView.delegate = self;
    }
    _frameRateTextView.hidden = YES;
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
        make.left.mas_equalTo(reslabel);
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
        make.left.mas_equalTo(reslabel);
        make.top.mas_equalTo(vbpsLabel.mas_bottom).offset(16);
    }];
    
    if (!_abpsTextView){
        _abpsTextView = [[UITextField alloc] init];
        _abpsTextView.keyboardType = UIKeyboardTypeNumberPad;
        _abpsTextView.borderStyle = UITextBorderStyleRoundedRect;
        _abpsTextView.tag = 2;
        _abpsTextView.placeholder = @"64";
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

- (void)onParamTypeChange:(UISegmentedControl *)ctl
{
    
    switch (ctl.selectedSegmentIndex) {
        case 0:
        {
            self.codecLabel.hidden = YES;
            self.codecSegmentedControl.hidden = YES;
            self.frameRateTextView.hidden = NO;
            frameLabel.hidden = NO;
            outputFmtLb.hidden = YES;
            self.outputFmtSegCtl.hidden = YES;
            
            self.resolutionSegmentedControl.selectedSegmentIndex = [VideoParamCache sharedInstance].captureParam.level;
            self.codecSegmentedControl.selectedSegmentIndex = [VideoParamCache sharedInstance].captureParam.codec;
            self.frameRateTextView.text = [NSString stringWithFormat:@"%@", @([VideoParamCache sharedInstance].captureParam.frame)];
            self.abpsTextView.text = [NSString stringWithFormat:@"%@", @([VideoParamCache sharedInstance].captureParam.abps)];
            self.vbpsTextView.text = [NSString stringWithFormat:@"%@", @([VideoParamCache sharedInstance].captureParam.vbps)];
        }break;
        case 1:
        {
            self.codecLabel.hidden = NO;
            self.codecSegmentedControl.hidden = NO;
            self.frameRateTextView.hidden = YES;
            frameLabel.hidden = YES;
            outputFmtLb.hidden = NO;
            self.outputFmtSegCtl.hidden = NO;
//            [self.codecLabel setNeedsUpdateConstraints];
            
            self.resolutionSegmentedControl.selectedSegmentIndex = [VideoParamCache sharedInstance].exportParam.level;
            self.codecSegmentedControl.selectedSegmentIndex = [VideoParamCache sharedInstance].exportParam.codec;
            self.frameRateTextView.text = [NSString stringWithFormat:@"%@", @([VideoParamCache sharedInstance].exportParam.frame)];
            self.abpsTextView.text = [NSString stringWithFormat:@"%@", @([VideoParamCache sharedInstance].exportParam.abps)];
            self.vbpsTextView.text = [NSString stringWithFormat:@"%@", @([VideoParamCache sharedInstance].exportParam.vbps)];
        }break;
        case UISegmentedControlNoSegment:
            break;
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
        [VideoParamCache sharedInstance].exportParam.outputFmt = [self.outputFmtSegCtl selectedSegmentIndex];
    }
}

- (void)onJump:(id)sender
{
    PreviewViewController *vc = [[PreviewViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Getter / Setter

- (UISegmentedControl *)outputFmtSegCtl{
    if (!_outputFmtSegCtl) {
        _outputFmtSegCtl = [[UISegmentedControl alloc] initWithItems:@[@"MP4", @"GIF"]];
        [_outputFmtSegCtl setSelectedSegmentIndex:0];
    }
    return _outputFmtSegCtl;
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
    request.timeoutInterval = 5;
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

static int kAuthCount = 3;
/**
 @abstract 使用ak进行短视频SDK鉴权
 */
- (void)registerClipSDK {
    // 1. 从APP Server获取ak
    [self getAccessKey:^(NSString *ak, NSString *amzDate, NSError *error) {
        if (ak && !error) {
            // 2. 通过ak 对短视频sdk鉴权
            [self authWithAK:ak amzDate:amzDate];
        }else{
            NSLog(@"获取AK失败:%@",error);
        }
    }];
}

- (void)authWithAK:(NSString *)ak amzDate:(NSString *)amzDate{
    [KSYAuth sendClipSDKAuthRequestWithAccessKey:ak
                                         amzDate:amzDate
                                        complete:^(KSYStatusCode rc, NSError *err) {
                                            if (rc == KSYRC_OK) {
                                                NSLog(@"鉴权成功");
                                            }else{
                                                NSLog(@"鉴权失败:%@",err);
                                                __weak typeof(self) weakSelf = self;
                                                if (kAuthCount-- > 0) {
                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                        [weakSelf authWithAK:ak amzDate:amzDate];
                                                    });
                                                }
                                            }
                                        }];
}

- (void)uploadWithPutObjReq:(KS3PutObjectRequest *)req{
    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:req];
    NSLog(@"%@",response);
}


@end
