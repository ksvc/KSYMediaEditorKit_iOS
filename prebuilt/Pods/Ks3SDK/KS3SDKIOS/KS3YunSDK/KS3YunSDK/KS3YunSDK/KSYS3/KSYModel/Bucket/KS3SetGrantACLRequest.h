//
//  KSS3SetGrantACLRequest.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3Request.h"

@class KS3GrantAccessControlList;

@interface KS3SetGrantACLRequest : KS3Request

@property (nonatomic, strong) KS3GrantAccessControlList *acl;

- (instancetype)initWithName:(NSString *)bucketName accessACL:(KS3GrantAccessControlList *)accessACL;

@end
