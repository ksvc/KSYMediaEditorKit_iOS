//
//  KSS3SetObjectACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3SetObjectACLRequest.h"
#import "KS3Constants.h"
#import "KS3AccessControlList.h"
#import "KS3Client.h"
@implementation KS3SetObjectACLRequest
- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKeyName acl:(KS3AccessControlList *)acl
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.key = [self URLEncodedString:strKeyName];
        self.acl = acl;
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = @"";
        
        //
        self.kSYHeader = [@"x-kss-acl:" stringByAppendingString:_acl.accessACL];
        self.kSYHeader = [NSString stringWithFormat:@"%@\n",self.kSYHeader];
        self.kSYResource = [NSString stringWithFormat:@"%@/%@?acl", self.kSYResource,_key];
        self.host = [NSString stringWithFormat:@"%@://%@.%@/%@?acl", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain], _key];
    }
    return self;
}
- (KS3URLRequest *)configureURLRequest
{
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodPut];
    [self.urlRequest setValue:_acl.accessACL forHTTPHeaderField:@"x-kss-acl"];
    return self.urlRequest;
}

@end
