//
//  KSS3Contents.h
//  KS3SDK
//
//  Created by JackWong on 12/13/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KS3Owner;
@interface KS3ObjectSummary : NSObject
@property (strong, nonatomic) NSString *Key;
@property (strong, nonatomic) NSString *LastModified;
@property (strong, nonatomic) NSString *ETag;
@property (strong, nonatomic) KS3Owner *owner;
@property (assign, nonatomic) int32_t size;
@property (strong, nonatomic) NSString *storageClass;

@end
