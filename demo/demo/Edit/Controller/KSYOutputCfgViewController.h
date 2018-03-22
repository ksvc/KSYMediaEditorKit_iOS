//
//  KSYOutputCfgViewController.h
//  demo
//
//  Created by sunyazhou on 2017/7/25.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OutputModel.h"
#import "OutputConfigCell.h"


@class KSYOutputCfgViewController;
@protocol KSYEditOutputConfigView <NSObject>
@optional
- (void)outputConfigVC:(KSYOutputCfgViewController *)vc
             withModel:(OutputModel *)model
              isCancel:(BOOL)isCancelClick;
@end


@interface KSYOutputCfgViewController : UIViewController
@property (nonatomic, strong) OutputModel *outputModel;
@property(nonatomic, weak) id<KSYEditOutputConfigView>delegate;
@end
