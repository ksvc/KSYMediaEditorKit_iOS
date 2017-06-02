//
//  KSS3CompleteMultipartUploadResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Response.h"
#import "KS3CompleteMultipartUploadResult.h"

@interface KS3CompleteMultipartUploadResponse : KS3Response
@property (nonatomic, readonly) KS3CompleteMultipartUploadResult *completeMultipartUploadResult;
@end
