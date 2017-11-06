//
//  KSYAuth.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYDefines.h"

@interface KSYMEAuth : NSObject

/**
 @abstract 短视频SDK鉴权函数
 
 @param token 联系商务获取
 @param complete 鉴权结果
 */
+ (void)sendClipSDKAuthRequestWithToken:(NSString *)token
                               complete:(void (^)(KSYStatusCode rc, NSError *error))complete;
@end
