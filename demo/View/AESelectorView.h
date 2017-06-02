//
//  AESelectorView.h
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEMgrView.h"

@interface AESelectorView : UIView

//0 混响 1.变声
- (instancetype)initWithType:(NSUInteger)type;

@property(nonatomic, strong)AEMgrView *aeView;


@end
