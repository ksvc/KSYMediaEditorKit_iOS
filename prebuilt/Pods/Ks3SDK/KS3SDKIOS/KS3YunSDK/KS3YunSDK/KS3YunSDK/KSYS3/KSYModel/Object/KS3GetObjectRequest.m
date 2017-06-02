//
//  KSS3GetObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetObjectRequest.h"
#import "KS3Constants.h"
#import "KS3SDKUtil.h"
#import "KS3Client.h"
@implementation KS3GetObjectRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = [NSString stringWithFormat:@"%@://%@.%@", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain]];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    self.kSYResource = [self.kSYResource stringByAppendingFormat:@"/%@", _key];
    self.host = [self.host stringByAppendingFormat:@"/%@", _key];
    
    // **** request params
    NSMutableString *queryPramaString = [NSMutableString stringWithCapacity:512];
    NSMutableString *subResouceString = [NSMutableString stringWithCapacity:512];
    if (nil != _responseContentType) {
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentType, [KS3SDKUtil urlEncode:_responseContentType]];
        [subResouceString appendFormat:@"%@=%@", kKS3QueryParamResponseContentType, _responseContentType];
    }
    if (nil != _responseContentLanguage) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
            [subResouceString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentLanguage, [KS3SDKUtil urlEncode:_responseContentLanguage]];
        [subResouceString appendFormat:@"%@=%@", kKS3QueryParamResponseContentLanguage, _responseContentLanguage];
    }
    if (nil != _responseExpires) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
            [subResouceString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseExpires, [KS3SDKUtil urlEncode:_responseExpires]];
        [subResouceString appendFormat:@"%@=%@", kKS3QueryParamResponseExpires, _responseExpires];
    }
    if (nil != _responseCacheControl) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
            [subResouceString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseCacheControl, [KS3SDKUtil urlEncode:_responseCacheControl]];
        [subResouceString appendFormat:@"%@=%@", kKS3QueryParamResponseCacheControl, _responseCacheControl];
    }
    if (nil != _responseContentDisposition) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
            [subResouceString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentDisposition, [KS3SDKUtil urlEncode:_responseContentDisposition]];
        [subResouceString appendFormat:@"%@=%@", kKS3QueryParamResponseContentDisposition, _responseContentDisposition];
    }
    if (nil != _responseContentEncoding) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
            [subResouceString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentEncoding, [KS3SDKUtil urlEncode:_responseContentEncoding]];
        [subResouceString appendFormat:@"%@=%@", kKS3QueryParamResponseContentEncoding, _responseContentEncoding];
    }
    if (queryPramaString.length > 0) {
        self.host = [self.host stringByAppendingFormat:@"?%@", queryPramaString];
        self.kSYResource = [self.kSYResource stringByAppendingFormat:@"?%@", subResouceString];
    }
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
