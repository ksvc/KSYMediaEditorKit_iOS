//
//  KSS3UploadPartRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3UploadPartRequest.h"
#import "KS3SDKUtil.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@interface KS3UploadPartRequest ()


@end

@implementation KS3UploadPartRequest

- (id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload partNumber:(int32_t)partNumber data:(NSData *)data generateMD5:(BOOL)generateMD5
{
    if(self = [super init])
    {
        self.bucket   = [self URLEncodedString:multipartUpload.bucket];
        self.key      = [self URLEncodedString:multipartUpload.key];
        self.uploadId = multipartUpload.uploadId;
        _data = data;
        _partNumber = partNumber;
        _generateMD5 = generateMD5;
        self.contentMd5 = nil;
        _generateMD5 = YES;
        _multipartUpload = multipartUpload;
        self.contentType = @"binary/octet-stream";
        self.kSYHeader = @"";
        self.httpMethod = kHttpMethodPut;
        
        KS3Client * ks3Client = [KS3Client initialize];
        NSString * customBucketDomain = [ks3Client getCustomBucketDomain];
        
        if ( customBucketDomain!= nil) {
            self.host = [NSString stringWithFormat:@"%@://%@/%@?partNumber=%d&uploadId=%@", [[KS3Client initialize] requestProtocol], customBucketDomain, _key, _partNumber,_multipartUpload.uploadId];
        }else{
               self.host = [NSString stringWithFormat:@"%@://%@.%@/%@?partNumber=%d&uploadId=%@", [[KS3Client initialize] requestProtocol], self.bucket, [ks3Client getBucketDomain],_key, _partNumber, _multipartUpload.uploadId];
            
        }
        
        if (nil == self.contentMd5 && YES == self.generateMD5 && self.data != nil) {
            self.contentMd5 = [KS3SDKUtil base64md5FromData:self.data];
        }
        self.kSYResource = [NSString stringWithFormat:@"/%@/%@?%@=%d&%@=%@", self.bucket,self.key, kKS3QueryParamPartNumber, self.partNumber, kKS3QueryParamUploadId, self.uploadId];
    }
    
    return self;
}

-(NSMutableURLRequest *)configureURLRequest
{
    
    
    [super configureURLRequest];
    if (self.contentLength < 1) {
        self.contentLength = [self.data length];
    }
    [self.urlRequest  setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[[self.urlRequest  HTTPBody] length]] forHTTPHeaderField:kKSHttpHdrContentLength];
    if (self.data != nil) {
        [self.urlRequest setHTTPBody:self.data];
    }
    if (nil != self.contentMd5) {
        [self.urlRequest setValue:self.contentMd5 forHTTPHeaderField:kKS3HttpHdrContentMD5];
    }
    if (nil != _expect) {
        [self.urlRequest setValue:_expect forHTTPHeaderField:@"Expect"];
    }
    [self.urlRequest setValue:self.contentType forHTTPHeaderField:kKSHttpHdrContentType];
    return self.urlRequest;
}

@end
