//
//  KSS3ListObjectsResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListObjectsResponse.h"
#import "KS3ListObjectsResult.h"
#import "KS3ListObjectsXMLPrarser.h"
#import "KS3ObjectSummary.h"
#import "KS3Owner.h"
@implementation KS3ListObjectsResponse
-(void)processBody
{
    KS3ListObjectsXMLPrarser *xmlParser = [[KS3ListObjectsXMLPrarser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _listBucketsResult = xmlParser.listBuctkResult;
}
@end
