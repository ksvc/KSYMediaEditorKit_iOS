//
//  VideoParamCache.m
//  demo
//
//  Created by 张俊 on 16/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "VideoParamCache.h"


@implementation VideoParams


@end

@implementation VideoParamCache


+(instancetype)sharedInstance
{
    static VideoParamCache *inst = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!inst){
            inst = [[VideoParamCache alloc] init];
            
        }
    });
    return inst;
}

-(VideoParams*) captureParam
{
    if (!_captureParam){
        _captureParam = [[VideoParams alloc] init];
        _captureParam.abps = 96;
        _captureParam.vbps = 4096;
        _captureParam.frame = 30;
        _captureParam.level = k720P;
        _captureParam.codec = KSYVOut_H264;
    }
    return _captureParam;
}

-(VideoParams*) exportParam
{
    if (!_exportParam){
        _exportParam = [[VideoParams alloc] init];
        _exportParam.abps = 96;
        _exportParam.vbps = 4096;
        _exportParam.frame = 30;
        _exportParam.level = k720P;
        _exportParam.codec = KSYVOut_H264;
    }
    return _exportParam;
}

@end
