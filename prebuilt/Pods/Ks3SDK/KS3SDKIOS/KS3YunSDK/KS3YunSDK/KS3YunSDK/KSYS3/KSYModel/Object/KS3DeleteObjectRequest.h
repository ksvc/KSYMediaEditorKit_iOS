//
//  KSS3DeleteObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3DeleteObjectRequest : KS3Request

@property (nonatomic, strong) NSString *key;

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKey;

@end
