//
//  KSS3Part.h
//  KS3SDK
//
//  Created by JackWong on 12/16/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3Part : NSObject


@property (strong, nonatomic) NSString *etag;


@property (strong, nonatomic) NSString *lastModified;


@property (nonatomic, assign) int32_t partNumber;


@property (nonatomic, assign) long long size;

@end
