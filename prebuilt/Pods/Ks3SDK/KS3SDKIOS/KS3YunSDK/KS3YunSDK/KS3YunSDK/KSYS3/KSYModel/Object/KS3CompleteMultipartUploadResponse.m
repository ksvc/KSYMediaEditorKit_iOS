//
//  KSS3CompleteMultipartUploadResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3CompleteMultipartUploadResponse.h"

@implementation KS3CompleteMultipartUploadResponse
-(void)processBody
{
    
    NSLog(@"KSS3CompleteMultipartUploadResponse %d",self.httpStatusCode);
}

@end
