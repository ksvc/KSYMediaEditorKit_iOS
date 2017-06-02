//
//  KSS3GetObjectACLResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetObjectACLResponse.h"
#import "KS3ObjectACLXMLParser.h"
#import "KS3BucketACLResult.h"
@implementation KS3GetObjectACLResponse

-(void)processBody
{
    KS3ObjectACLXMLParser *xmlParser = [[KS3ObjectACLXMLParser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _listBucketsResult = xmlParser.listBuctkResult;
}
@end
