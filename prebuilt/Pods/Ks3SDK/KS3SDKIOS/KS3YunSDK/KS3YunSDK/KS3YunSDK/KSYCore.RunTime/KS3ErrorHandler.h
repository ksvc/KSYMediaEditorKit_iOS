//
//  KS3ErrorHandler.h
//  KS3YunSDK
//
//  Created by JackWong on 12/23/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const KS3iOSSDKServiceErrorDomain;
extern NSString *const KS3iOSSDKClientErrorDomain;

@interface KS3ErrorHandler : NSObject
+ (void)shouldThrowExceptions __attribute__((deprecated));
+ (void)shouldNotThrowExceptions;
+ (BOOL)throwsExceptions;
+ (NSError *)errorFromExceptionWithThrowsExceptionOption:(NSException *)exception;
+ (NSError *)errorFromException:(NSException *)exception;
+ (NSError *)errorFromException:(NSException *)exception serviceErrorDomain:(NSString *)serviceErrorDomain clientErrorDomain:(NSString *)clientErrorDomain;
@end
