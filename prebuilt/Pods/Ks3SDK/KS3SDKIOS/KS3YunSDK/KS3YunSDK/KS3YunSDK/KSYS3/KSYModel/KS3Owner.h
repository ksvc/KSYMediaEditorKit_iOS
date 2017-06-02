//
//  S3Owner.h
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3Owner : NSObject

@property (strong, nonatomic) NSString *ID;

@property (strong, nonatomic) NSString *displayName;

-(id)initWithID:(NSString *)theID withDisplayName:(NSString *)theDisplayName;

+(id)ownerWithID:(NSString *)theID withDisplayName:(NSString *)theDisplayName;

@end
