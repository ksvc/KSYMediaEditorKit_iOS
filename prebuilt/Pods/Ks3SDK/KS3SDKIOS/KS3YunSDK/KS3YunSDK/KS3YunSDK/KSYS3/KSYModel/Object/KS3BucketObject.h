//
//  KS3BucketObj.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 15/4/15.
//  Copyright (c) 2015年 Blues. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3BucketObject : NSObject
@property (strong, nonatomic) NSString *bucketName;
@property (strong ,nonatomic) NSString *objKey;

- (instancetype)initWithBucketName:(NSString *)strBucketName keyName:(NSString *)strKeyName;

@end
