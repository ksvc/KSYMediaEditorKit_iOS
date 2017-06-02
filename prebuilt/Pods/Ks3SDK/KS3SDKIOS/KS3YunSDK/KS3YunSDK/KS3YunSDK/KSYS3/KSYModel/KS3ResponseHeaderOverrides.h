//
//  KSS3ResponseHeaderOverrides.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3ResponseHeaderOverrides : NSObject

@property (nonatomic, strong) NSString *contentType;

@property (nonatomic, strong) NSString *contentLanguage;

@property (nonatomic, strong) NSString *expires;

@property (nonatomic, strong) NSString *cacheControl;

@property (nonatomic, strong) NSString *contentDisposition;

@property (nonatomic, strong) NSString *contentEncoding;

@property (nonatomic, assign) NSString *queryString;

@end
