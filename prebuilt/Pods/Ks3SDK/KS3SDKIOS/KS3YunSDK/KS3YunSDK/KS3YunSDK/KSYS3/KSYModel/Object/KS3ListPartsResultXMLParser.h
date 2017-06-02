//
//  KSS3ListPartsResultXMLParser.h
//  KS3SDK
//
//  Created by JackWong on 12/16/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3ListPartsResult.h"

@interface KS3ListPartsResultXMLParser : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) KS3ListPartsResult *listPartsResult;

- (void)kSS3XMLarse:(NSData *)dataXml;

@end
