//
//  ListBucketObjects.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3ListObjectsResult : NSObject

@property (strong, nonatomic) NSMutableArray *objectSummaries;
@property (strong, nonatomic) NSString *bucketName;
@property (strong, nonatomic) NSString *prefix;
@property (strong, nonatomic) NSString *marker;
@property (strong, nonatomic) NSString *NextMarker;
@property (nonatomic) int32_t maxKeys;
@property (strong, nonatomic) NSString *delimiter;
@property (assign, nonatomic) BOOL IsTruncated;
@property (strong ,nonatomic) NSMutableArray *commonPrefixes;
@end
