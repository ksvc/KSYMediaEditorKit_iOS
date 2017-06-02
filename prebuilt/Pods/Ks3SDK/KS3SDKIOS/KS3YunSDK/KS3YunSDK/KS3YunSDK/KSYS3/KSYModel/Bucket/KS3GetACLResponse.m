//
//  KSS3BucketACLResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetACLResponse.h"
#import "KS3BucketACLXMLParser.h"
#import "KS3BucketACLResult.h"
@implementation KS3GetACLResponse

-(void)processBody
{
    KS3BucketACLXMLParser *xmlParser = [[KS3BucketACLXMLParser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _listBucketsResult = xmlParser.listBuctkResult;
    
}
@end
