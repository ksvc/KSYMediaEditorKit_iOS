//
//  KS3PutObjectCopyRequest.h
//  KSYSDKDemo
//
//  Created by Blues on 12/25/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"
#import "KS3BucketObject.h"

@interface KS3PutObjectCopyRequest : KS3Request

@property (nonatomic, strong) NSString *strSourceBucket;
@property (nonatomic, strong) NSString *strSourceObject;
@property (nonatomic, strong) NSString *xkssMetaDataDirective;
@property (nonatomic, strong) NSString *xkssCopySourceIfMatch;
@property (nonatomic, strong) NSString *xkssCopySourceIfNoneMatch;
@property (nonatomic, strong) NSString *xkssCopySourceIfUnmodifiedSince;
@property (nonatomic, strong) NSString *xkssCopySourceIfModifiedSince;
@property (nonatomic, strong) NSString *xkssMeta;
@property (nonatomic, strong) NSString *xkssStorageClass;
@property (nonatomic, strong) NSString *xkssWebsiteRedirectLocation;

@property (nonatomic, strong) NSString *xkssServerSideEncryption;
@property (nonatomic, strong) NSString *xkssServerSideEncryptionCustomerKey;
@property (nonatomic, strong) NSString *xkssServerSideEncryptionCustomerAlgorithm;
@property (nonatomic, strong) NSString *xkssServerSideEncryptionCustomerKeyMD5;
@property (nonatomic, strong) NSString *xkssCopySourceServerSideEncryptionCustomerKey;
@property (nonatomic, strong) NSString *xkssCopySourceServerSideEncryptionCustomerAlgorithm;
@property (nonatomic, strong) NSString *xkssCopySourceServerSideEncryptionCustomerMD5;
@property (nonatomic, strong) NSString *xkssAcl;

@property (nonatomic, strong) NSString *key;

//- (instancetype)initWithName:(NSString *)bucketName;
- (instancetype)initWithName:(KS3BucketObject *)destBucketObj sourceBucketObj:(KS3BucketObject *)sourBucketObj;

@end
