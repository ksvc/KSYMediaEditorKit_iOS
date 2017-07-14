//
//  KSYFilterCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSYFilterCell;
@protocol KSYFilterCellDelegate <NSObject>

@optional

/**
 滤镜点击回调

 @param cell 点击的 滤镜cell
 @param type 美颜类型
 @param index 滤镜索引
 */
- (void)filterCell:(KSYFilterCell *)cell
        filterType:(KSYMEFilterType)type
       filterIndex:(NSUInteger)index;

@end
@interface KSYFilterCell : UICollectionViewCell
@property(nonatomic, weak) id <KSYFilterCellDelegate>delegate;
@end
