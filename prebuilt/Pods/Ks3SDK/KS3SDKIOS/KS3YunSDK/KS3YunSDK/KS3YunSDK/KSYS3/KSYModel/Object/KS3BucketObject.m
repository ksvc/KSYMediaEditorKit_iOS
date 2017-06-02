//
//  KS3BucketObj.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 15/4/15.
//  Copyright (c) 2015年 Blues. All rights reserved.
//

#import "KS3BucketObject.h"

@implementation KS3BucketObject

- (instancetype)initWithBucketName:(NSString *)strBucketName keyName:(NSString *)strKeyName {
    self = [super init];
    if (self) {
        _bucketName = strBucketName;
        _objKey = strKeyName;
    }
    return self;
}

@end
