//
//  KSYMediaHelper.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 17/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface VideoMetaInfo : NSObject

@property(nonatomic, assign)CGSize naturalSize;

@property(nonatomic, assign)int degree;

@end

@interface KSYMediaHelper : NSObject
/**
 *  获取本地视频信息
 *
 *  @param path 本地视频地址
 *
 *  @return <#return value description#>
 */
+ (VideoMetaInfo *)videoMetaFrom:(NSString *)path;

@end
