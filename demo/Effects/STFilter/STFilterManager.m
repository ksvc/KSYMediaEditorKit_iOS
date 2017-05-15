//
//  LoginManager.m
//  Nemo
//
//  Created by iVermisseDich on 16/11/24.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import "STFilterManager.h"

@interface STFilterManager ()

@end

@implementation STFilterManager

+ (instancetype)instance{
    static STFilterManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STFilterManager alloc] init];
    });
    return instance;
}

- (void)fetchMaterialList{
    _ksySTFitler = [[KSYSTFilter alloc]initWithAppid:AppID appKey:AppKey];
    _ksySTFitler.fetchListFinishCallback=^(){
    };
    
}

-(NSInteger)STMaterialCount{
    return (NSInteger)_ksySTFitler.arrStickers.count;
}

-(SenseArMaterial *)materialAtIndex:(NSInteger)index{
    return _ksySTFitler.arrStickers[index];
}

@end
