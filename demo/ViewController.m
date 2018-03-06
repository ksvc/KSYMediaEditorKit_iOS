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

#define kToken @"K5jLqVUr3yvVsq7Zu3+xL0idh3tl2C5aL9Q76lRAI4VIQlaUclKOGFdh/bPohKtvn+OBtgsU4df/vNTKoEvi5Jx5exD5+KMiOqvWT1xKRddYEljhQIIC4gV9E+TXAZ5MfYxlFCbsWOcxADEZcxu9XqUq9uGkh00btfQ6O4M+mJQ=r7SnUwpGV6Xq/8e0RWLUbTmvaWnO3KhJH9Q0+XyzqtOFEW0mRxQA5PN46LAi7lVV05MgQRKPfSeLpOlCO+HWk8h6Hr3l5i5s9nV4MQJ70iDM+HslY1a0zXcvRMRxN6Cg6oTkxs23ybxPwEUYoizDkNcOgEkgM7FrMgpjoUs73hs="
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
