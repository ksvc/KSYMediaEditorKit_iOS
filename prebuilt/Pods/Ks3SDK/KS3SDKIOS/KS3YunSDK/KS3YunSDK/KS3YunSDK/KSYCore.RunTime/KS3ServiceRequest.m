//
//  KingSoftServiceRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ServiceRequest.h"
#import "KS3AuthUtils.h"
#import "KS3ClientException.h"

@implementation KS3ServiceRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentMd5 = @"";
        _contentType = @"";
        _kSYHeader = @"";
        _kSYResource = @"";
        _host = @"";
        _requestDate = [NSDate date];
        _strDate = [KS3AuthUtils strDateWithDate:_requestDate andType:@"GMT"];
        
        _strKS3Token = nil;
        _urlRequest = [KS3URLRequest new];}
    return self;
}

- (void)setCompleteRequest
{
    
}
- (void)sign
{
    [KS3AuthUtils signRequestV4:self urlRequest:_urlRequest headers:nil payload:nil credentials:_credentials];
}

- (KS3URLRequest *)configureURLRequest
{
    [self sign];
    return _urlRequest;
    
}

- (KS3ClientException *)validate
{
    return nil;
}
- (void)cancel
{
    [self.urlConnection cancel];
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
    output = [[output stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"] mutableCopy];
    output = [[output stringByReplacingOccurrencesOfString:@"+" withString:@"%20"] mutableCopy];
    output = [[output stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"] mutableCopy];
    output = [[output stringByReplacingOccurrencesOfString:@"%7E" withString:@"~"] mutableCopy];
    
    return output;
    
}

@end
