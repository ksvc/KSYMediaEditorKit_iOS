//
//  KSYRecordAELayout.m
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYRecordAELayout.h"

@implementation KSYRecordAELayout
- (instancetype)initSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.itemSize = size;
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
