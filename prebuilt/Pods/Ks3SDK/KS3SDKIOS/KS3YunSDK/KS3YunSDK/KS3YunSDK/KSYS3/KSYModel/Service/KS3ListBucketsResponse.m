//
//  S3ListBucketsResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListBucketsResponse.h"
#import "KS3ListBucketsXMLParser.h"
#import "KS3Bucket.h"
@implementation KS3ListBucketsResponse

-(void)processBody
{
    KS3ListBucketsXMLParser *xmlParser = [[KS3ListBucketsXMLParser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _listBucketsResult = xmlParser.listBuctkResult;
}
@end
