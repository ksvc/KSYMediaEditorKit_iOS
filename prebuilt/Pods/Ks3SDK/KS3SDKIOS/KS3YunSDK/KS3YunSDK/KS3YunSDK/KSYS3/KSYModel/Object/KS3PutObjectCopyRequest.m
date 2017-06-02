//
//  KS3PutObjectCopyRequest.m
//  KSYSDKDemo
//
//  Created by Blues on 12/25/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3PutObjectCopyRequest.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@implementation KS3PutObjectCopyRequest

- (instancetype)initWithName:(KS3BucketObject *)destBucketObj sourceBucketObj:(KS3BucketObject *)sourBucketObj
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:destBucketObj.bucketName];
        self.key = [self URLEncodedString:destBucketObj.objKey];
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = [NSString stringWithFormat:@"%@://%@.%@", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain]];
        
        // ****
        self.strSourceBucket = [self URLEncodedString:sourBucketObj.bucketName];
        self.strSourceObject = [self URLEncodedString:sourBucketObj.objKey];
        NSString *strValue = [NSString stringWithFormat:@"/%@/%@", _strSourceBucket, _strSourceObject];
        self.kSYHeader = [@"x-kss-copy-source:" stringByAppendingString:strValue];
        self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
        self.host = [NSString stringWithFormat:@"%@/%@",self.host,_key];
        self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_key];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    NSString *strValue = [NSString stringWithFormat:@"/%@/%@", _strSourceBucket, _strSourceObject];
    
    [super configureURLRequest];
    [self.urlRequest setValue:strValue forHTTPHeaderField:@"x-kss-copy-source"];
    
    // **** header
    if (nil != _xkssMetaDataDirective) {
        [self.urlRequest setValue:_xkssMetaDataDirective forHTTPHeaderField:@"x-kss-metadata-directive"];
    }
    if (nil != _xkssCopySourceIfMatch) {
        [self.urlRequest setValue:_xkssCopySourceIfMatch forHTTPHeaderField:@"x-kss-copy-source-if-match"];
    }
    if (nil != _xkssCopySourceIfNoneMatch) {
        [self.urlRequest setValue:_xkssCopySourceIfNoneMatch forHTTPHeaderField:@"x-kss-copy-source-if-none-match"];
    }
    if (nil != _xkssCopySourceIfUnmodifiedSince) {
        [self.urlRequest setValue:_xkssCopySourceIfUnmodifiedSince forHTTPHeaderField:@"x-kss-copy-source-if-unmodified-since"];
    }
    if (nil != _xkssCopySourceIfModifiedSince) {
        [self.urlRequest setValue:_xkssCopySourceIfModifiedSince forHTTPHeaderField:@"x-kss-copy-source-if-modified-since"];
    }
    if (nil != _xkssMeta) {
        [self.urlRequest setValue:_xkssMeta forHTTPHeaderField:@"x-kss-meta-"];
    }
    if (nil != _xkssStorageClass) {
        [self.urlRequest setValue:_xkssStorageClass forHTTPHeaderField:@"x-kss-storage-class"];
    }
    if (nil != _xkssWebsiteRedirectLocation) {
        [self.urlRequest setValue:_xkssWebsiteRedirectLocation forHTTPHeaderField:@"x-kss-website-redirect-location"];
    }
    
    // **** encryption header
    if (nil != _xkssServerSideEncryption) {
        [self.urlRequest setValue:_xkssServerSideEncryption forHTTPHeaderField:@"x-kss-server-side-encryption"];
    }
    if (nil != _xkssServerSideEncryptionCustomerKey) {
        [self.urlRequest setValue:_xkssServerSideEncryptionCustomerKey forHTTPHeaderField:@"x-kss-server-side-encryption-customer-key"];
    }
    if (nil != _xkssServerSideEncryptionCustomerAlgorithm) {
        [self.urlRequest setValue:_xkssServerSideEncryptionCustomerAlgorithm forHTTPHeaderField:@"x-kss-server-side-encryption-customer-algorithm"];
    }
    if (nil != _xkssServerSideEncryptionCustomerKeyMD5) {
        [self.urlRequest setValue:_xkssServerSideEncryptionCustomerKeyMD5 forHTTPHeaderField:@"x-kss-server-side-encryption-customer-key-MD5"];
    }
    
    if (nil != _xkssCopySourceServerSideEncryptionCustomerKey) {
        [self.urlRequest setValue:_xkssCopySourceServerSideEncryptionCustomerKey forHTTPHeaderField:@"x-kss-copy-source-server-side-encryption-customer-key"];
    }
    if (nil != _xkssCopySourceServerSideEncryptionCustomerAlgorithm) {
        [self.urlRequest setValue:_xkssCopySourceServerSideEncryptionCustomerAlgorithm forHTTPHeaderField:@"x-kss-copy-source-server-side-encryption-customer-algorithm"];
    }
    if (nil != _xkssCopySourceServerSideEncryptionCustomerMD5) {
        [self.urlRequest setValue:_xkssCopySourceServerSideEncryptionCustomerMD5 forHTTPHeaderField:@"x-kss-copy-source-server-side-encryption-customer-key-MD5"];
    }
    
    // **** acl
    if (nil != _xkssAcl) {
        [self.urlRequest setValue:_xkssAcl forHTTPHeaderField:@"x-kss-acl"];
    }
    return self.urlRequest;
}

@end
