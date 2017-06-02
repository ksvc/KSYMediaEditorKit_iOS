//
//  KSS3CompleteMultipartUploadRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"
#import "KS3MultipartUpload.h"

@interface KS3CompleteMultipartUploadRequest : KS3Request

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, strong) NSData *dataParts;
@property (nonatomic, strong) NSString *callbackUrl;
@property (nonatomic, strong) NSString *callbackBody;
@property (nonatomic, strong) NSDictionary *callbackParams;

- (id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload;

- (void)addPartWithPartNumber:(int)partNumber withETag:(NSString *)etag;

- (NSData *)requestBody;

@end
