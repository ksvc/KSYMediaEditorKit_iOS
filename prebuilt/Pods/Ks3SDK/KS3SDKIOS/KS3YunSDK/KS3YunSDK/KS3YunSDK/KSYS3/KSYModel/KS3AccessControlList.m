//
//  KSS3AccessControlList.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3AccessControlList.h"

@implementation KS3AccessControlList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _accessACL = @"";
    }
    return self;
}
- (NSString *)setContronAccess:(KingSoftYun_PermissionACLType)aclType
{
    _accessACL = @"";
    switch (aclType) {
        case KingSoftYun_Permission_Private:
            _accessACL = @"private";
            break;
        case KingSoftYun_Permission_Public_Read:
            _accessACL = @"public-read";
            break;
        case KingSoftYun_Permission_Public_Read_Write:
            _accessACL = @"public-read-write";
            break;
        case KingSoftYun_Permission_Authenticated_Read:
            _accessACL = @"authenticated-read";
            break;
        default:
            break;
    }
    return _accessACL;
}
@end
