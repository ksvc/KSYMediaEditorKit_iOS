//
//  KS3ErrorHandler.m
//  KS3YunSDK
//
//  Created by JackWong on 12/23/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

// Public Constants
#import "KS3ErrorHandler.h"
#import "KS3ClientException.h"

NSString *const KS3iOSSDKServiceErrorDomain = @"com.ks3yun.iossdk.ServiceErrorDomain";
NSString *const KS3iOSSDKClientErrorDomain = @"com.ks3yun.iossdk.ClientErrorDomain";
static BOOL throwsExceptions = NO;

@implementation KS3ErrorHandler

+ (void)shouldThrowExceptions
{
    throwsExceptions = YES;
}

+ (void)shouldNotThrowExceptions
{
    throwsExceptions = NO;
}

+ (BOOL)throwsExceptions
{
    return throwsExceptions;
}

+ (NSError *)errorFromExceptionWithThrowsExceptionOption:(NSException *)exception
{
    if(exception == nil)
    {
        return nil;
    }
    else if(throwsExceptions == YES)
    {
        @throw exception;
    }
    else if(![exception isKindOfClass:[KS3ClientException class]])
    {
        // Fatal error. This should not happen.
        @throw exception;
    }
    
    return [KS3ErrorHandler errorFromException:exception];
}

+ (NSError *)errorFromException:(NSException *)exception serviceErrorDomain:(NSString *)serviceErrorDomain clientErrorDomain:(NSString *)clientErrorDomain
{
    NSError *error = nil;
    
    if([exception isKindOfClass:[KS3ClientException class]])
    {
        KS3ClientException *clientException = (KS3ClientException *)exception;
        
        if(clientException.error != nil)
        {
            error = clientException.error;
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      clientException.message, @"message",
                                      clientException, @"exception", nil];
            
            error = [NSError errorWithDomain:clientErrorDomain code:-1 userInfo:userInfo];
        }
    }
    
    // Return nil for non Amazon exceptions.
    return error;
}

+ (NSError *)errorFromException:(NSException *)exception
{
    return [KS3ErrorHandler errorFromException:exception
                            serviceErrorDomain:KS3iOSSDKServiceErrorDomain
                             clientErrorDomain:KS3iOSSDKClientErrorDomain];
}


@end
