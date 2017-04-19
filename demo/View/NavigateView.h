//
//  NavigateView.h
//  demo
//
//  Created by 张俊 on 08/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigateView : UIView


@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, copy) void (^onEvent)(int idx, int extra);

@end
