//
//  KingSoftSDKUtil.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const KSYS3DefaultRunLoopMode;
@interface KS3SDKUtil : NSObject
NSDate* getCurrentDate();
+(NSString *)base64md5FromData:(NSData *)data;
+(NSString *)urlEncode:(NSString *)input;
+ (NSString *)applicationDocumentFilePath;
+ (BOOL)isIpString:(NSString *)aString;
+ (BOOL)isVaildBucketName:(NSString *)bucket;
@end

@interface NSData (WithBase64)

/**
 * Return a base64 encoded representation of the data.
 *
 * @return base64 encoded representation of the data.
 */
-(NSString *) base64EncodedString;

/**
 * Decode a base-64 encoded string into a new NSData object.
 *
 * @param encodedString an base-64 encoded string
 *
 * @return NSData with the data represented by the encoded string.
 */
+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString;


@end
@interface NSString (Md5)
- (NSString *) MD5Hash ;
@end