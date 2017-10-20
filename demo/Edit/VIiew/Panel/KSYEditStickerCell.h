//
//  KSYEditStickerCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYEditStickDelegate.h"
@interface KSYEditStickerCell : UICollectionViewCell

@property (nonatomic, weak) id <KSYEditStickDelegate> delegate;

@end

