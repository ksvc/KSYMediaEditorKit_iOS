//
//  ListBucketObjects.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListObjectsResult.h"

@implementation KS3ListObjectsResult
- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectSummaries = [NSMutableArray new];
        _commonPrefixes = [NSMutableArray new];
    }
    return self;
}
@end
