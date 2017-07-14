//
//  TrimBgView.h
//  demo
//
//  Created by sunyazhou on 2017/6/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TrimMeidaType){
    TrimMeidaTypeVideo = 0,
    TrimMeidaTypeAudio = 1
};

@class TrimBgView;
@protocol TrimBgProtocol <NSObject>

@optional
- (void)trimBgView:(TrimBgView *)trimBgView clickIndex:(TrimMeidaType)type;

@end

@interface TrimBgView : UIView

@property(nonatomic, weak) id <TrimBgProtocol> delegate;

@end
