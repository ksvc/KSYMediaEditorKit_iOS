//
//  KSS3HeadObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3HeadObjectRequest.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@implementation KS3HeadObjectRequest

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKey
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.key = [self URLEncodedString:strKey];
        self.httpMethod = kHttpMethodHead;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = [NSString stringWithFormat:@"%@://%@.%@", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain]];
        
        //
        self.host = [NSString stringWithFormat:@"%@/%@",self.host,_key];
        self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_key];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    [super configureURLRequest];
    
    // **** http header
    if (nil != _range) {
        [self.urlRequest setValue:_range forHTTPHeaderField:kKSHttpHdrRange];
    }
    if (nil != _ifModifiedSince) {
        [self.urlRequest setValue:_ifModifiedSince forHTTPHeaderField:kKSHttpHdrIfModifiedSince];
    }
    if (nil != _ifUnmodifiedSince) {
        [self.urlRequest setValue:_ifUnmodifiedSince forHTTPHeaderField:kKSHttpHdrIfUnmodifiedSince];
    }
    if (nil != _ifMatch) {
        [self.urlRequest setValue:_ifMatch forHTTPHeaderField:kKSHttpHdrIfMatch];
    }
    if (nil != _ifNoneMatch) {
        [self.urlRequest setValue:_ifNoneMatch forHTTPHeaderField:kKSHttpHdrIfNoneMatch];
    }
    return self.urlRequest;
}

@end
