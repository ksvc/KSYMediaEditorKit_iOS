//
//  LoginManager.h
//  Nemo
//
//  Created by iVermisseDich on 16/11/24.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYSTFilter.h"
#import "senseAr.h"


@interface STFilterManager : NSObject

+ (instancetype)instance;

- (void)fetchMaterialList;

-(NSInteger)STMaterialCount;

-(SenseArMaterial *)materialAtIndex:(NSInteger)index;

@property (nonatomic, strong) KSYSTFilter * ksySTFitler; //贴纸filter

@end
