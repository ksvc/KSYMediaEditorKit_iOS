//
//  ReLogViewController.m
//  demo
//
//  Created by sunyazhou on 2017/7/21.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "ReLogViewController.h"
#import <WebKit/WebKit.h>

NSString *const kReleaseLogURL = @"https://ks3-cn-beijing.ksyun.com/ksplayer/svod_change_log/dist/iOS.html";
@interface ReLogViewController ()
@property (strong, nonatomic) WKWebView *logWebview;

@end

@implementation ReLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    self.logWebview = [[WKWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.logWebview];
    [self.logWebview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    
    NSURL *url = [NSURL URLWithString:kReleaseLogURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.logWebview loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
