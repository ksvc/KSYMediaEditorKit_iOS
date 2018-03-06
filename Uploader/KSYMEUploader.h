//
//  KSYMEUploder.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/7/5.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSYMediaEditorUploadDelegate;


@interface KSYMEUploader : NSObject

@property (nonatomic, weak) id<KSYMediaEditorUploadDelegate> delegate;

- (instancetype)initWithFilePath:(NSString *)path;

/**
 @abstract ks3 上传参数
 @param params 参数字典
     包括下面的key
     KSYUploadBucketName 必填
     KSYUploadObjKey     必填
     KSYUploadDomain     可选
 @param uploadParamblock 参数回调
     1.params回调一组参数(包括HttpMethod、ContentType、Resource、Headers、ContentMd5)，客户使用这些参数从自己的服务器计算ks3上传的token及Date信息
     2.uploadParamblock块的第二个参数也是一个block，用于客户设置token及Date
             更具体的参考KSYDefines.h中的定义
 */

- (void)setUploadParams:(NSDictionary *)params uploadParamblock:(KSYGetUploadParamBlock)uploadParamblock ;

@end



#pragma - mark KSYMediaEditorDelegate Ks3SDK_Upload
@protocol KSYMediaEditorUploadDelegate <NSObject>

/**
 @abstract 上传进度
 @param value from  0-1.0f
 */
- (void)onUploadProgressChanged:(float)value;

/**
 @abstract 上传ks3完成
 */
- (void)onUploadFinish;

/**
 @abstract KSYMediaEditor 内部的错误回调
 @param err      错误码
 @param extraStr extraStr
 */
- (void)onUploadError:(KSYStatusCode)err  extraStr:(NSString*)extraStr;

@end
