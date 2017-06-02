//
//  KSS3GetBucketLoggingRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetBucketLoggingRequest.h"
#import "KS3Constants.h"
#import "KS3SDKUtil.h"
#import "KS3Client.h"
@implementation KS3GetBucketLoggingRequest
- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@/?logging", self.bucket];
        self.host = [NSString stringWithFormat:@"%@://%@.%@/?logging", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain]];
    }
    return self;
}
- (KS3URLRequest *)configureURLRequest
{
    NSMutableString *queryString = [NSMutableString stringWithCapacity:512];
    
    if (nil != self.prefix) {
        [queryString appendFormat:@"%@=%@", kKS3QueryParamPrefix, [KS3SDKUtil urlEncode:self.prefix]];
    }
    if (nil != self.marker) {
        if ( [queryString length] > 0) {
            [queryString appendFormat:@"&"];
        }
        [queryString appendFormat:@"%@=%@", kKS3QueryParamMarker, [KS3SDKUtil urlEncode:self.marker]];
    }
    if (nil != self.delimiter) {
        if ( [queryString length] > 0) {
            [queryString appendFormat:@"&"];
        }
        [queryString appendFormat:@"%@=%@", kKS3QueryParamDelimiter, [KS3SDKUtil urlEncode:self.delimiter]];
    }
    if (self.maxKeys > 0) {
        if ( [queryString length] > 0) {
            [queryString appendFormat:@"&"];
        }
        [queryString appendFormat:@"%@=%d", kKS3QueryParamMaxKeys, self.maxKeys];
    }
    
    if ([queryString length] > 0) {
        self.host = [NSString stringWithFormat:@"%@?%@",self.host,queryString];
    }

    
    [super configureURLRequest];
    return self.urlRequest;
}
@end
