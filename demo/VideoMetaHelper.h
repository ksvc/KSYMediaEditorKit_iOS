//
//  VideoMetaHelper.h
//  demo
//
//  Created by 张俊 on 17/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoMetaHelper : NSObject
/**
 *  获取本地视频信息
 *
 *  @param path 本地视频地址
 *
 *  @return <#return value description#>
 */
+ (VideoMetaInfo *)videoMetaFrom:(NSString *)path;

@end
