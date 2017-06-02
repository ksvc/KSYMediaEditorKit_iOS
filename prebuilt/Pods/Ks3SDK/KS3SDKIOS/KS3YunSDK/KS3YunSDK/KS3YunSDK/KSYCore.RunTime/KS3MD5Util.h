//
//  KingSoftMD5Util.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3MD5Util : NSObject
+ (NSString *)hexEncode:(NSString *)key text:(NSString *)text;

@end
