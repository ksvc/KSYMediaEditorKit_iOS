//
//  KSS3HeadBucketRequest.h
//  KS3YunSDK
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//
#import "KS3Request.h"
@interface KS3HeadBucketRequest : KS3Request
- (instancetype)initWithName:(NSString *)bucketName;
@end
