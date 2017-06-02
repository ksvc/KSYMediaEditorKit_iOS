//
//  S3Request.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ServiceRequest.h"

@interface KS3Request : KS3ServiceRequest
@property (strong, nonatomic) NSString *bucket;
@property (nonatomic, assign) int64_t contentLength;
@end
