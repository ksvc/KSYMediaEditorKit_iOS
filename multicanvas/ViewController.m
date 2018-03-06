//
//  ViewController.m
//  multicanvas
//
//  Created by sunyazhou on 2017/11/23.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "ViewController.h"

#import "KSYConfigViewController.h"

#define kToken @"K5jLqVUr3yvVsq7Zu3+xL0idh3tl2C5aL9Q76lRAI4VIQlaUclKOGFdh/bPohKtvn+OBtgsU4df/vNTKoEvi5Jx5exD5+KMiOqvWT1xKRddYEljhQIIC4gV9E+TXAZ5MfYxlFCbsWOcxADEZcxu9XqUq9uGkh00btfQ6O4M+mJQ=r7SnUwpGV6Xq/8e0RWLUbTmvaWnO3KhJH9Q0+XyzqtOFEW0mRxQA5PN46LAi7lVV05MgQRKPfSeLpOlCO+HWk8h6Hr3l5i5s9nV4MQJ70iDM+HslY1a0zXcvRMRxN6Cg6oTkxs23ybxPwEUYoizDkNcOgEkgM7FrMgpjoUs73hs="


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    [self requestOffLineAuth];
}

#pragma mark -
#pragma mark - private methods 私有方法
//SDK离线鉴权示例（具体流程请参考wiki）
- (void)requestOffLineAuth{
    [KSYMEAuth sendClipSDKAuthRequestWithToken:kToken complete:^(KSYStatusCode rc, NSError *error) {
        if(error == nil) {
            NSLog(@"离线鉴权成功");
        } else {
            NSLog(@"code:%zd,reason:%@",rc,error);
        }
    }];
}
#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
#pragma mark -
#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)startShortVideoAction:(UIButton *)sender {
    //进入短视频SDK for 多画布
    KSYConfigViewController *configVC = [[KSYConfigViewController alloc] initWithNibName:[KSYConfigViewController className] bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:configVC animated:YES];
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
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
