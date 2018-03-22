//
//  KSYFilterEffectModel.h
//  demo
//
//  Created by sunyazhou on 2017/12/26.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYEffectLineView.h"

@interface KSYFilterEffectModel : NSObject
@property (nonatomic, copy  ) NSString            *imgName;
@property (nonatomic, copy  ) NSString            *effectName;
@property (nonatomic, assign) KSYEffectLineType   filterEffectType;
@property (nonatomic, strong) UIColor             *drawColor;


@end
