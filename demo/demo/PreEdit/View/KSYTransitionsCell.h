//
//  KSYTransitionsCell.h
//  demo
//
//  Created by sunyazhou on 2017/10/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYTransModel.h"

@interface KSYTransitionsCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *transitionImage;
@property (nonatomic, strong) KSYTransModel *model;
@end
