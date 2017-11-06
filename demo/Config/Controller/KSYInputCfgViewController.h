//
//  KSYInputCfgViewController.h
//  demo
//
//  Created by sunyazhou on 2017/10/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSYInputCfgModel;

typedef void (^InputCfgFinishBlock)(KSYInputCfgModel * model);


//@class KSYInputCfgViewController;
//@protocol KSYInputCfgVCDelegate <NSObject>
//
//@optional
//- (void)inputCfgViewController:(KSYInputCfgViewController *)vc
//                    inputModel:(KSYInputCfgModel *)model;
//
//@end



@interface KSYInputCfgViewController : UIViewController

@property (nonatomic, copy) InputCfgFinishBlock finish;
//@property (nonatomic, weak) id <KSYInputCfgVCDelegate> delegate;


@end
