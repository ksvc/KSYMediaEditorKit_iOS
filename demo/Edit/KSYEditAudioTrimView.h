//
//  KSYEditAudioTrimView.h
//  demo
//
//  Created by sunyazhou on 2017/7/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYEditTrimDelegate.h"

@interface KSYEditAudioTrimView : UIView

@property (nonatomic, copy) NSString *filePath; 
@property (nonatomic, weak) id <KSYEditTrimDelegate> delegate;
/**
 读取音频文件的URL

 @param filePathURL 音频路径
 */
- (void)openFileWithFilePathURL:(NSURL*)filePathURL;

@end
