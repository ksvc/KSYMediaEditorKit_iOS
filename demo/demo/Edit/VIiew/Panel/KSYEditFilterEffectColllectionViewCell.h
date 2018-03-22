//
//  KSYEditFilterEffectColllectionViewCell.h
//  demo
//
//  Created by sunyazhou on 2017/12/26.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYFilterEffectModel.h"
static NSString *kFilterEffectCellEndNotification = @"FilterEffectCellEndNotification";


@interface KSYEditFilterEffectColllectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *effectImageView;

@property (nonatomic, strong) KSYFilterEffectModel *model;


/**
 缩放 cell 表示被点击

 @param ratio 当前的开始缩放比例
 @param state 当前手势状态
 */
- (void)zoomCellWithRatio:(CGFloat)startRatio andState:(UIGestureRecognizerState)state;
@end
