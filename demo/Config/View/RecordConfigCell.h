//
//  RecordConfigCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/4.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordConfigModel.h"



@class RecordConfigCell;
@protocol RecordCfgCellDelegte <NSObject>

@optional
- (void)recordConfigCell:(RecordConfigCell *)cell recordModel:(RecordConfigModel *)model;
@end

@interface RecordConfigCell : UITableViewCell
@property(nonatomic, strong) RecordConfigModel *model;
@property(nonatomic, weak) id<RecordCfgCellDelegte>delegate;
@end
