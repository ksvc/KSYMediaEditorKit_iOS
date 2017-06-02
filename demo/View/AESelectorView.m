//
//  AESelectorView.m
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "AESelectorView.h"

@interface AESelectorView ()

@property(nonatomic)NSUInteger type;

@end

@implementation AESelectorView

- (instancetype)initWithType:(NSUInteger)type;
{
    self = [super init];
    if (self) {
        self.type = type;
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews
{
    [self addSubview:self.aeView];
    
    [self.aeView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(self);
    }];

    
}


-(AEMgrView *)aeView
{
    if (!_aeView){
        _aeView = [[AEMgrView alloc] initWithIdentifier:[NSString stringWithFormat:@"%p", self]];
        
         //TODO move below to AEModelTemplate
        AEModelTemplate *m0 = [AEModelTemplate new];
        m0.idx = 0;
        m0.image = [UIImage imageNamed:@"closeef"];
        m0.txt  = nil;
        m0.type = _type;
        
        AEModelTemplate *m1 = [AEModelTemplate new];
        m1.type = _type;
        AEModelTemplate *m2 = [AEModelTemplate new];
        m2.type = _type;
        AEModelTemplate *m3 = [AEModelTemplate new];
        m3.type = _type;
        AEModelTemplate *m4 = [AEModelTemplate new];
        m4.type = _type;
        if(_type == 0){
            /**
             - 1 录音棚
             - 2 ktv
             - 3 小舞台
             - 4 演唱会
             */
            m1.idx = 1;
            m1.image = [UIImage imageNamed:@"studio"];
            m1.txt  = @"录音棚";
            
            m2.idx = 2;
            m2.image = [UIImage imageNamed:@"ktv"];
            m2.txt  = @"KTV";
            
            m3.idx = 4;
            m3.image = [UIImage imageNamed:@"woodwing"];
            m3.txt  = @"小舞台";
            
            m4.idx = 3;
            m4.image = [UIImage imageNamed:@"concert"];
            m4.txt  = @"演唱会";
            

        }
        if (_type == 1){
            m1.idx = 1;
            m1.image = [UIImage imageNamed:@"man"];
            m1.txt  = @"大叔";
            
            m2.idx = 2;
            m2.image = [UIImage imageNamed:@"woman"];
            m2.txt  = @"萝莉";
            
            m3.idx = 3;
            m3.image = [UIImage imageNamed:@"solemn"];
            m3.txt  = @"庄重";
            
            m4.idx = 4;
            m4.image = [UIImage imageNamed:@"robot"];
            m4.txt  = @"机器人";
        }
        
        if (_type == 2) {
            for (NSInteger i = 0; i < 8; ++i) {
                AEModelTemplate *m = [AEModelTemplate new];
                m.type = _type;
                m.idx = i+1;
                m.image = [UIImage imageNamed:[NSString stringWithFormat:@"decal_%ld_icon",i]];
                m.txt = @"";
                [_aeView.dataArray addObject:m];
            }
            [_aeView.collectionView reloadData];
            return _aeView;
        }
        
        [_aeView.dataArray addObjectsFromArray:@[m0, m1, m2, m3, m4]];
        [_aeView.collectionView reloadData];
    }
    return _aeView;
}


@end
