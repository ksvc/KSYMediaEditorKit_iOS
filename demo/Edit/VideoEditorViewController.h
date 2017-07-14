//
//  VideoEditorViewController.h
//  demo
//
//  Created by 张俊 on 05/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutputModel.h"

@interface VideoEditorViewController : UIViewController

-(instancetype)initWithUrl:(NSURL *)path;

@property (nonatomic, strong) OutputModel *outputModel;

@end
