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

#define kToken @"ONPNtpsWncTaDyRIYHE9T59tlhuV8yHnPky4vhwUBfn5o4iTrd4YwSWDeFOwtxWwa9YkuUmgJrzQ95Wzf9UQAdEsbnKVSirvXu7dU1d382U9A191IhTDlVQwuuZh7JUHiAUbommKt0dyjduJfeTq9FJeiZWAnhuO+nbd/cH57K8=h0hAw6ZXOP7qFI+ohJovWhWbZY1ILD5shZdnk7kFqLsP6HElz202sI5dOhwJWHNc2epj+DfZduJdmS0oK/brc+pQ/EGgxOxF/Y7zB0DuTvn0XeHEyUP1oEFYwJc3C3PVMLc2oCUDbA+t3G44lM0AmJoEUrk3xjixjH18DAZM4Ys="
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    // 短视频SDK鉴权
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

#pragma mark - SDK离线鉴权示例（具体流程请参考wiki）

- (void)requestOffLineAuth{
    [KSYMEAuth sendClipSDKAuthRequestWithToken:kToken complete:^(KSYStatusCode rc, NSError *error) {
        if(error == nil) {
            NSLog(@"离线鉴权成功");
        } else {
            NSLog(@"code:%zd,reason:%@",rc,error);
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
