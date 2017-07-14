//
//  KSYFilterCollectionViewLayout.m
//  demo
//
//  Created by sunyazhou on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYFilterCollectionViewLayout.h"

@implementation KSYFilterCollectionViewLayout

- (instancetype)initSize:(CGSize)size{
    self = [super init];
    if (self) {
        self.itemSize = size;
        self.minimumLineSpacing = 4;
//        self.minimumInteritemSpacing = 1;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
