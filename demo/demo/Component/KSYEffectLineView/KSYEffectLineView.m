//
//  KSYEffectLineView.m
//  demo
//
//  Created by sunyazhou on 2017/12/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEffectLineView.h"
#import "KSYEffectLineCell.h"
#import "KSYEffectLineItem.h"
#import "KSYEffectLineMaskView.h"

//----------------------------------------
//----------------------------------------
//----------------------------------------

@implementation KSYEffectLineInfo

@end

//----------------------------------------
//----------------------------------------
//----------------------------------------
static const CGFloat kEffectlineItemCount = 13.0f;  //默认13张封面

@interface KSYEffectLineView()
<
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) NSMutableArray        *effectLineItems;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) KSYEffectLineMaskView *effectMaskView;
@end

@implementation KSYEffectLineView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configSubviews];
    }
    return self;
}


- (void)configSubviews{
    
    if (self.effectLineItems == nil) {
        self.effectLineItems = [NSMutableArray array];
    }
    [self.effectLineItems removeAllObjects];
    
    //底部缩略图
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(kScreenWidth/kEffectlineItemCount, 40);
    if (self.collectionView == nil) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self addSubview:self.collectionView];
    }
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //注册 cell
    UINib *nib = [UINib nibWithNibName:@"KSYEffectLineCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"KSYEffectLineCell"];
    
    
    //所有遮盖的 layer背景视图
    self.effectMaskView = [[[NSBundle mainBundle] loadNibNamed:@"KSYEffectLineMaskView" owner:self options:nil] lastObject];
    [self addSubview:self.effectMaskView];
    
    //遮盖视图的回调
    __weak KSYEffectLineView *weakSelf = self;
    self.effectMaskView.cursorBlock = ^(UIGestureRecognizerState state, CGFloat pointX, CGFloat ratio) {
        [weakSelf notifyDelegateState:state cursorMove:pointX withRatio:ratio];
    };
    
    self.effectMaskView.drawCompleteBlock = ^(KSYEffectLineInfo *info) {
        [weakSelf notifyDelegateDrawInfo:info];
    };
    
    self.duraiton = kCMTimeZero;
}

//取缩略图
- (void)handleThumbnails:(NSURL *)url{
     if (url== nil) { return; }
    self.imageGenerator = nil;
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    self.imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
    CMTime duration = asset.duration;
    self.duraiton = duration;
    NSMutableArray *times = [NSMutableArray array];
    
    for (int i = 0 ; i < kEffectlineItemCount; i++) {
        CGFloat pst = CMTimeGetSeconds(duration) / kEffectlineItemCount * i;
        CMTime  pstTime = CMTimeMake(pst*duration.timescale, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:pstTime]];
    }
    __block NSUInteger imageCount = times.count;                            // 4
    __block NSMutableArray *images = [NSMutableArray array];
    AVAssetImageGeneratorCompletionHandler handler;
    handler = ^(CMTime requestedTime,
                CGImageRef imageRef,
                CMTime actualTime,
                AVAssetImageGeneratorResult result,
                NSError *error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            KSYEffectLineItem *thumbnail = [KSYEffectLineItem thumbnailWithImage:image time:actualTime];
            [images addObject:thumbnail];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
        // If the decremented image count is at 0, we're all done.
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleData:images];
            });
        }
    };
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}

//取图完成
- (void)handleData:(NSArray *)effectLineItems{
    [self.effectLineItems removeAllObjects];
    [self.effectLineItems addObjectsFromArray:effectLineItems];
    [self.collectionView reloadData];
    self.imageGenerator = nil;
}


#pragma mark -
#pragma mark - override methods 复写方法
- (void)layoutSubviews{
    [super layoutSubviews];
    //更改遮盖背景的坐标
    self.effectMaskView.frame = self.bounds;
    
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (void)setDuraiton:(CMTime)duraiton{
    _duraiton = duraiton;
    self.effectMaskView.duraiton = duraiton;
}

#pragma mark -
#pragma mark - public methods 公有方法
- (void)startEffectByURL:(NSURL *)url{
    if (url== nil) { NSLog(@"传入的 URL 不能为 nil");  return;}
    self.url = url;
    [self handleThumbnails:self.url];
}

- (void)seekToTime:(Float64)time{
    Float64 seekTime = (CMTimeGetSeconds(self.duraiton) == 0) ? 0 : time / CMTimeGetSeconds(self.duraiton);
    [self.effectMaskView seekToCursorTime:seekTime];
}

- (void)drawViewByStatus:(KSYEffectLineCursorStatus)status
                andColor:(UIColor *)drawColor
                 forType:(KSYEffectLineType)type{
    [self.effectMaskView drawView:status andColor:drawColor forType:type];
    //通知代理
    if (status == KSYELViewCursorStatusDrawBegan ||
        status == KSYELViewCursorStatusDrawing) {
        [self notifyDelegateDrawStatus:status drawedModel:nil];
    }
}


- (void)removeLastDrawViews{
    [self.effectMaskView undoDrawedView];
}
- (void)removeAllDrawViews{
    [self.effectMaskView undoAllDrawedView];
}

- (NSArray<KSYEffectLineInfo *>*)getAllDrawedInfos{
    return [self.effectMaskView getAllDrawedInfo];
}

#pragma mark -
#pragma mark - UICollectionView Delegate 代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.effectLineItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYEffectLineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KSYEffectLineCell" forIndexPath:indexPath];
    cell.effectLineItem = [self.effectLineItems objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)notifyDelegateState:(UIGestureRecognizerState)state
                 cursorMove:(CGFloat)pointX
                  withRatio:(CGFloat)ratio {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectLineView:state:cursorMoveRatio:)]) {
        [self.delegate effectLineView:self state:state cursorMoveRatio:ratio];
    }
}

- (void)notifyDelegateDrawInfo:(KSYEffectLineInfo *)info{
    if (info == nil) { return; }
    [self notifyDelegateDrawStatus:KSYELViewCursorStatusDrawEnd drawedModel:info];
}

- (void)notifyDelegateDrawStatus:(KSYEffectLineCursorStatus)status
                     drawedModel:(KSYEffectLineInfo *)info{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectLineView:actionState:completeDrawInfo:)]){
        [self.delegate effectLineView:self actionState:status completeDrawInfo:info];
    }
}

@end
