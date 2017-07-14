//
//  KSYEditWatermarkCellDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSYEditWatermarkCell;
@protocol KSYEditWatermarkCellDelegate <NSObject>

@optional

/**
 水印按钮点击
 
 @param cell 当前水印的cell
 @param isShowWatermark 是否开启或关闭水印
 */
- (void)editWatermarkCell:(KSYEditWatermarkCell *)cell
            showWatermark:(BOOL)isShowWatermark;

@end
