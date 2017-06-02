//
//  KSS3SetBucketLoggingRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3SetBucketLoggingRequest : KS3Request

- (instancetype)initWithName:(NSString *)bucketName;

@end
