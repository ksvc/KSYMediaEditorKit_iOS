//
//  KSYEditFilterEffectCell.h
//  demo
//
//  Created by sunyazhou on 2017/12/26.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYFilterEffectModel.h"
@class KSYEditFilterEffectCell;

@protocol KSYEditFilterEffectCellDelegate <NSObject>

@optional

/**
 手势触发的 model

 @param cell 当前 panel Cell
 @param filterModel 模型对象
 @param state 手势状态
 */
- (void)editFilterEffectCell:(KSYEditFilterEffectCell *)cell
               selectedModel:(KSYFilterEffectModel *)filterModel
                    andState:(UIGestureRecognizerState)state;

/**
 撤销按钮触发

 @param cell 当前 panel Cell
 @param filterModel 模型对象
 */
- (void)editFilterEffectCell:(KSYEditFilterEffectCell *)cell
                   UndoModel:(KSYFilterEffectModel *)filterModel
                 isLongPress:(BOOL)isLongPress;
@end

@interface KSYEditFilterEffectCell : UICollectionViewCell

@property (nonatomic, weak) id <KSYEditFilterEffectCellDelegate>delegate;

@end
