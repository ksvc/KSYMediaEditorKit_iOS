//
//  KSS3CompleteMultipartUploadRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3CompleteMultipartUploadRequest.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@interface KS3CompleteMultipartUploadRequest ()
@property (strong, nonatomic) NSMutableDictionary *parts;
@end

@implementation KS3CompleteMultipartUploadRequest
-(id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload
{
    if(self = [super init])
    {
        self.bucket   = [self URLEncodedString:multipartUpload.bucket];
        self.key      = [self URLEncodedString:multipartUpload.key];
        self.uploadId = multipartUpload.uploadId;
        self.contentMd5 = @"";
        self.contentType = @"text/xml";
        self.httpMethod = kHttpMethodPost;
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        self.kSYHeader = @"";
    }
    return self;
}

- (void)setCompleteRequest
{
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
                    NSLog(@"The header with field: \"%@\" and value: \"%@\" is not correct, this header will be ingored", strKey, _callbackParams[strKey]);
                }
            }
        }
    }
    
    [self setKSYResource:[NSString stringWithFormat:@"%@/%@?%@=%@", self.kSYResource,_key, kKS3QueryParamUploadId, self.uploadId]];
    
    KS3Client * ks3Client = [KS3Client initialize];
    NSString * customBucketDomain = [ks3Client getCustomBucketDomain];
    if ( customBucketDomain!= nil) {
        self.host = [NSString stringWithFormat:@"%@://%@/%@?uploadId=%@", [[KS3Client initialize] requestProtocol], customBucketDomain, self.key,self.uploadId];
    }else{
       self.host = [NSString stringWithFormat:@"%@://%@.%@/%@?uploadId=%@", [[KS3Client initialize] requestProtocol], self.bucket,[ks3Client getBucketDomain], self.key, self.uploadId];
        
    }
    
    
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


-(NSURLRequest *)configureURLRequest
{
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodPost];
    [self.urlRequest setHTTPBody:[self requestBody]];
    [self.urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[[self.urlRequest HTTPBody] length]] forHTTPHeaderField:kKSHttpHdrContentLength];
    [self.urlRequest setValue:@"text/xml" forHTTPHeaderField:kKSHttpHdrContentType];
    return self.urlRequest;
}

- (void)addPartWithPartNumber:(int)partNumber withETag:(NSString *)etag
{
    if (_parts == nil) {
        _parts = [NSMutableDictionary new];
    }
    [_parts setObject:etag forKey:[NSNumber numberWithInt:partNumber]];
}
-(NSData *)requestBody
{
    NSMutableString *xml = [NSMutableString stringWithFormat:@"<CompleteMultipartUpload>"];
    NSComparator   comparePartNumbers = ^ (id part1, id part2) {
        return [part1 compare:part2];
    };
    NSArray *keys = [[self.parts allKeys] sortedArrayUsingComparator:comparePartNumbers];
    for (NSNumber *partNumber in keys)
    {
        [xml appendFormat:@"<Part><PartNumber>%d</PartNumber><ETag>%@</ETag></Part>", [partNumber intValue], [self.parts objectForKey:partNumber]];
    }
    [xml appendString:@"</CompleteMultipartUpload>"];
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
}
@end
