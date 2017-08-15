//
//  KSYBeautyFilterCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/7.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSYBeautyFilterCell;
@protocol KSYBeautyFilterCellDelegate <NSObject>

@optional
- (void)beautyFilterCell:(KSYBeautyFilterCell *)cell
              filterType:(KSYMEBeautyKindType)type;

@end


@interface KSYBeautyFilterCell : UICollectionViewCell
@property(nonatomic, weak) id <KSYBeautyFilterCellDelegate> delegate;

@end
