//
//  FilterView.h
//  
//
//  Created by ksyun on 17/4/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StickerViewDelegate <NSObject>

- (void)StickerChanged:(int) StickerIndex;

@end


@interface StickerView : UIView

@property (nonatomic, weak) id <StickerViewDelegate>delegate;

@end
