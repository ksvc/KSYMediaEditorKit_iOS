//
//  KSS3SetObjectGrantACLRequest.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3Request.h"

@class KS3GrantAccessControlList;

@interface KS3SetObjectGrantACLRequest : KS3Request

@property (nonatomic, strong) KS3GrantAccessControlList *acl;
@property (nonatomic, strong) NSString *key;

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKeyName grantAcl:(KS3GrantAccessControlList *)grantAcl;

@end
