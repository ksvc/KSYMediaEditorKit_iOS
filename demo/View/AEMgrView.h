//
//  AEMgrView.h
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEModelTemplate.h"

@interface AEMgrView : UIView

- (instancetype)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, strong)UICollectionView *collectionView;

//for external init
@property (nonatomic, strong)NSMutableArray<__kindof AEModelTemplate *> *dataArray;

@property (nonatomic, copy)void(^BgmBlock)(AEModelTemplate *model);

@end
