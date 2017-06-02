//
//  KSS3ListObjectsRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3ListObjectsRequest : KS3Request

@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *marker;
@property (nonatomic) int32_t maxKeys;
@property (nonatomic, retain) NSString *delimiter;
@property (nonatomic, strong) NSString *encodingType;

- (instancetype)initWithName:(NSString *)bucketName;

@end
