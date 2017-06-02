//
//  KSS3ListPartsResult.h
//  KS3SDK
//
//  Created by JackWong on 12/16/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Owner.h"

@interface KS3ListPartsResult : NSObject

@property (strong, nonatomic) NSString *Bucket;

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *UploadId;

@property (nonatomic) int32_t partNumberMarker;

@property (nonatomic) int32_t maxParts;

@property (nonatomic) BOOL isTruncated;

@property (strong, nonatomic) KS3Owner *initiator;

@property (strong, nonatomic) KS3Owner *owner;

@property (strong, nonatomic) NSMutableArray *parts;



@end
