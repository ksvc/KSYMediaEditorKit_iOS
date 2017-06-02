//
//  KSS3InitiateMultipartUploadResult.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3MultipartUpload.h"

@interface KS3InitiateMultipartUploadResult : NSObject
@property (strong, nonatomic) KS3MultipartUpload *multipartUpload;
@end
