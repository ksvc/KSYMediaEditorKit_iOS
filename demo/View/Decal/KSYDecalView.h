//
//  KSYDecalView.h
//  demo
//
//  Created by iVermisseDich on 2017/5/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYDecalView : UIImageView

// 选中后出现边框
@property (nonatomic, assign, getter=isSelected) BOOL select;

@property (nonatomic, assign) CGFloat oriScale;
@property (nonatomic, assign) CGAffineTransform oriTransform;


@property (nonatomic) UIButton *closeBtn;
@property (nonatomic) UIImageView *dragBtn;

- (void)close:(id)sender;

@end
