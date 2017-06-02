//
//  KSS3GrantAccessControlList.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3GrantAccessControlList.h"

@implementation KS3GrantAccessControlList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _accessGrantACL = @"";
    }
    return self;
}

- (NSString *)setGrantControlAccess:(KingSoftYun_GrantPermissionACLType)grantAclType
{
    _accessGrantACL = @"";
    switch (grantAclType) {
        case KingSoftYun_Grant_Permission_Read:
            _accessGrantACL = @"x-kss-grant-read";
            break;
        case KingSoftYun_Grant_Permission_Write:
            _accessGrantACL = @"x-kss-grant-write";
            break;
        case KingSoftYun_Grant_Permission_Read_ACP:
            _accessGrantACL = @"x-kss-grant-read-acp";
            break;
        case KingSoftYun_Grant_Permission_Write_ACP:
            _accessGrantACL = @"x-kss-grant-write-acp";
            break;
        case KingSoftYun_Grant_Permission_Full_Control:
            _accessGrantACL = @"x-kss-grant-full-control";
            break;
        default:
            break;
    }
    return _accessGrantACL;
}

@end
