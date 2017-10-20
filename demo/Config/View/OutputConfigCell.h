//
//  OutputConfigCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/4.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutputModel.h"

@class OutputConfigCell;
@protocol OutputCfgCellDelegate <NSObject>

@optional
- (void)outputConfigCell:(OutputConfigCell *)cell outputModel:(OutputModel *)model;
@end

@interface OutputConfigCell : UITableViewCell
@property(nonatomic, strong)OutputModel *model;
@property(nonatomic, weak) id<OutputCfgCellDelegate>delegate;
@end
