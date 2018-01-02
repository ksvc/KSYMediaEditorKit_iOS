//
//  KSYCanvasCell.h
//  multicanvas
//
//  Created by sunyazhou on 2017/11/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYCanvasModel.h"

static const NSString *KSYModelKVOStatusContext;
static NSString *KSYKeyPathForModelStatus = @"modelStatus";
static NSString *KSYKeyPathForIsSelected = @"isSelected";
@interface KSYCanvasCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *canvasImageView;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boundsView;

@property (nonatomic, strong) KSYCanvasModel *model;

//注册和移除观察接口
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context;
- (void)removeObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath 
               context:(void *)context;

@end
