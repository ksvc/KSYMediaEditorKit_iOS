//
//  KSYMVView.h
//  demo
//
//  Created by sunyazhou on 2017/9/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSYMVDelegate.h"
@interface KSYMVView : UIView
@property (nonatomic, weak) id <KSYMVDelegate> delegate;
@end
