//
//  KSS3AccessControlList.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,KingSoftYun_PermissionACLType)
{
    KingSoftYun_Permission_Private,
    KingSoftYun_Permission_Public_Read,
    KingSoftYun_Permission_Public_Read_Write,
    KingSoftYun_Permission_Authenticated_Read,
    
};

@interface KS3AccessControlList : NSObject
@property (strong, nonatomic) NSString *accessACL;

- (NSString *)setContronAccess:(KingSoftYun_PermissionACLType)aclType;
@end
