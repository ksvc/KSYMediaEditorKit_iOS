//
//  KingSoftMD5Util.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3MD5Util.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

@implementation KS3MD5Util

+ (NSString *)hexEncode:(NSString *)key text:(NSString *)text
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *strHash = @"";
    if ([HMAC respondsToSelector:@selector(base64EncodedDataWithOptions:)]) {
        strHash = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }else {
        strHash = [HMAC base64Encoding];
    }
    
    return strHash;
}

@end
