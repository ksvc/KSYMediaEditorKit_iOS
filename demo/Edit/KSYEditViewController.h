//
//  KSYEditViewController.h
//  demo
//
//  Created by iVermisseDich on 2017/7/7.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutputModel.h"
@interface KSYEditViewController : UIViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       VideoURL:(NSURL *)url;

- (instancetype)initWithVideoURL:(NSURL *)url;

@property (nonatomic, strong) OutputModel *outputModel;

@end
