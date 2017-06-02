//
//  KSS3ListBucketsResult.h
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KS3Owner;

@interface KS3ListBucketsResult : NSObject

@property (nonatomic, strong) KS3Owner *owner;
@property (nonatomic, strong) NSMutableArray *buckets;

@end
