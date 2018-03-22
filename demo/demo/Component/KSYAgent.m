//
//  KSYAgent.m
//  demo
//
//  Created by sunyazhou on 2017/9/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYAgent.h"
#import <ZipArchive/ZipArchive.h>

static NSString *const mvResPath = @"mvRes";
static NSString *const configName = @"config.json";
static NSString *const fileType = @"zip";

@interface KSYAgent ()
@property (nonatomic, strong) ZipArchive *zip;
@end

@implementation KSYAgent



- (void)copyMVFiletoSandBox:(NSString *)fileName
              completeBlock:(KSYAgentComplete)complete
                failedBlock:(KSYAgentFail)failedBlock
{
    
    //check file nil
    if (fileName == nil) {
        [self createError:KSYAgentErrorFileNameNil andInfo:@"传入的mv主题名称不能为 nil"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        // 获取Documents目录路径
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *bundleIDPath = [docDir stringByAppendingPathComponent:bundleID];
        //资源根路径
        NSString *resPath = [bundleIDPath stringByAppendingPathComponent:mvResPath];
        //mv 文件路径
        NSString *mvFilePath = [resPath stringByAppendingPathComponent:fileName];
        __block NSError *error = nil;
        if (![fm fileExistsAtPath:mvFilePath isDirectory:nil]) {
            [fm createDirectoryAtPath:mvFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString *src  = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        if (![fm fileExistsAtPath:src]) {
            NSString *errorInfo = [NSString stringWithFormat:@"工程目录没有可拷贝的资源:%@",fileName];
            error = [self createError:KSYAgentErrorFileNotExist andInfo:errorInfo];
        }
        NSString *desrc = [resPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,fileType]];
        NSString *jsonConfig = [mvFilePath stringByAppendingPathComponent:configName];
        
        BOOL exist = [fm fileExistsAtPath:jsonConfig];
        NSString *md5 = [[NSUserDefaults standardUserDefaults] valueForKey:fileName];
        NSString *fileMD5 = nil;
        if ([fm fileExistsAtPath:src]) {
            YYFileHash *hash = [YYFileHash hashForFile:src types:YYFileHashTypeMD5];
            fileMD5 = hash.md5String;
        }
        
        if (!exist || (fileMD5.length > 0 && ![fileMD5 isEqualToString:md5])) {
            if (exist) {
                [fm removeItemAtPath:mvFilePath error:&error];
                //保存 config文件的 md5
                [[NSUserDefaults standardUserDefaults] setValue:fileMD5 forKey:fileName];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else if (fileMD5.length > 0){
                //保存 config文件的 md5
                [[NSUserDefaults standardUserDefaults] setValue:fileMD5 forKey:fileName];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            if (error == nil &&
                ![fm fileExistsAtPath:desrc] &&
                [fm fileExistsAtPath:src]) {
                [fm copyItemAtPath:src toPath:desrc error:&error];
            }
            if (self.zip == nil) {
                self.zip = [[ZipArchive alloc] initWithFileManager:fm];
            }
            
            if ([self.zip UnzipOpenFile:desrc]) {
                BOOL ret = [self.zip UnzipFileTo:resPath overWrite:YES];
                if(!ret)
                {
                    NSLog(@"解压不成功");
                }
                [self.zip UnzipCloseFile];
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil){
                    //成功之后移出 zip
                    if ([fm fileExistsAtPath:desrc]) {
                        [fm removeItemAtPath:desrc error:&error];
                    }
                    if (complete) {
                        complete(mvFilePath,jsonConfig);
                    }
                } else {
                    //出错之后直接移出
                    [fm removeItemAtPath:mvFilePath error:&error];
                    if (failedBlock) {
                        NSError *failedError = [self createError:KSYAgentErrorCopyOrCreateFailed andInfo:[NSString stringWithFormat:@"创建路径/copy失败:%@",error]];
                        failedBlock(failedError);
                    }
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil){
                    if (complete) {
                        complete(mvFilePath,jsonConfig);
                    }
                } else {
                    //出错之后直接移出
                    [fm removeItemAtPath:mvFilePath error:&error];
                    if (failedBlock) {
                        NSError *failedError = [self createError:KSYAgentErrorCopyOrCreateFailed andInfo:[NSString stringWithFormat:@"创建路径/copy失败:%@",error]];
                        failedBlock(failedError);
                    }
                }                
            });
        }
    });
    
}


/**
 快速创建错误方法

 @param code 错误码
 @param info 错误提示信息
 @return 返回错误实例
 */
- (NSError *)createError:(NSInteger)code andInfo:(NSString *)info{
    NSDictionary * uInfo = @{NSLocalizedDescriptionKey:info};
    NSError *err = NULL;
    err = [[NSError alloc] initWithDomain:@""
                                     code:code
                                 userInfo:uInfo];
    return err;
}

- (NSDictionary *)parseJsonByPath:(NSString *)filePath{
    if (filePath.length == 0) { return nil; }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data == nil) { return nil; }
    NSDictionary *theme = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return theme;
}
@end
