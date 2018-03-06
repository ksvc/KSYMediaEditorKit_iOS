//
//  KS3UploadMgr.h
//  demo
//
//  Created by iVermisseDich on 10/04/2017.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, KSYUploadMethod){
    kUploadSingle,
    kUploadMulti,   //分片上传
};

@class KS3UploadMgr;

@protocol KS3UploadMgrDelegate <NSObject>

@optional
//出错回调

- (void) uploadFinish;

- (void) uploadMgr:(KS3UploadMgr *)mgr  errStr:(NSString *)error;

- (void) uploadMgr:(KS3UploadMgr *)mgr progress:(float)progress;
//

@end

@interface KS3UploadMgr : NSObject


- (instancetype)initWithUploadType:(KSYUploadMethod) type;

- (NSDictionary *)calUploadheaderWithParams:(NSDictionary *)params;

- (void)startUpload;

- (void)pauseUpload;

- (void)resumeUpload;

//上传前必须设置

//文件地址
@property (nonatomic, strong)NSString *path;

@property (nonatomic, strong)NSString *bucketName;

@property (nonatomic, strong)NSString *objKey;

@property (nonatomic, strong)NSString *domain;

@property (nonatomic, strong)NSString *strKS3Token;

@property (nonatomic, strong)NSString *strDate;

@property (nonatomic, strong)NSDictionary *uploadHeader;

@property(nonatomic, weak)id<KS3UploadMgrDelegate> delegate;

@end
