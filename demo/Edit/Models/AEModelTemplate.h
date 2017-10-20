//
//  AEModelTemplate.h
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AEModelTemplate : NSObject

//0 for 混响, 1 变声
@property(nonatomic, assign)NSUInteger type;

@property(nonatomic, assign)NSUInteger idx;

@property(nonatomic, strong)UIImage *image;

@property(nonatomic, strong)NSString *txt;

@property(nonatomic, strong)NSString *path;


@end
