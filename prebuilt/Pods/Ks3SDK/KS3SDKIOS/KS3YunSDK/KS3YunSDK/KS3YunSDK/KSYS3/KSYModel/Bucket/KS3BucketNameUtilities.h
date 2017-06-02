//
//  KS3BucketNameUtilities.h
//  KS3YunSDK
//
//  Created by JackWong on 12/23/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KS3ClientException;
@interface KS3BucketNameUtilities : NSObject
+ (KS3ClientException *)validateBucketName:(NSString *)theBucketName;
@end
