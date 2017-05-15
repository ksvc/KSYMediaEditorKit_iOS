//
//  FilterCell.m
//  
//
//  Created by ksyun on 17/4/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "FilterCell.h"

@interface FilterCell(){
    
}

@property (nonatomic, strong) UIImageView * filterView;

@end

@implementation FilterCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.frame = CGRectMake(0, 0, 75, 100);
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        //make.width.mas_equalTo(75);
        //make.height.mas_equalTo(100);
    }];
}

-(void)setEffectIndex:(int)effectIndex{
    _effectIndex = effectIndex;
    if (!_filterView) {
        _filterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"effect_%d",(int)_effectIndex]] highlightedImage:nil];

        [self.contentView addSubview:_filterView];
        
        [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.centerX.equalTo(self.contentView);
            //make.centerY.equalTo(self.contentView);
            //make.top.equalTo(self).offset(20);
            make.top.equalTo(self.contentView);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(100);
        }];
    }else{
        [_filterView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"effect_%d",(int)_effectIndex]]];
    }
    
}
@end
