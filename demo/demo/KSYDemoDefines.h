//
//  KSYDefines.h
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#ifndef KSYDemoDefines_h
#define KSYDemoDefines_h



// size
#define kSCREEN_SIZE [[UIScreen mainScreen] bounds].size
#define kScreenSizeHeight (kSCREEN_SIZE.height)
#define kScreenSizeWidth (kSCREEN_SIZE.width)
#define kScreenMaxLength (MAX(kScreenSizeWidth, kScreenSizeHeight))
#define kScreenMinLength (MIN(kScreenSizeWidth, kScreenSizeHeight))

#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height-812)?NO:YES)

// safe_main_thread
#define dispatch_async_main_safe(block) \
if ([NSThread isMainThread]) \
block \
else \
dispatch_async(dispatch_get_main_queue(), ^{block});


#define WeakSelf(VC)  __weak VC *weakSelf = self

#define UIColorFromRGB(R,G,B)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:1.0]
#define rgba(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]

typedef NS_ENUM(NSInteger, KSYMEFilterType){
    KSYMEFilterTypeBeautyFilter = 0,//美颜
    KSYMEFilterTypeFaceSticker  = 1,//人脸贴纸
    KSYMEFilterTypeEffectFilter = 2 //特效滤镜
};


typedef NS_ENUM(NSInteger, KSYMEBeautyKindType){
    KSYMEBeautyKindTypeOrigin = 0,//原图
    KSYMEBeautyKindTypZiran   = 1,//自然
    KSYMEBeautyKindTypeWeimei = 2,//唯美
    KSYMEBeautyKindTypeHuayan = 3,//花颜
    KSYMEBeautyKindTypeFennen = 4,//粉嫩
};

typedef NS_ENUM(NSInteger, KSYMEAudioVolumnType){
    KSYMEAudioVolumnTypeMicphone = 0, //处理麦克风音量
    KSYMEAudioVolumnTypeBgm = 1       //处理背景音乐音量
};
typedef NS_ENUM(NSInteger, KSYMEAudioEffectType){
    KSYMEAudioEffectTypeChangeTone   = 0,//变调
    KSYMEAudioEffectTypeChangeVoice  = 1,//变声
    KSYMEAudioEffectTypeChangeReverb = 2//混响
};

typedef NS_ENUM(NSInteger, KSYMEEditStickerType){
    KSYMEEditStickerTypeSticker       = 0,//贴纸
    KSYMEEditStickerTypeSubtitle      = 1,//字幕
    KSYMEEditStickerTypeAnimatedImage = 2,//动态贴纸
    KSYMEEditStickerTypeMV            = 3 //MV
};

typedef NS_ENUM(NSInteger, KSYMEEditTrimType){
    KSYMEEditTrimTypeVideo = 0, //视频裁剪
    KSYMEEditTrimTypeAudio = 1  //音频裁剪
};

// 编辑 resize 的比例
typedef NS_ENUM(NSInteger, KSYMEResizeRatio){
    KSYMEResizeRatio_9_16 = 0,  // 9:16
    KSYMEResizeRatio_3_4,       // 3:4
    KSYMEResizeRatio_1_1        // 1:1
};

/**
 *  block define, ks3 相关回调
 */
typedef void (^KSYUploadWithTokenBlock)(NSString *token, NSString *strDate);
typedef void (^KSYGetUploadParamBlock)(NSDictionary *params, KSYUploadWithTokenBlock block);

//ks3 上传参数
#define KSYUploadBucketName        @"KSYUploadBucketName"
#define KSYUploadObjKey            @"KSYUploadObjKey"
#define KSYUploadToken             @"KSYUploadToken"
#define KSYUploadDomain            @"KSYUploadDomain"

//所有通知的 key 都放这里

#define kMVSelectedNotificationKey @"MVSelectedNotificationKey"


#endif /* KSYDemoDefines_h */
