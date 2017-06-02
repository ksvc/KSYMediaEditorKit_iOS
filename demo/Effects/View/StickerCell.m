//
//  NemoFilterCell.m
//  Nemo
//
//  Created by ksyun on 17/4/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "StickerCell.h"
@interface StickerCell(){
    
}

@property (nonatomic, strong) UIImageView * filterView;
@property(nonatomic,strong)UIButton * downloadBtn;

@end

@implementation StickerCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    UIView *maskView = [[UIView alloc]init];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.15;
    [self.contentView addSubview:maskView];
    
    _filterView = [[UIImageView alloc] init];
    [self.contentView addSubview:_filterView];
    
    //添加一个下载按钮
    CGRect btnFram = CGRectMake(0, 0, 24, 24);
    _downloadBtn = [[UIButton alloc]initWithFrame:btnFram];
    [_downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    _downloadBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:_downloadBtn];
    _downloadBtn.hidden = YES;
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-8);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.5);
        make.left.equalTo(self.contentView).offset(12.5);
        make.width.mas_equalTo(75);
        make.height.mas_equalTo(75);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


-(void)setMaterial:(SenseArMaterial *)material{
    _material = material;
    __weak typeof(self) weakSelf = self;
    //设置缩略图
    if(!_material){
        [self.filterView setImage:[UIImage imageNamed:@"ar_none"]];
    }else{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:_material.strThumbnailURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              
              dispatch_sync(dispatch_get_main_queue(), ^{
                  weakSelf.filterView.image = [UIImage imageWithData:data];
              });
              
          }] resume];
        });
    }
    
    //设置下载图标
    if ( !_material ||[[STFilterManager instance].ksySTFitler isDownloadComplete:_material] ) {
        _downloadBtn.hidden = YES;
    }else{
        _downloadBtn.hidden = NO;
    }
}

-(void)downloadMaterial{
    //判断是否已经下载
    if(_material && ![[STFilterManager instance].ksySTFitler isDownloadComplete:_material]){
        [STFilterManager instance].ksySTFitler.enableSticker = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showHud];
            _downloadBtn.hidden = YES;
        });
        
        //下载
        [[STFilterManager instance].ksySTFitler download:_material onSuccess:^(SenseArMaterial * m){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.contentView animated:NO];
            });
            [STFilterManager instance].ksySTFitler.enableSticker = YES;
            [[STFilterManager instance].ksySTFitler startShowingMaterial];
        } onFailure:nil onProgress:^(SenseArMaterial * matarial, float process, int64_t error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD HUDForView:self.contentView].progress = process;
            });
        }];
    }
}

-(void)showHud{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:NO];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    if (selected) {
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [[UIColor colorWithHexString:@"#ff8c10"]CGColor];
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [[UIColor clearColor]CGColor];
    }
}

@end
