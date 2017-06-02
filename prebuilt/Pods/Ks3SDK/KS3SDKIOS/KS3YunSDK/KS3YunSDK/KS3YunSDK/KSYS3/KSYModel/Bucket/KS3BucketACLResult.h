//
//  KSS3BucketACLResult.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Owner.h"
#import "KS3Grant.h"

@interface KS3BucketACLResult : NSObject
@property (strong, nonatomic) KS3Owner *owner;
@property (strong, nonatomic) NSMutableArray *accessControlList;
@end
