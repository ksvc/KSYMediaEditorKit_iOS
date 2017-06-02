//
//  KSS3MultipartUpload.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3MultipartUpload.h"
#import "KS3AbortMultipartUploadRequest.h"
#import "KS3AbortMultipartUploadResponse.h"

@implementation KS3MultipartUpload

- (void)pause
{
    _isPaused = YES;
    
}

- (void)proceed
{
    _isPaused = NO;
    _isCanceled = NO;
}

- (void)cancel
{
    _isCanceled = YES;
}

@end
