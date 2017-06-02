//
//  S3ListBucketsResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Response.h"
@class KS3ListBucketsResult;
@interface KS3ListBucketsResponse : KS3Response

@property (nonatomic, strong) KS3ListBucketsResult *listBucketsResult;
@end
