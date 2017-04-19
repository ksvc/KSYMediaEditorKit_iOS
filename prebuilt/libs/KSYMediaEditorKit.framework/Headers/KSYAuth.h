//
//  KSYAuth.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYDefines.h"

@interface KSYAuth : NSObject

/**
 *  短视频SDK鉴权函数，异步函数
 *
 *  @param accessKey  联系商务获取
 *  @param complete   鉴权结果
 */
+ (void)sendClipSDKAuthRequestWithAccessKey:(NSString *)accessKey
                                    amzDate:(NSString *)amzDate
                                   complete:(void (^)(KSYStatusCode rc, NSError *error))complete;

@end
