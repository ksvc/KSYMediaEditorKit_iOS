//
//  KSS3ListPartsResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Response.h"
#import "KS3ListPartsResult.h"

@class KS3ListPartsResult;
@interface KS3ListPartsResponse : KS3Response

@property (strong, nonatomic) KS3ListPartsResult *listResult;
@end
