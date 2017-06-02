//
//  KS3BucketNameUtilities.m
//  KS3YunSDK
//
//  Created by JackWong on 12/23/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3BucketNameUtilities.h"
#import "KS3ClientException.h"
#import <ctype.h>
#import "KS3SDKUtil.h"
@implementation KS3BucketNameUtilities
+(KS3ClientException *)validateBucketName:(NSString *)theBucketName
{
    if (theBucketName == nil) {
        return [KS3ClientException exceptionWithMessage : @"Bucket name should not be nil."];
    }
    
    if ( [theBucketName length] < 3 || [theBucketName length] > 255) {
        return [KS3ClientException exceptionWithMessage : @"Bucket name should be between 3 and 255 characters in length."];
    }
    if ([KS3SDKUtil isVaildBucketName:theBucketName]) {
       return [KS3ClientException exceptionWithMessage : @"Bucket name 只能包含小写英文字母（a-z），数字，点（.），中线."];
    }
    
    if ( [theBucketName hasPrefix:@"kss"]) {
        return [KS3ClientException exceptionWithMessage : @"Bucket name should not start with a 'kss'."];
    }
    if ([theBucketName hasPrefix:@"."]) {
        return [KS3ClientException exceptionWithMessage : @"Bucket name should not start with a '.'."];
    }
    if ([theBucketName hasPrefix:@"-"]) {
        return [KS3ClientException exceptionWithMessage : @"Bucket name should not start with a '-'."];
    }
    if ([KS3SDKUtil isIpString:theBucketName]) {
        return [KS3ClientException exceptionWithMessage : @"Bucket name should not be a IP"];
    }
    
//    if ( [KS3BucketNameUtilities contains:theBucketName searchString:@".."]) {
//        return [KS3ClientException exceptionWithMessage : @"Bucket name should not contain two adjacent periods."];
//    }
//    
//    if ( [KS3BucketNameUtilities contains:theBucketName searchString:@"_"]) {
//        return [KS3ClientException exceptionWithMessage : @"Bucket name should not contain '_'."];
//    }
//    
//    if ( [KS3BucketNameUtilities contains:theBucketName searchString:@"-."] ||
//        [KS3BucketNameUtilities contains:theBucketName searchString:@".-"]) {
//        return [KS3ClientException exceptionWithMessage : @"Bucket name should not contain dashes next to periods."];
//    }
//    
//    if ( [[theBucketName lowercaseString] isEqualToString:theBucketName] == NO) {
//        return [KS3ClientException exceptionWithMessage : @"Bucket name should not contain upper case characters."];
//    }
    
    return nil;

    
}
+ (bool)isDNSBucketName:(NSString *)theBucketName;
{
    if (theBucketName == nil) {
        return NO;
    }
    
    if ( [theBucketName length] < 3 || [theBucketName length] > 255) {
        return NO;
    }
    
    if ( [theBucketName hasPrefix:@"-"]) {
        return NO;
    }
//    
//    if ( [KS3BucketNameUtilities contains:theBucketName searchString:@"_"]) {
//        return NO;
//    }
//    
//    if ( [KS3BucketNameUtilities contains:theBucketName searchString:@"."]) {
//        return NO;
//    }
//    
//    if ( [KS3BucketNameUtilities contains:theBucketName searchString:@"-."] ||
//        [KS3BucketNameUtilities contains:theBucketName searchString:@".-"]) {
//        return NO;
//    }
//    
//    if ( [[theBucketName lowercaseString] isEqualToString:theBucketName] == NO) {
//        return NO;
//    }
    
    return YES;
}

+(bool)contains:(NSString *)sourceString searchString:(NSString *)searchString
{
    NSRange range = [sourceString rangeOfString:searchString];
    
    return (range.location != NSNotFound);
}

@end
