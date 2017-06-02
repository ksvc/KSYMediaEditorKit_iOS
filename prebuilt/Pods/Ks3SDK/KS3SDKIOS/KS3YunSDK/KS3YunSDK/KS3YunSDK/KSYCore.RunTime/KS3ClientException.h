//
//  KS3ClientException.h
//  KS3YunSDK
//
//  Created by JackWong on 12/22/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3ClientException : NSException

@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) NSError *error;

+ (id)exceptionWithMessage:(NSString *)theMessage;

+ (id)exceptionWithMessage:(NSString *)theMessage andError:(NSError *)theError;

@end
