//
//  KSYMCEditorViewController.h
//  multicanvas
//
//  Created by sunyazhou on 2017/12/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYCanvasModel.h"
@class KSYMCEditorViewController;
@protocol KSYMCEditorVCDelegate <NSObject>

@optional

/**
 代理的回调用于决定是否是编辑完合成完成的返回

 @param editorVC 编辑控制器
 @param isEditDone flag 标识是否正常编辑完成
 */
- (void)editorVC:(KSYMCEditorViewController *)editorVC
      isEditDone:(BOOL)isEditDone;


/**
 修改完之后的模型

 @param editorVC 编辑控制器
 @param url 合成完成之后的 URL
 @param model 修改完的 model
 */
- (void)editorVC:(KSYMCEditorViewController *)editorVC
     concatorURL:(NSURL *)url
     canvasModel:(KSYCanvasModel *)model;


/**
 代理需要告知目前已经录制多少 url 了

 @return 已录制好的URL数组
 */
- (NSArray *)allRecordedURLs;

@end

@interface KSYMCEditorViewController : UIViewController

@property (nonatomic, strong) NSURL                 *recordedURL;
@property (nonatomic, strong) KSYCanvasModel        *model;
@property (nonatomic, assign) CGRect                layoutFrame;
@property (nonatomic, weak  ) id <KSYMCEditorVCDelegate> delegate;

@end
