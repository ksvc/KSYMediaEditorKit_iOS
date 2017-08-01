//
//  KSYEditTimesCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYEditSpeedLevelModel.h"
#import "KSYEditLevelDelegate.h"
@interface KSYEditTimesCell : UICollectionViewCell

@property (nonatomic, strong) KSYEditSpeedLevelModel *levelModel;
@property (nonatomic, weak) id <KSYEditLevelDelegate> delegate;
@end
