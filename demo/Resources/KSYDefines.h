//
//  KSYDefines.h
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#ifndef KSYDefines_h
#define KSYDefines_h



// size
#define kSCREEN_SIZE [[UIScreen mainScreen] bounds].size
#define kScreenSizeHeight (kSCREEN_SIZE.height)
#define kScreenSizeWidth (kSCREEN_SIZE.width)
#define kScreenMaxLength (MAX(kScreenSizeWidth, kScreenSizeHeight))
#define kScreenMinLength (MIN(kScreenSizeWidth, kScreenSizeHeight))


// safe_main_thread
#define dispatch_main_async_safe(block) \
if ([NSThread isMainThread]) \
block(); \
else \
dispatch_async(dispatch_get_main_queue(), block);\

#define WeakSelf(VC)  __weak VC *weakSelf = self

typedef NS_ENUM(NSInteger, KSYMEFilterType){
    KSYMEFilterTypeBeautyFilter = 0, //美颜
    KSYMEFilterTypeFaceSticker = 1, //人脸贴纸
    KSYMEFilterTypeEffectFilter = 2 //特效滤镜
};


typedef NS_ENUM(NSInteger, KSYMEBeautyKindType){
    KSYMEBeautyKindTypeFaceWhiten = 0, //美白
    KSYMEBeautyKindTypeGrind = 1,   //磨皮
    KSYMEBeautyKindTypeRuddy = 2      //红润
};

typedef NS_ENUM(NSInteger, KSYMEAudioVolumnType){
    KSYMEAudioVolumnTypeMicphone = 0, //处理麦克风音量
    KSYMEAudioVolumnTypeBgm = 1       //处理背景音乐音量
};
typedef NS_ENUM(NSInteger, KSYMEAudioEffectType){
    KSYMEAudioEffectTypeChangeTone = 0, //变调
    KSYMEAudioEffectTypeChangeVoice= 1, //变声
    KSYMEAudioEffectTypeChangeReverb= 2 //混响
};

typedef NS_ENUM(NSInteger, KSYMEEditStickerType){
    KSYMEEditStickerTypeSticker = 0, //贴纸
    KSYMEEditStickerTypeSubtitle = 1  //字幕
};


#endif /* KSYDefines_h */
