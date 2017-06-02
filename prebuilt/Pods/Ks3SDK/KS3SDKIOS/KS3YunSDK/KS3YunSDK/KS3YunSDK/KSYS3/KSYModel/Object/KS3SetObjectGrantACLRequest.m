//
//  KSS3SetObjectGrantACLRequest.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3SetObjectGrantACLRequest.h"
#import "KS3GrantAccessControlList.h"
#import "KS3Constants.h"
#import "KS3Client.h"

@implementation KS3SetObjectGrantACLRequest

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKeyName grantAcl:(KS3GrantAccessControlList *)grantAcl
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.key = [self URLEncodedString:strKeyName];
        self.acl = grantAcl;
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = @"";
        
        //
        self.kSYResource = [NSString stringWithFormat:@"%@/%@?acl", self.kSYResource, _key];
        NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", _acl.identifier];
        strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", _acl.displayName];
        self.kSYHeader = [_acl.accessGrantACL stringByAppendingString:@":"];
        self.kSYHeader = [self.kSYHeader stringByAppendingString:strValue];
        self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
        self.host = [NSString stringWithFormat:@"%@://%@.%@/%@?acl", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain], _key];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", _acl.identifier];
    strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", _acl.displayName];
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodPut];
    [self.urlRequest setValue:strValue forHTTPHeaderField:_acl.accessGrantACL];
    
    return self.urlRequest;
}

@end
