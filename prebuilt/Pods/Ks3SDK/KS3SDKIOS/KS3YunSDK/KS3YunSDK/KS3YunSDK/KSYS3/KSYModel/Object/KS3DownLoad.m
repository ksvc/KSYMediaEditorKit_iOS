//
//  MSDownLoad.m
//  MusicSample
//
//  Created by JackWong on 14-1-9.
//  Copyright (c) 2014年 JackWong. All rights reserved.
//

#import "KS3DownLoad.h"
#import "KS3SDKUtil.h"
#import "KS3Credentials.h"
#import "KS3AuthUtils.h"
#import "KS3Request.h"
#import "KS3Response.h"
#import "KS3Constants.h"
#import "KS3Client.h"
@interface KS3DownLoad ()

@property (strong, nonatomic) KS3Credentials *credentials;
@end

@implementation KS3DownLoad {
}

@synthesize delegate;
@synthesize overwrite;
@synthesize url;
@synthesize fileName;
@synthesize filePath;
@synthesize fileSize;

- (id)initWithUrl:(NSString *)aUrl credentials:(KS3Credentials *)credentials :(NSString *)bucketName :(NSString *)objectKey
{
    self = [super init];
    if (self)
    {
        _credentials = credentials;
        url = aUrl;
        _requestDate = getCurrentDate();
        _strDate = [KS3AuthUtils strDateWithDate:_requestDate andType:@"GMT"];
        _contentMd5 = @"";
        _contentType = @"";
        _kSYHeader = @"";
        _kSYResource = @"";
        _strKS3Token = nil;
        _httpMethod = kHttpMethodGet;
        _bucketName = [self URLEncodedString:bucketName];
        _key = [self URLEncodedString:objectKey];
        _kSYResource = [NSString stringWithFormat:@"/%@/%@", _bucketName,_key];
        
    }
    return self;
}

- (NSString *)URLEncodedString:(NSString *)str
{
    
    NSMutableString *output = [NSMutableString string];
    
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    
    int sourceLen = (int)strlen((const char *)source);
    
    for (int i = 0; i < sourceLen; ++i) {
        
        const unsigned char thisChar = source[i];
        
        if (thisChar == ' '){
            
            [output appendString:@"+"];
            
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   
                   (thisChar >= '0' && thisChar <= '9')) {
            
            [output appendFormat:@"%c", thisChar];
            
        } else {
            
            [output appendFormat:@"%%%02X", thisChar];
            
        }
        
    }
    
    return output;
    
}

- (NSString *)applicationDocumentFilePath
{
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}
- (void)start
{
    if (!url)
    {
        if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"Url can not be nil!" code:110 userInfo:nil];
                [delegate downloadFaild:self didFailWithError:error];
        }
    }
    fileName = [url lastPathComponent];
//    if (!fileName)
//    {
//        NSString *urlStr = [url absoluteString];
//        fileName = [urlStr lastPathComponent];
//        if ([fileName length] > 32) fileName = [fileName substringFromIndex:[fileName length]-32];
//    }
    _isStop = NO;
    NSString *deletingPathExtension = [url MD5Hash];
    
    NSString *pathExtension = [url pathExtension];
    
    if (!filePath)
    {
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        filePath = documentsDir;
    }
    destinationPath=[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",deletingPathExtension,pathExtension]];
    
	temporaryPath=[filePath stringByAppendingPathComponent:deletingPathExtension];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
    {
        if (overwrite)
        {
            [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
        }else
        {
            NSLog(@"本地已存在");
            if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
                [delegate downloadProgressChange:self progress:1.0];
            }
            if (delegate && [delegate respondsToSelector:@selector(downloadFinished:filePath:)]) {
                [delegate downloadFinished:self filePath:destinationPath];
            }
            if (_downloadProgressChangeBlock) {
                _downloadProgressChangeBlock(self,1.0);
            }
            if (_downloadFileCompleteionBlock) {
                _downloadFileCompleteionBlock(self,destinationPath);
            }
            return;
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryPath])
    {
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:temporaryPath contents:nil attributes:nil];
        if (!createSucces)
        {
            if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"Temporary File can not be create!" code:111 userInfo:nil];
                [delegate downloadFaild:self didFailWithError:error];
            }
            if (_failedBlock) {
                NSError *error = [NSError errorWithDomain:@"Temporary File can not be create!" code:111 userInfo:nil];
                _failedBlock(self, error);
            }
            return;
        }
    }
    
    [fileHandle closeFile];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:temporaryPath];
    offset = [fileHandle seekToEndOfFile];
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
    
    KS3Client * ks3Client = [KS3Client initialize];
    NSString * customBucketDomain = [ks3Client getCustomBucketDomain];
    
    NSString *strHost;
    if ( customBucketDomain!= nil) {
        strHost = [NSString stringWithFormat:@"%@://%@/%@", [ks3Client requestProtocol], customBucketDomain, _key];
    }else{
        strHost = [NSString stringWithFormat:@"%@://%@.%@/%@", [ks3Client requestProtocol], _bucketName,[ks3Client getBucketDomain], _key];
    }
    
    
    NSString *strAuthorization = @"";
    if (_credentials.accessKey != nil && _credentials.secretKey != nil) {
        strAuthorization = [KS3AuthUtils strAuthorizationWithHTTPVerb:_credentials.accessKey
                                                            secretKey:_credentials.secretKey
                                                             httpVerb:KSS3_HTTPVerbGet
                                                           contentMd5:@""
                                                          contentType:@""
                                                                 date:_requestDate
                                               canonicalizedKssHeader:@""
                                                canonicalizedResource:_kSYResource];
    }
    
    NSTimeInterval downloadTimeOut = _timeoutInterval;
    if (_timeoutInterval == 0 || _timeoutInterval < 0) {
        downloadTimeOut = 60;
    }
    NSURL *urlRequest = [NSURL URLWithString:strHost];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:downloadTimeOut];
    [request setHTTPMethod:@"GET"];
    [request setValue:_strDate forHTTPHeaderField:@"Date"];
    [request setValue:strAuthorization forHTTPHeaderField:@"Authorization"];
    [request addValue:range forHTTPHeaderField:@"Range"];
    
    // **** set token
    NSLog(@"====== start ======");
    if (_credentials == nil) {
        NSLog(@"====== _credentials is empty ======");
//        NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   @"GET",  @"http_method",
//                                   @"",     @"content_md5",
//                                   @"",     @"content_type",
//                                   _strDate, @"date",
//                                   @"",     @"headers",
//                                   @"",     @"resource", nil];
        [request setValue:_strKS3Token forHTTPHeaderField:@"Authorization"];
    }
    [connection cancel];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:KSYS3DefaultRunLoopMode];
    
    [connection start];
    
    while (!_isFinished)
    {
        if (_isStop == YES) {
            break;
        }
        [[NSRunLoop currentRunLoop] runMode:KSYS3DefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (KS3Response *)startURLRequest:(NSMutableURLRequest *)urlRequest
                      KS3Request:(KS3Request *)request
                           token:(NSString *)strToken {
    if (strToken != nil) {
        [urlRequest setValue:strToken forHTTPHeaderField:@"Authorization"];
        [connection cancel];
        connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    }
    return nil;
}


- (void)stop
{
    _isStop = YES;
    [connection cancel];
    connection = nil;
    [fileHandle closeFile];
    fileHandle = nil;
}

- (void)stopAndClear
{
    [self stop];
    [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil];
    
    
    
    if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
       [delegate downloadProgressChange:self progress:0];
    }
    if (_downloadProgressChangeBlock) {
        _downloadProgressChangeBlock(self,0.0);
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response expectedContentLength] != NSURLResponseUnknownLength)
        fileSize = (unsigned long long)[response expectedContentLength]+offset;
    if (delegate && [delegate respondsToSelector:@selector(downloadBegin:didReceiveResponseHeaders:)]) {
         [delegate downloadBegin:self didReceiveResponseHeaders:response];
    }
    if (_downloadBeginBlock) {
        _downloadBeginBlock(self, response);
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    [fileHandle writeData:aData];
    offset = [fileHandle offsetInFile];
    double progress = offset*1.0/fileSize;
    if (_downloadProgressChangeBlock) {
        _downloadProgressChangeBlock(self,progress);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
        [delegate downloadProgressChange:self progress:progress];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [fileHandle closeFile];
    if (_failedBlock) {
        _failedBlock(self, error);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
       [delegate downloadFaild:self didFailWithError:error];
    }
   
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isFinished = YES;
    [fileHandle closeFile];
    [[NSFileManager defaultManager] moveItemAtPath:temporaryPath toPath:destinationPath error:nil];
    
    if (_downloadFileCompleteionBlock) {
        _downloadFileCompleteionBlock(self, destinationPath);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadFinished:filePath:)]) {
        [delegate downloadFinished:self filePath:destinationPath];
    }
}

@end
