//
//  FilterView.h
//  
//
//  Created by ksyun on 17/4/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libksygpulive/libksygpufilter.h>

@protocol FilterViewDelegate <NSObject>

- (void)specialEffectFilterChanged:(int) effectIndex;

@end


@interface FilterView : UIView

@property (nonatomic, weak) id <FilterViewDelegate>delegate;

@end
