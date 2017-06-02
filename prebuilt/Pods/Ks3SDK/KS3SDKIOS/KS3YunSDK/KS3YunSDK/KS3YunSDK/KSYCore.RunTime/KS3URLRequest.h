//
//  KingSoftURLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Credentials.h"

@interface KS3URLRequest : NSMutableURLRequest
@property (weak, nonatomic) KS3Credentials *credentials;
@end
