//
//  ViewController.m
//  demo
//
//  Created by iVermisseDich on 2017/7/3.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "ViewController.h"
#import "KSYCfgViewController.h"
#import "FilterManager.h"
#import "ReLogViewController.h"
#import "KSYNavigationController.h"
#define kGetAkURI       @"http://ksvs-demo.ks-live.com:8321/Auth"

#define kToken @"siE71VDDm2aDQVJXOgzGDux1DM+s0ISFh1ksTZReXYaXaK1PUSjG2lwQbrv6y+tldpJf7icL44p3nUQG7uoOyXhjtI7rtK+QdLIUvLj6JvULkNoer2PINzl4n+6aymVFRWuduuP/FATJsCMHTJxKlfAi656Zhb9cLg7RhlJ8a8I=knxbvEib/gbJwRO62EMmn2YuFPtdtwOkCUQAaR9VPX6AtlVFlr76dBnq7bU1fUtlc/mDciv7sdlsk27eZYdqhyXxL7mnK2jonyjKzdrPTi/R5Px4/dnZ0ME62kWtmf08dzCgv43sSUYfCnerXiuQIi9ILniDLpB15XQ62OJs8NE="

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    // 短视频SDK鉴权
//    [self registerClipSDK];
    [self requestOffLineAuth];
    
    // 商汤第三方鉴权
    [[FilterManager instance] setupWithTokeID:@"557dd71f0c01c67ab36d5318b2cdfb9f" Onsuccess:^{
        NSLog(@"获取列表完成");
    }];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    _versionLabel.text = [NSString stringWithFormat:@"SDK V%@版本", version];
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (IBAction)startShortVideoAction:(UIButton *)sender {
    KSYCfgViewController *ksyCfgVC = [[KSYCfgViewController alloc] initWithNibName:@"KSYCfgViewController" bundle:[NSBundle mainBundle]];
    KSYNavigationController *nvg = [[KSYNavigationController alloc] initWithRootViewController:ksyCfgVC];
    [[UIApplication sharedApplication].keyWindow setRootViewController:nvg];
}

#pragma mark - SDK在线鉴权示例（具体流程请参考wiki）

- (void)requestOffLineAuth{
    [KSYMEAuth sendClipSDKAuthRequestWithToken:kToken complete:^(KSYStatusCode rc, NSError *error) {
        if(error == nil) {
            NSLog(@"离线鉴权成功");
        } else {
            NSLog(@"code:%zd,reason:%@",rc,error);
        }
    }];
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


- (void)authWithAK:(NSString *)ak amzDate:(NSString *)amzDate{
    [KSYMEAuth sendClipSDKAuthRequestWithAccessKey:ak
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

- (IBAction)versionLogAction:(UIButton *)sender {
    ReLogViewController *logVC = [[ReLogViewController alloc] initWithNibName:@"ReLogViewController" bundle:nil];
    [self.navigationController pushViewController:logVC animated:YES];
}


#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
