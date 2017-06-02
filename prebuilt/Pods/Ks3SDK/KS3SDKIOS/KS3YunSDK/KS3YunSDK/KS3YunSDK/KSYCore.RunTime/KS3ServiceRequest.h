//
//  KingSoftServiceRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Credentials.h"
#import "KS3URLRequest.h"
@class KS3ServiceResponse;
@class KS3ClientException;
@protocol  KingSoftServiceRequestDelegate;
@interface KS3ServiceRequest : NSObject
@property (strong, nonatomic) KS3Credentials *credentials;
@property (strong, nonatomic) KS3URLRequest *urlRequest;
@property (strong, nonatomic) NSString *httpMethod;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, readonly, nonatomic) NSURL  *url;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *contentMd5;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *kSYHeader;
@property (strong, nonatomic) NSString *kSYResource;
@property (strong, nonatomic) NSDate *requestDate;
@property (strong, nonatomic) NSString *strDate;
@property (nonatomic, strong) NSString *strKS3Token;
@property NSTimeInterval timeoutInterval;
@property (weak, nonatomic) id<KingSoftServiceRequestDelegate> delegate;

- (KS3URLRequest *)configureURLRequest;
- (void)sign;
- (KS3ClientException *)validate;
- (void)cancel;
- (NSString *)URLEncodedString:(NSString *)str;
- (void)setCompleteRequest;
@end

@protocol KingSoftServiceRequestDelegate <NSObject>

@optional


-(void)request:(KS3ServiceRequest *)request didReceiveResponse:(NSURLResponse *)response;


-(void)request:(KS3ServiceRequest *)request didReceiveData:(NSData *)data;



-(void)request:(KS3ServiceRequest *)request didCompleteWithResponse:(KS3ServiceResponse *)response;


-(void)request:(KS3ServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite;


-(void)request:(KS3ServiceRequest *)request didFailWithError:(NSError *)error;


-(void)request:(KS3ServiceRequest *)request didFailWithServiceException:(NSException *)exception __attribute__((deprecated));

@end

