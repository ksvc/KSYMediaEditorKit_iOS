//
//  KSS3InitiateMultipartUploadResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3InitiateMultipartUploadResponse.h"
#import "KS3InitiateMultipartUploadXMLParser.h"

@implementation KS3InitiateMultipartUploadResponse

-(void)processBody
{
    KS3InitiateMultipartUploadXMLParser *xmlParser = [[KS3InitiateMultipartUploadXMLParser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _multipartUpload = xmlParser.listBuctkResult.multipartUpload;
    
}

@end
