//
//  KSS3SetObjectACLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"
@class KS3AccessControlList;
@interface KS3SetObjectACLRequest : KS3Request

@property (strong, nonatomic) NSString *key;

@property (strong, nonatomic) KS3AccessControlList *acl;

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKeyName acl:(KS3AccessControlList *)acl;

@end
