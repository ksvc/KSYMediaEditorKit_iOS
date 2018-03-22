//
//  KSYPreEditViewController.h
//  demo
//
//  Created by sunyazhou on 2017/10/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYInputCfgModel.h"

@interface KSYPreEditViewController : UIViewController
@property (nonatomic, strong) NSMutableArray   *originAssets;
@property (nonatomic, strong) NSArray          *urls;
@property (nonatomic, strong) KSYInputCfgModel *configModel;


@end
