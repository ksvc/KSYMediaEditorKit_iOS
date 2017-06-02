//
//  KSS3ListPartsRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"
#import "KS3MultipartUpload.h"

@interface KS3ListPartsRequest : KS3Request

@property (strong, nonatomic) NSString *key;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, assign) int32_t maxParts;
@property (nonatomic, assign) int32_t partNumberMarker;
@property (nonatomic, strong) NSString *encodingType;

- (id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload;

@end
