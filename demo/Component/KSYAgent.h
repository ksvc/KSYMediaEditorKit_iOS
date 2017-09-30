//
//  KSYAgent.h
//  demo
//
//  Created by sunyazhou on 2017/9/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//  这个类主要功能类似 helper 目前只有文件的一些简单操作 由于 VC 的代码比较多一些不必要的代码放在了这里

#import <Foundation/Foundation.h>

typedef void (^KSYAgentFail)(NSError * error);
typedef void (^KSYAgentComplete)(NSString * mvFilePath,NSString *configFilePath);

typedef NS_ENUM(NSUInteger, KSYAgentError){
    KSYAgentErrorOK                 = 0,//OK没问题
    KSYAgentErrorFileNameNil        = 1,//文件名不能为空
    KSYAgentErrorUnzipFail          = 2,//解压失败
    KSYAgentErrorCopyOrCreateFailed = 3,//copy 或创建目录失败
    KSYAgentErrorFileNotExist = 4       //文件不存在
};

@interface KSYAgent : NSObject

/**
 拷贝资源到沙盒

 @param fileName mv 资源包名称(必须zip 格式)
 @param complete 完成回调
 @param failedBlock 错误回调
 */
- (void)copyMVFiletoSandBox:(NSString *)fileName
              completeBlock:(KSYAgentComplete)complete
                failedBlock:(KSYAgentFail)failedBlock;


/**
 解析 json

 @param filePath 文件路径
 @return 返回解析完的数据结构
 */
- (NSDictionary *)parseJsonByPath:(NSString *)filePath;
@end
