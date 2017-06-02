//
//  KSS3AbortMultipartUploadRequest.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3Request.h"
#import "KS3MultipartUpload.h"

@interface KS3AbortMultipartUploadRequest : KS3Request

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *uploadId;

- (instancetype)initWithName:(NSString *)bucketName;
- (id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload;

@end
