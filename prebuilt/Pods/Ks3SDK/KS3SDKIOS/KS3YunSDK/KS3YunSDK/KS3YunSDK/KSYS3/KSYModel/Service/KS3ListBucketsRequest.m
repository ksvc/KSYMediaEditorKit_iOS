//
//  S3ListBucketsRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListBucketsRequest.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@implementation KS3ListBucketsRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = @"/";
        self.host =  [NSString stringWithFormat:@"%@://%@", [[KS3Client initialize] requestProtocol], [[KS3Client initialize]getBucketDomain]] ;
    }
    return self;
}

@end
