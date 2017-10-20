//
//  KSYAudioEffectCommonLayout.m
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYAudioEffectCommonLayout.h"

@implementation KSYAudioEffectCommonLayout
- (instancetype)initSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.itemSize = size;
        self.minimumLineSpacing = 13;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
