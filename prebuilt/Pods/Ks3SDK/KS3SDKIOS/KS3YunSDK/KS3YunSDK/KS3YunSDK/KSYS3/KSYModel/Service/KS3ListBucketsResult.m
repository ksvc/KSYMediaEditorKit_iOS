//
//  KSS3ListBucketsResult.m
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListBucketsResult.h"

@implementation KS3ListBucketsResult

- (instancetype)init
{
    self = [super init];
    if (self) {
        _buckets = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
