//
//  MSDownLoad.h
//  MusicSample
//
//  Created by JackWong on 14-1-9.
//  Copyright (c) 2014年 JackWong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Client.h"

@class KS3Credentials;

@protocol KS3DownloadDelegate;
@interface KS3DownLoad : NSObject
{

    BOOL        _isFinished;
    BOOL        _isStop;
    BOOL       overwrite;
	NSString      *url;
	NSString   *fileName;
    NSString   *filePath;
    unsigned long long fileSize;
@private
    NSString   *destinationPath;
    NSString   *temporaryPath;
    NSFileHandle        *fileHandle;
    NSURLConnection     *connection;
    unsigned long long  offset;
    
}
- (id)initWithUrl:(NSString *)aUrl credentials:(KS3Credentials *)credentials :(NSString *)bucketName :(NSString *)objectKey;

@property (nonatomic, weak) id<KS3DownloadDelegate> delegate;


@property (strong, nonatomic) NSString *bucketName;

@property (strong, nonatomic) NSString *key;

@property (nonatomic, assign) BOOL overwrite;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSString *filePath;

@property (strong, nonatomic) NSString *httpMethod;

@property (strong, nonatomic) NSString *contentMd5;

@property (strong, nonatomic) NSString *contentType;

@property (strong, nonatomic) NSString *kSYHeader;

@property (strong, nonatomic) NSString *kSYResource;

@property (nonatomic, strong) NSString *strKS3Token;

@property (strong, nonatomic) NSDate *requestDate;

@property (strong, nonatomic) NSString *strDate;

@property NSTimeInterval timeoutInterval;

@property (nonatomic, readonly) unsigned long long fileSize;

@property (copy, nonatomic) KSS3DownloadProgressChangeBlock downloadProgressChangeBlock;

@property (copy, nonatomic) KSS3DownloadFailedBlock failedBlock;

@property (copy, nonatomic) kSS3DownloadFileCompleteionBlock downloadFileCompleteionBlock;

@property (copy, nonatomic) KSS3DownloadBeginBlock downloadBeginBlock;

- (void)start;


- (void)stop;


- (void)stopAndClear;

- (void)setStrKS3Token:(NSString *)ks3Token;

@end

@protocol KS3DownloadDelegate<NSObject>

- (void)downloadBegin:(KS3DownLoad *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders;

- (void)downloadFaild:(KS3DownLoad *)aDownload didFailWithError:(NSError *)error;

- (void)downloadFinished:(KS3DownLoad *)aDownload filePath:(NSString *)filePath;

- (void)downloadProgressChange:(KS3DownLoad *)aDownload progress:(double)newProgress;

@end
