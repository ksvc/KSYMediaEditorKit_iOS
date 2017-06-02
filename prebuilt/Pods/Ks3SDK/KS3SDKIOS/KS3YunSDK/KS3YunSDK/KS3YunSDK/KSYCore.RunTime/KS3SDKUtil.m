//
//  KingSoftSDKUtil.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3SDKUtil.h"
//#import "RegexKitLite.h"
#import <CommonCrypto/CommonDigest.h>
static char        base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static const short base64DecodingTable[] =
{
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};
NSString *const KSYS3DefaultRunLoopMode = @"com.ksyun.DefaultRunLoopMode";
@implementation KS3SDKUtil
NSDate* getCurrentDate()
{
    return [NSDate date];
}
+(NSString *)base64md5FromData:(NSData *)data
{
   
    
    const void    *cStr = [data bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (uint32_t)[data length], result);
    
    NSData *md5 = [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return [md5 base64EncodedString];
}
+(NSString *)urlEncode:(NSString *)input
{
    NSString *encoded = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)input, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8));
    return encoded;
}
+ (NSString *)applicationDocumentFilePath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return documentPaths[0];
}

+ (BOOL)isIpString:(NSString *)aString
{
    NSString *regex = @"(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:aString];
    return isMatch;

//    NSString *regex = @"(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])";
//    return [aString isMatchedByRegex:regex];
}

+ (BOOL)isVaildBucketName:(NSString *)bucket
{
    NSString *strReg5 = @"^[a-z0-9-.]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strReg5];
    BOOL isMatch = [pred evaluateWithObject:bucket];
    return !isMatch;

//    NSString *strReg5 = @"^[a-z0-9-.]+$";
//    return  ![bucket isMatchedByRegex:strReg5];
}
@end

@implementation NSData (WithBase64)

-(NSString *) base64EncodedString
{
    NSMutableString *result;
    unsigned char   *raw;
    unsigned long   length;
    short           i, nCharsToWrite;
    long            cursor;
    unsigned char   inbytes[3], outbytes[4];
    
    length = [self length];
    
    if (length < 1) {
        return @"";
    }
    
    result = [NSMutableString stringWithCapacity:length];
    raw    = (unsigned char *)[self bytes];
    // Take 3 chars at a time, and encode to 4
    for (cursor = 0; cursor < length; cursor += 3) {
        for (i = 0; i < 3; i++) {
            if (cursor + i < length) {
                inbytes[i] = raw[cursor + i];
            }
            else{
                inbytes[i] = 0;
            }
        }
        
        outbytes[0] = (inbytes[0] & 0xFC) >> 2;
        outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
        outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
        outbytes[3] = inbytes[2] & 0x3F;
        
        nCharsToWrite = 4;
        
        switch (length - cursor) {
            case 1:
                nCharsToWrite = 2;
                break;
                
            case 2:
                nCharsToWrite = 3;
                break;
        }
        for (i = 0; i < nCharsToWrite; i++) {
            [result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
        }
        for (i = nCharsToWrite; i < 4; i++) {
            [result appendString:@"="];
        }
    }
    
    return [NSString stringWithString:result]; // convert to immutable string
}

+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString
{
    if (nil == encodedString || [encodedString length] < 1) {
        return [NSData data];
    }
    
    const char    *inputPtr;
    unsigned char *buffer;
    
    NSInteger     length;
    
    inputPtr = [encodedString cStringUsingEncoding:NSASCIIStringEncoding];
    length   = strlen(inputPtr);
    char ch;
    NSInteger inputIdx = 0, outputIdx = 0, padIdx;
    
    buffer = calloc(length, sizeof(unsigned char));
    
    while (((ch = *inputPtr++) != '\0') && (length-- > 0)) {
        if (ch == '=') {
            if (*inputPtr != '=' && ((inputIdx % 4) == 1)) {
                free(buffer);
                return nil;
            }
            continue;
        }
        
        ch = base64DecodingTable[ch];
        
        if (ch < 0) { // whitespace or other invalid character
            continue;
        }
        
        switch (inputIdx % 4) {
            case 0:
                buffer[outputIdx] = ch << 2;
                break;
                
            case 1:
                buffer[outputIdx++] |= ch >> 4;
                buffer[outputIdx]    = (ch & 0x0f) << 4;
                break;
                
            case 2:
                buffer[outputIdx++] |= ch >> 2;
                buffer[outputIdx]    = (ch & 0x03) << 6;
                break;
                
            case 3:
                buffer[outputIdx++] |= ch;
                break;
        }
        
        inputIdx++;
    }
    
    padIdx = outputIdx;
    
    if (ch == '=') {
        switch (inputIdx % 4) {
            case 1:
                free(buffer);
                return nil;
                
            case 2:
                padIdx++;
                
            case 3:
                buffer[padIdx] = 0;
        }
    }
    
    NSData *objData = [[NSData alloc] initWithBytes:buffer length:outputIdx];
    free(buffer);
    return objData;
}



@end
@implementation NSString (Md5)

- (NSString *) MD5Hash {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end


