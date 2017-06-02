//
//  KSS3ListPartsResult.m
//  KS3SDK
//
//  Created by JackWong on 12/16/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListPartsResult.h"

@implementation KS3ListPartsResult

- (instancetype)init
{
    self = [super init];
    if (self) {
        _parts = [NSMutableArray new];
    }
    return self;
}
@end
