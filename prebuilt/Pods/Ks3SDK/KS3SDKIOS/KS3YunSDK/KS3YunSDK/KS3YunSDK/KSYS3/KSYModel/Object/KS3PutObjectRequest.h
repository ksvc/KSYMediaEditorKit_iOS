//
//  KSS3PutObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@class KS3AccessControlList;
@class KS3GrantAccessControlList;

@interface KS3PutObjectRequest : KS3Request

@property (nonatomic, strong) NSString *cacheControl;
@property (nonatomic, strong) NSString *contentDisposition;
@property (nonatomic, strong) NSString *contentEncoding;
@property (nonatomic, assign) BOOL generateMD5;
@property (nonatomic, strong) NSString *expect;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSInputStream *stream;
@property (nonatomic, assign, readonly) int64_t expires;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *redirectLocation;
@property (nonatomic, strong) NSString *callbackUrl;
@property (nonatomic, strong) NSString *callbackBody;
@property (nonatomic, strong) NSDictionary *callbackParams;
@property (strong, nonatomic) KS3AccessControlList *acl;
@property (nonatomic, strong) NSArray *arrGrantAcl;

- (instancetype)initWithName:(NSString *)bucketName withAcl:(KS3AccessControlList *)acl grantAcl:(NSArray *)arrGrantAcl;

@end
