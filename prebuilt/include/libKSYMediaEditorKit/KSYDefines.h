//
//  KSYStatusDefine.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#ifndef KSYDefines_h
#define KSYDefines_h
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, KSYStatusCode) {

    KSYRC_OK            = 0,
    /// 无效的appkey
    KSYRC_InvalidKey    = 1,
    /// 鉴权失败
    KSYRC_AuthFailed    = 2,
    /// 输入参数错误
    KSYRC_ParamErr      = 50,
    /// 暂不支持的特性
    KSYRC_NotSupport    = 100,
    
    ///合成失败
    KSYRC_ComposeErr    = 110,
    
    KSYRC_LowMem        = 500,
    KSYRC_DiskNotEnough = 510,
    /// 传入的文件不存在
    KSYRC_FileNotExist  = 511,
    /// 无效的状态，sdk内部正在处理一些任务，调用的时机不正确
    KSYRC_InvalidState  = 900,
    KSYRC_UnknownErr    = 1000
};

/**
    内置美颜支持列表
    warning never use magic number
 */
typedef NS_ENUM(NSUInteger, KSYFilter){
    /// 嫩肤
    KSYFilterBeautifyExt,
    /// 柔肤
    KSYFilterBeautifyPlus,
    /// 白皙
    KSYFilterBeautifyFace,
};

/**
 合成视频编码方式

 - KSYVOut_H264: H264编码
 - KSYVOut_H265: 金山云H265编码方案
 */
typedef NS_ENUM(NSUInteger, KSYVideoOutputType)
{
    KSYVOut_H264,
    KSYVOut_H265,
};

typedef NS_ENUM(NSInteger, KSYThumbnailGenResult)
{
    ///生成截图成功
    KSYThumbnailGenSucceeded,
    ///生成截图失败
    KSYThumbnailGenFailed,
    KSYThumbnailGenCancelled,
};


/// 输出视频的编码格式
FOUNDATION_EXPORT NSString *const KSYVideoOutputCodec;
/// 输出视频的宽
FOUNDATION_EXPORT NSString *const kSYVideoOutputWidth;
/// 输出视频的高
FOUNDATION_EXPORT NSString *const kSYVideoOutputHeight;
/// 输出视频的视频频码率
FOUNDATION_EXPORT NSString *const KSYVideoOutputVideoBitrate;
/// 输出视频的帧率
FOUNDATION_EXPORT NSString *const KSYVideoOutputFramerate;
/// 输出视频的音频码率
FOUNDATION_EXPORT NSString *const KSYVideoOutputAudioBitrate;

///截图相关参数
FOUNDATION_EXPORT NSString *const KSYThumbnailWith;

FOUNDATION_EXPORT NSString *const KSYThumbnailHeight;

/**
 *  KS3参数相关key
 */

/// KS3上传bucket 名字，从ks3获取
FOUNDATION_EXPORT NSString *const KSYUploadBucketName;

/// ks3上传的Objkey，用户生成
FOUNDATION_EXPORT NSString *const KSYUploadObjKey;

/// 用户上传文件需要的token，通过用户服务端计算获取
FOUNDATION_EXPORT NSString *const KSYUploadToken;

/**
 上传的Region,默认是北京
   Region
 中国（北京）	        ks3-cn-beijing.ksyun.com
 美国（圣克拉拉）	    ks3-us-west-1.ksyun.com
 中国（香港）	        ks3-cn-hk-1.ksyun.com
 
 */
FOUNDATION_EXPORT NSString *const KSYUploadDomain;


/**
 *  block define, ks3 相关回调
 */
typedef void (^KSYUploadWithTokenBlock)(NSString *token, NSString *strDate);
typedef void (^KSYGetUploadParamBlock)(NSDictionary *params, KSYUploadWithTokenBlock block);


/**
 截图block

 @param requestedTime 请求时间
 @param image 图像
 @param actualTime 真实截取图像的时间点
 @param result 截图结果
 @param error 错误信息
 */
typedef void (^KSYThumbnailGenHandler)(CMTime requestedTime, CGImageRef image, CMTime actualTime, KSYThumbnailGenResult result, NSError *error);

#endif /* KSYDefines_h */
