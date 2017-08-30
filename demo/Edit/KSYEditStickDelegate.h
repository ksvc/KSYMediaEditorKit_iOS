//
//  KSYEditStickDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSYEditStickerCell;
@protocol KSYEditStickDelegate <NSObject>

@optional
- (void)editPanelStickerType:(KSYMEEditStickerType)type selectedIndex:(NSInteger)index;


@end
