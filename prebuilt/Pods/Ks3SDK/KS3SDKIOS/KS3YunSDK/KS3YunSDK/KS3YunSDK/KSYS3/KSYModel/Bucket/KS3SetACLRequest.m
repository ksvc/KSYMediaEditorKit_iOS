//
//  KSS3SetACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3SetACLRequest.h"
#import "KS3AccessControlList.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@implementation KS3SetACLRequest

- (instancetype)initWithName:(NSString *)bucketName accessACL:(KS3AccessControlList *)accessACL
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@/?acl", self.bucket];
        self.host = [NSString stringWithFormat:@"%@://%@.%@/?acl", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain]];
        _acl = accessACL;
        if (accessACL) {
            self.kSYHeader = [@"x-kss-acl:" stringByAppendingString:_acl.accessACL];
        }
        self.kSYHeader = [NSString stringWithFormat:@"%@\n",self.kSYHeader];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    
    [super configureURLRequest];
    [self.urlRequest setValue:_acl.accessACL forHTTPHeaderField:@"x-kss-acl"];
    return self.urlRequest;
    
}
@end
