//
//  KSYInputCfgCell.h
//  demo
//
//  Created by sunyazhou on 2017/10/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYInputCfgModel.h"

@class KSYInputCfgCell;
@protocol KSYInputCfgCellDelegte <NSObject>

@optional
- (void)inputConfigCell:(KSYInputCfgCell *)cell
               cfgModel:(KSYInputCfgModel*)model;

@end

@interface KSYInputCfgCell : UITableViewCell
@property(nonatomic, strong) KSYInputCfgModel *model;
@property(nonatomic, weak) id<KSYInputCfgCellDelegte>delegate;
@end
