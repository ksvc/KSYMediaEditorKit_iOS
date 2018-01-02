//
//  KSYCanvasCell.m
//  multicanvas
//
//  Created by sunyazhou on 2017/11/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYCanvasCell.h"



@interface KSYCanvasCell()
// 使用 ObservableKeys 保存 keyPath 观察状态，避免重复注册和重复移除（重复移除会导致 crash）
@property (nonatomic, strong) NSMutableSet *observableKeySets;
@end

@implementation KSYCanvasCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.canvasImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.addImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.height.equalTo(@40);
    }];
    
    [self.boundsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.canvasImageView);
    }];
    
    
}

- (void)setModel:(KSYCanvasModel *)model{
    _model = model;
}

- (void)prepareForReuse{
    [self showBorder:self.model.isSelected];
}

- (void)showBorder:(BOOL)selected{
    self.addImageView.hidden = selected;
    if (selected) {
        self.boundsView.layer.borderWidth = 2;
        self.boundsView.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.boundsView.layer.borderWidth = 0;
        self.boundsView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)updateArtworkImageFromModel:(KSYCanvasModel *)model{
    __weak KSYCanvasCell *weakSelf = self;
    [model gengrateImageBySize:self.bounds.size completionHandler:^(UIImage * _Nullable image) {
        __strong KSYCanvasCell *strongSelf = weakSelf;
        strongSelf.boundsView.image = image;
    }];
}

- (void)playVideoOrShowAddindicator:(KSYCanvasModel *)model{
    if (model.videoURL) {
        self.contentView.alpha = 0;
    } else {
        self.contentView.alpha = 1;
    }
}

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context{
    if ([self.observableKeySets containsObject:keyPath]) { return; }
    
    if (self.observableKeySets == nil) {
        self.observableKeySets = [NSMutableSet set];
    }
    
    [self.observableKeySets addObject:keyPath];
    
    [self.model addObserver:observer
                 forKeyPath:keyPath
                    options:options
                    context:context];
}

- (void)removeObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               context:(void *)context{
    if (![self.observableKeySets containsObject:keyPath]) { return; }
    
    [self.model removeObserver:observer
                    forKeyPath:keyPath
                       context:context];
    [self.observableKeySets removeObject:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    if ([KSYKeyPathForModelStatus isEqualToString:keyPath]) {
        KSYMultiCanvasModelStatus modelStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        NSLog(@"当前状态:%zd",modelStatus);
        [self handleCellActionByModelStatus:modelStatus];
    } else if([KSYKeyPathForIsSelected isEqualToString:keyPath]){
        BOOL isSelected = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        [self showBorder:isSelected];
    }
}

- (void)handleCellActionByModelStatus:(KSYMultiCanvasModelStatus)modelStatus{
    self.alpha = 1; //不透明
    if (modelStatus == KSYMultiCanvasModelStatusNOPreview) {
        [self updateArtworkImageFromModel:self.model];//更新缩略图
    } else if (modelStatus == KSYMultiCanvasModelStatusINPreview) {
        if (self.model.isSelected) {
            //正在录制的 cell 不应该任何处理 只能设置 image 为 nil
            self.boundsView.image = nil;
        } else {
            [self updateArtworkImageFromModel:self.model];//更新缩略图
        }
    } else if (modelStatus == KSYMultiCanvasModelStatusRecording) {
        if (self.model.isSelected) {
            self.boundsView.image = nil;
        } else {
            [self playVideoOrShowAddindicator:self.model];//更新缩略图
        }
    }
}

- (void)dealloc{
    self.boundsView.image = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
