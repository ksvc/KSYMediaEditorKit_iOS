//
//  KSS3InitiateMultipartUploadResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Response.h"
#import "KS3MultipartUpload.h"

@interface KS3InitiateMultipartUploadResponse : KS3Response
@property (nonatomic, strong) KS3MultipartUpload *multipartUpload;
@end
