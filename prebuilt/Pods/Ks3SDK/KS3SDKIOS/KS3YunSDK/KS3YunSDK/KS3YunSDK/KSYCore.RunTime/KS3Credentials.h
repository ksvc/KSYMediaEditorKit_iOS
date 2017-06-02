//
//  KingSoftCredentials.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3Credentials : NSObject

@property (strong, readonly, nonatomic) NSString *accessKey;
@property (strong, readonly, nonatomic) NSString *secretKey;

- (id)initWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey;

@end
