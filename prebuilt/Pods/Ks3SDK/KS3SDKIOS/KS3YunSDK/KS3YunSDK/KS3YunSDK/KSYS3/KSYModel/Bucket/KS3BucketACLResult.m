//
//  KSS3BucketACLResult.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3BucketACLResult.h"

@implementation KS3BucketACLResult
- (instancetype)init
{
    self = [super init];
    if (self) {
        _accessControlList = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
