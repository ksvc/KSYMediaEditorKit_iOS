//
//  KingSoftServiceResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ServiceResponse.h"
#import "KS3ServiceRequest.h"
#import "KS3UploadPartRequest.h"
#import "KS3ListPartsResponse.h"
#import "KS3Part.h"
@implementation KS3ServiceResponse

-(NSData *)body
{
    return [NSData dataWithData:body];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    // setting response header to use it in shouldRetry method of AmazonAbstractWebServiceClient
    _responseHeader = [httpResponse allHeaderFields];
    NSLog(@"Response Headers:");
    for (NSString *header in [[httpResponse allHeaderFields] allKeys]) {
        NSLog(@"%@ = [%@]", header, [[httpResponse allHeaderFields] valueForKey:header]);
    }
    self.httpStatusCode = (int32_t)[httpResponse statusCode];
    [body setLength:0];
    if ([self.request.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [self.request.delegate request:self.request didReceiveResponse:response];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == body) {
        body = [NSMutableData data] ;
    }
    [body appendData:data];
    if ([self.request.delegate respondsToSelector:@selector(request:didReceiveData:)]) {
        [self.request.delegate request:self.request didReceiveData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isFinishedLoading = YES;
    NSString *tmpStr = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    NSLog(@"Response Body:\n%@", tmpStr);
    [self processBody];
    if ([self.request isKindOfClass:[KS3ListPartsResponse class]]) {
        KS3ListPartsResponse *listParts = (KS3ListPartsResponse *)self.request;
        NSLog(@"%@",listParts.listResult.parts);
        for (KS3Part *part in listParts.listResult.parts) {
            NSLog(@"part = %@",part);
        }
    }
    if (_request.delegate && [_request.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
        [_request.delegate request:self.request didCompleteWithResponse:self];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError
{
    _isFinishedLoading = YES;
    NSDictionary *info = [theError userInfo];
    NSLog(@"%@",info);
    self.error = theError;
//    for (id key in info)
//    {
//        NSLog(@"UserInfo.%@ = %@\n", [key description], [[info valueForKey:key] description]);
//    }
    if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.request.delegate request:self.request didFailWithError:theError];
    }
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
    //上传暂停
    if ( [self.request isKindOfClass:[KS3UploadPartRequest class  ]]  ) {
        KS3UploadPartRequest *req = (KS3UploadPartRequest *)self.request;
        if (req.multipartUpload.isPaused) {
               [self.request cancel];
        }
     
    }
    
    if ([self.request.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.request.delegate request:self.request
                           didSendData:(long long)bytesWritten
                     totalBytesWritten:(long long)totalBytesWritten
             totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite];
    }
}

// When a request gets a redirect due to the bucket being in a different region,
// The request gets re-written with a GET http method. This is to set the method back to
// the appropriate method if necessary
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)proposedRequest redirectResponse:(NSURLResponse *)redirectResponse
{
    return proposedRequest;
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)processBody
{
    
}
- (void)timeout
{
    
}

@end
