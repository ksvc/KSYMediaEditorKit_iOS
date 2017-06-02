//
//  KSS3Grant.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KS3Grantee;
@interface KS3Grant : NSObject
@property (strong, nonatomic) NSString *permission;
@property (strong, nonatomic) KS3Grantee *grantee;

@end

@interface KS3Grantee : NSObject
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *URI;

@end
