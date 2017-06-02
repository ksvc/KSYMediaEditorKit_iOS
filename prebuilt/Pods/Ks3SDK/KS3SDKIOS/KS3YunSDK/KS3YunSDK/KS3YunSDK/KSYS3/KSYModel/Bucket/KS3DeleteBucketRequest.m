//
//  KSS3DeleteBucketRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3DeleteBucketRequest.h"
#import "KS3Constants.h"
#import "KS3ClientException.h"
#import "KS3Client.h"
@implementation KS3DeleteBucketRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodDelete;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@/", self.bucket];
        self.host = [NSString stringWithFormat:@"%@://%@.%@", [[KS3Client initialize] requestProtocol], self.bucket,[[KS3Client initialize]getBucketDomain]];
    }
    return self;
}
- (KS3ClientException *)validate
{
    KS3ClientException *clientException = [super validate];
    if(clientException == nil)
    {
        if (nil == self.bucket) {
            clientException = [KS3ClientException exceptionWithMessage : @"Bucket Name should not be nil."];
        }
    }
    return clientException;
}
@end
