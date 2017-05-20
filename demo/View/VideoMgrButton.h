//
//  VideoMgrButton.h
//  demo
//
//  Created by 张俊 on 15/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>


enum {
    kLoadfileState = (1 << 16), //导入视频状态
    kDeleteState  = (1 << 17), //删除状态
    kBackSelect    = (1 << 18), //回退状态(回退->删除->导入)
};

@interface VideoMgrButton : UIButton

@property (nonatomic, assign)NSUInteger videoMgrState;

@end




