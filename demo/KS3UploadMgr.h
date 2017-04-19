//
//  KS3UploadMgr.h
//  demo
//
//  Created by 张俊 on 10/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KS3UploadMgr;

@protocol KS3UploadMgrDelegate <NSObject>

@optional
//出错回调  
- (void) uploadMgr:(KS3UploadMgr *)mgr  statusCode:(NSInteger)code;

- (void) uploadMgr:(KS3UploadMgr *)mgr progress:(float)progress  err:(NSString *)err;
//

@end

@interface KS3UploadMgr : NSObject

- (void)startUpload;

- (void)pauseUpload;

- (void)resumeUpload;

//上传前必须设置

//文件地址
@property (nonatomic, strong)NSString *path;

@property (nonatomic, strong)NSString *bucketName;

@property (nonatomic, strong)NSString *objKey;

@property (nonatomic, strong)NSString *domain;

@property(nonatomic, strong)NSString *strKS3Token;

@property(nonatomic, weak)id<KS3UploadMgrDelegate> delegate;

@end
