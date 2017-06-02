//
//  KSS3GrantAccessControlList.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    KingSoftYun_Grant_Permission_Read,
    KingSoftYun_Grant_Permission_Write,
    KingSoftYun_Grant_Permission_Read_ACP,
    KingSoftYun_Grant_Permission_Write_ACP,
    KingSoftYun_Grant_Permission_Full_Control,
}KingSoftYun_GrantPermissionACLType;

@interface KS3GrantAccessControlList : NSObject

@property (nonatomic, strong) NSString *accessGrantACL;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *displayName;

- (NSString *)setGrantControlAccess:(KingSoftYun_GrantPermissionACLType)grantAclType;

@end
