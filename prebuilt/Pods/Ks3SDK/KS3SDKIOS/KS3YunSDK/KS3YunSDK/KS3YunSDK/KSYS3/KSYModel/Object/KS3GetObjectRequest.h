//
//  KSS3GetObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3GetObjectRequest : KS3Request

@property (nonatomic, strong) NSString *responseContentType;
@property (nonatomic, strong) NSString *responseContentLanguage;
@property (nonatomic, strong) NSString *responseExpires;
@property (nonatomic, strong) NSString *responseCacheControl;
@property (nonatomic, strong) NSString *responseContentDisposition;
@property (nonatomic, strong) NSString *responseContentEncoding;

@property (nonatomic, strong) NSString *range;
@property (nonatomic, strong) NSString *ifModifiedSince;
@property (nonatomic, strong) NSString *ifUnmodifiedSince;
@property (nonatomic, strong) NSString *ifMatch;
@property (nonatomic, strong) NSString *ifNoneMatch;
@property (nonatomic, strong) NSString *versionId;
@property (nonatomic, strong) NSString *key;

- (instancetype)initWithName:(NSString *)bucketName;

@end
