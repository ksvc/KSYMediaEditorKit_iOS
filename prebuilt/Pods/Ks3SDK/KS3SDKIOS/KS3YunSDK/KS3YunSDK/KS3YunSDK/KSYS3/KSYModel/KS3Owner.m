//
//  S3Owner.m
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Owner.h"

@implementation KS3Owner

-(id)initWithID:(NSString *)theID withDisplayName:(NSString *)theDisplayName
{
    self = [super init];
    if (self) {
        _ID          = theID;
        _displayName = theDisplayName;
    }
    return self;
}

+(id)ownerWithID:(NSString *)theID withDisplayName:(NSString *)theDisplayName
{
    return [[self alloc] initWithID:theID withDisplayName:theDisplayName];
}


@end
