//
//  KSYEditPanelCellLayout.m
//  demo
//
//  Created by sunyazhou on 2017/7/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditPanelCellLayout.h"

@implementation KSYEditPanelCellLayout
- (instancetype)initSize:(CGSize)size{
    self = [super init];
    if (self) {
        self.itemSize = size;
        self.minimumLineSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
