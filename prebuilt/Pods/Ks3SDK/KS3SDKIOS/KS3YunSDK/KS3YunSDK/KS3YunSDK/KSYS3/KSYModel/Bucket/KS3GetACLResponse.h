//
//  KSS3BucketACLResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Response.h"
@class KS3BucketACLResult;
@interface KS3GetACLResponse : KS3Response

@property (nonatomic, strong) KS3BucketACLResult *listBucketsResult;
@end
