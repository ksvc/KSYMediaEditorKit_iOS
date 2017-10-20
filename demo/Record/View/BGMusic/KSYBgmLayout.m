//
//  KSYBgmLayout.m
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYBgmLayout.h"

@implementation KSYBgmLayout
- (instancetype)initSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.itemSize = size;
        self.minimumLineSpacing = 19;
        self.minimumInteritemSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
