//
//  KSYEditAnimateImageCell.h
//  demo
//
//  Created by sunyazhou on 2017/8/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYEditStickDelegate.h"

@interface KSYEditAnimateImageCell : UICollectionViewCell
@property (nonatomic, weak) id <KSYEditStickDelegate> delegate;
@end
