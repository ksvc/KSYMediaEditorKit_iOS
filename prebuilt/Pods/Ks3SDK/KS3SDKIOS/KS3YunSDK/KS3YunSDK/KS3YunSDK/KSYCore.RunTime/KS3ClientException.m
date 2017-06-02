//
//  KS3ClientException.m
//  KS3YunSDK
//
//  Created by JackWong on 12/22/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ClientException.h"

@implementation KS3ClientException

+ (id)exceptionWithMessage:(NSString *)theMessage
{
    KS3ClientException *e = [[[self class] alloc] initWithName:@"KS3ClientException"
                                                           reason:theMessage
                                                         userInfo:nil];
    e.error = nil;
    e.message = theMessage;
    
    return e;
}

+ (id)exceptionWithMessage:(NSString *)theMessage andError:(NSError *)theError
{
    KS3ClientException *e = [[[self class] alloc] initWithName:@"KS3ClientException"
                                                           reason:theMessage
                                                         userInfo:nil];
    e.error   = theError;
    e.message = theMessage;
    
    return e;
}


- (id)initWithMessage:(NSString *)theMessage
{
    self = [super initWithName:@"KS3ClientException" reason:theMessage userInfo:nil];
    if (self) {
        _message = theMessage;
    }
    return self;
}
@end
