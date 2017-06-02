//
//  KSS3SetACLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@class KS3AccessControlList;
@interface KS3SetACLRequest : KS3Request

@property (strong, nonatomic) KS3AccessControlList *acl;

- (instancetype)initWithName:(NSString *)bucketName accessACL:(KS3AccessControlList *)accessACL;

@end
