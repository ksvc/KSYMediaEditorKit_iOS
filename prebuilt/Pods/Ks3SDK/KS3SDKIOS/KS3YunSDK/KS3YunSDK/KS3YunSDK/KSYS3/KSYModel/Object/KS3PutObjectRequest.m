//
//  KSS3PutObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3PutObjectRequest.h"
#import "KS3Constants.h"
#import "KS3SDKUtil.h"
#import "KS3AccessControlList.h"
#import "KS3GrantAccessControlList.h"
#import "KS3Client.h"
@implementation KS3PutObjectRequest

- (instancetype)initWithName:(NSString *)bucketName withAcl:(KS3AccessControlList *)acl grantAcl:(NSArray *)arrGrantAcl
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = nil;
        self.contentType = @"application/octet-stream";
        self.kSYHeader = @"";
        self.generateMD5 = YES;
        self.acl = acl;
        self.arrGrantAcl = arrGrantAcl;
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        
        KS3Client * ks3Client = [KS3Client initialize];
        NSString * customBucketDomain = [ks3Client getCustomBucketDomain];
        
        if ( customBucketDomain!= nil) {
            self.host = [NSString stringWithFormat:@"%@://%@", [[KS3Client initialize] requestProtocol], customBucketDomain];
        }else{
           self.host = [NSString stringWithFormat:@"%@://%@.%@", [[KS3Client initialize] requestProtocol], self.bucket,[ks3Client getBucketDomain]]; // **** 线上版本，无callback
        }
//        self.host = [NSString stringWithFormat:@"http://115.231.96.27:8080/%@", bucketName]; // **** 线上测试callback
        
        if (_acl != nil) {
            self.kSYHeader = [@"x-kss-acl:" stringByAppendingString:_acl.accessACL];
            self.kSYHeader = [NSString stringWithFormat:@"%@\n",self.kSYHeader];
        }
        if (_arrGrantAcl != nil) {
            for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
                KS3GrantAccessControlList *grantAcl = _arrGrantAcl[i];
                NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", grantAcl.identifier];
                strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", grantAcl.displayName];
                self.kSYHeader = [self.kSYHeader stringByAppendingString:[grantAcl.accessGrantACL stringByAppendingString:@":"]];
                self.kSYHeader = [self.kSYHeader stringByAppendingString:strValue];
                self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
            }
        }
    }
    return self;
}

- (void)sortGrantAcl {
    NSMutableArray *arrAccessGrantAcl = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
        KS3GrantAccessControlList *grantAcl = _arrGrantAcl[i];
        [arrAccessGrantAcl addObject:grantAcl.accessGrantACL];
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *resultArray = [arrAccessGrantAcl sortedArrayUsingDescriptors:descriptors];
    NSMutableArray *arrGrantAcl = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
        NSString *strAccessGrantAcl = resultArray[i];
        for (NSInteger j = 0; j < _arrGrantAcl.count; j ++) {
            KS3GrantAccessControlList *grantAcl = _arrGrantAcl[j];
            if ([grantAcl.accessGrantACL isEqualToString:strAccessGrantAcl] == YES) {
                [arrGrantAcl addObject:grantAcl];
                break;
            }
        }
    }
    self.arrGrantAcl = arrGrantAcl;
}

- (void)setCompleteRequest
{
    [self.urlRequest setHTTPBody:_data];
    [self.urlRequest setValue:self.contentType forHTTPHeaderField:kKSHttpHdrContentType];
    
    if (_acl != nil) {
        [self.urlRequest setValue:_acl.accessACL forHTTPHeaderField:@"x-kss-acl"];
    }
    
    if (_arrGrantAcl != nil) {
        for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
            KS3GrantAccessControlList *grantAcl = _arrGrantAcl[i];
            NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", grantAcl.identifier];
            strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", grantAcl.displayName];
            [self.urlRequest setValue:strValue forHTTPHeaderField:grantAcl.accessGrantACL];
        }
    }
    
    // **** 一定要先设置callbackbody，再设置callbackurl才可以签名成功
    if (nil != _callbackBody && nil != _callbackUrl) {
        self.kSYHeader = [self.kSYHeader stringByAppendingString:[@"x-kss-callbackbody:" stringByAppendingString:_callbackBody]];
        self.kSYHeader = [self.kSYHeader stringByAppendingFormat:@"\n"];
        [self.urlRequest setValue:_callbackBody forHTTPHeaderField:@"x-kss-callbackbody"];
        
        NSString *callbackUrl = [@"x-kss-callbackurl:" stringByAppendingString:_callbackUrl];
        self.kSYHeader = [self.kSYHeader stringByAppendingFormat:@"%@\n", callbackUrl];
        [self.urlRequest setValue:_callbackUrl forHTTPHeaderField:@"x-kss-callbackurl"];
        
        // **** 回调的自定义参数
        if (nil != _callbackParams) {
            for (NSString *strKey in _callbackParams.allKeys) {
                if (strKey.length >= 4 && [[strKey substringToIndex:4] isEqualToString:@"kss-"] == YES) {
                    [self.urlRequest setValue:_callbackParams[strKey] forHTTPHeaderField:strKey];
                }
                else {
                    NSLog(@"The header with field: \"%@\" and value: \"%@\" is not cocrect, this header will be ingored", strKey, _callbackParams[strKey]);
                }
            }
        }
    }
    if (nil == self.contentMd5 && YES == self.generateMD5 && self.data != nil) {
        self.contentMd5 = [KS3SDKUtil base64md5FromData:self.data];
    }
    [self.urlRequest setValue:self.contentMd5 forHTTPHeaderField:kKS3HttpHdrContentMD5];
    
    _filename = [self URLEncodedString:_filename];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_filename];
    
    self.host = [NSString stringWithFormat:@"%@/%@",self.host,_filename];
    
    if (![self.kSYHeader isEqualToString:@""]) {
        NSArray *componentsArray = [self.kSYHeader componentsSeparatedByString:@"\n"];
        NSMutableArray *componentsArray1 = [[NSMutableArray alloc] initWithArray:componentsArray];
        if (componentsArray1.count) {
            [componentsArray1 removeLastObject];
        }
        NSArray *headerArray = [componentsArray1 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        self.kSYHeader = [headerArray componentsJoinedByString:@"\n"];
        self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
      
    }
}

- (KS3URLRequest *)configureURLRequest
{

    [super configureURLRequest];
    return self.urlRequest;
}

@end
