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

#define kToken @"uZxNPEq5tv1fO72CLdvFlw437p4iyIOEEF6LdbHqb3K9zZ/E5cu/TCbi0Z5XfZtRkzBu13//n7ILWHrC10Qck/6TNnFRKB77noltlkV84NuHOKIqcWSdrLjJ5oRm1gsJKixTm2axDq65RKjyfTU7+HBSPSdpVpa+eGSM+Q2tQCw=t82OCwFDd4LSvDIbK8RZT2Eo6x1DYFXc/BN09lCeUMerY/yk2JoCibVBGqzlfVMlR76ej3ixPgmtRrCPw2vToEs2UeOPUDcEluKnNh7h4v38ZsK0lDaAKFgA5QVybGz9qKLZKWZUxHFJn/yochtJa+ooovVIqnyu1l3sq58ZWME="

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
