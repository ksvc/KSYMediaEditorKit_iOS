//
//  KSS3GetObjectACLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3GetObjectACLRequest : KS3Request

@property (strong, nonatomic) NSString *key;

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKey;
@end
