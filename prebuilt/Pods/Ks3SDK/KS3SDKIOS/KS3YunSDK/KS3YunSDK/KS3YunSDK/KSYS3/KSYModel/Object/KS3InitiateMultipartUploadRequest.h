//
//  KSS3InitiateMultipartUploadRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3AbstractPutRequest.h"

@class KS3AccessControlList;
@class KS3GrantAccessControlList;

@interface KS3InitiateMultipartUploadRequest : KS3AbstractPutRequest

- (id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket acl:(KS3AccessControlList *)acl grantAcl:(NSArray *)arrGrantAcl;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *cacheControl;
@property (nonatomic, strong) NSString *contentDisposition;
@property (nonatomic, strong) NSString *contentEncoding;
@property (nonatomic, strong) NSString *expires;
@property (nonatomic, strong) NSString *xkssMeta;
@property (nonatomic, strong) NSString *xkssStorageClass;
@property (nonatomic, strong) NSString *xkssWebSiteRedirectLocation;
@property (nonatomic, strong) NSString *xkssAcl;
@property (nonatomic, strong) KS3AccessControlList *acl;
@property (nonatomic, strong) NSArray *arrGrantAcl;

@end
