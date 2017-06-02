//
//  KSS3ListObjectsXMLPrarser.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KS3ListObjectsResult;
@interface KS3ListObjectsXMLPrarser : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic) KS3ListObjectsResult *listBuctkResult;
- (void)kSS3XMLarse:(NSData *)dataXml;



@end
