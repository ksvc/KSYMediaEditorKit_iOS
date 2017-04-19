//
//  KSYStatusDefine.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#ifndef KSYDefines_h
#define KSYDefines_h

typedef NS_ENUM(NSInteger, KSYStatusCode) {
    
    KSYRC_OK            = 0,
    /**
     *  无效的appkey,
     */
    KSYRC_InvalidKey    = 1,
    KSYRC_AuthFailed    = 2,
    KSYRC_ParamErr      = 50,
    KSYRC_NotSupport    = 100,
    
    KSYRC_LowMem        = 500,
    KSYRC_DiskNotEnough = 510,
    KSYRC_FileNotExist  = 511,
    
    KSYRC_InvalidState  = 900,
    KSYRC_UnknownErr    = 1000
};

/**
    内置美颜支持列表
    warning never use magic number
 */

typedef NS_ENUM(NSUInteger, KSYFilter){
    //嫩肤
    KSYFilterBeautifyExt,
    //柔肤
    KSYFilterBeautifyPlus,
    //白皙
    KSYFilterBeautifyFace,
};


typedef NS_ENUM(NSUInteger, KSYVideoOutputType)
{
    KSYVOut_H264,
    KSYVOut_H265,
};

//输出视频的编码格式
FOUNDATION_EXPORT NSString *const KSYVideoOutputCodec;
//输出视频的宽
FOUNDATION_EXPORT NSString *const kSYVideoOutputWidth;
//输出视频的高
FOUNDATION_EXPORT NSString *const kSYVideoOutputHeight;
//输出视频的视频频码率
FOUNDATION_EXPORT NSString *const KSYVideoOutputVideoBitrate;
//输出视频的帧率
FOUNDATION_EXPORT NSString *const KSYVideoOutputFramerate;
//输出视频的音频码率
FOUNDATION_EXPORT NSString *const KSYVideoOutputAudioBitrate;



/**
 *  KS3参数相关key
 */
FOUNDATION_EXPORT NSString *const KSYUploadBucketName;

FOUNDATION_EXPORT NSString *const KSYUploadObjKey;

FOUNDATION_EXPORT NSString *const KSYUploadToken;

FOUNDATION_EXPORT NSString *const KSYUploadDomain;


/**
 *  block define, ks3 相关回调
 */
typedef void (^KSYUploadWithTokenBlock)(NSString *token, NSString *strDate);
typedef void (^KSYGetUploadParamBlock)(NSDictionary *params, KSYUploadWithTokenBlock block);



#endif /* KSYDefines_h */
