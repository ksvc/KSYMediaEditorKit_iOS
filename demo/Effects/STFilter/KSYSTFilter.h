//
//  KSYSTFilterThree.h
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/1/16.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "senseAr.h"

@interface KSYSTFilter : GPUImageOutput<GPUImageInput>

//初始化appid
-(id)initWithAppid:(NSString *)appID
            appKey:(NSString *)appKey;

//获取资源列表，完成回调下载数量
@property(nonatomic, copy) void(^fetchListFinishCallback)();

//选择该资源，通过下载列表的
- (void)changeSticker:(int) index
            onSuccess:(void (^)(SenseArMaterial *))completeSuccess
            onFailure:(void (^)(SenseArMaterial *, int, NSString *))completeFailure
           onProgress:(void (^)(SenseArMaterial *, float, int64_t))processingCallBack;

//如果资源没有下载，需要在success回调里显式回调
- (void)startShowingMaterial;

//检测素材是否下载完成
- (BOOL)isDownloadComplete:(SenseArMaterial *)stickers;
//下载素材
- (void)download:(SenseArMaterial *)material onSuccess:(void (^)(SenseArMaterial *))completeSuccess
       onFailure:(void (^)(SenseArMaterial *, int, NSString *))completeFailure
      onProgress:(void (^)(SenseArMaterial *, float, int64_t))processingCallBack;

//贴纸数组
@property (nonatomic , readwrite) NSMutableArray  *arrStickers;

//打开贴纸
@property(nonatomic, assign) int enableSticker;

//打开美颜
@property(nonatomic, assign) BOOL enableBeauty;

@end
