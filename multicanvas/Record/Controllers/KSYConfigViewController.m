//
//  KSYConfigViewController.m
//  multicanvas
//
//  Created by sunyazhou on 2017/11/24.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYConfigViewController.h"
#import "KSYFlowLayout.h"
#import "KSYCanvasCell.h"
#import "KSYCanvasModel.h"
#import "RecordProgressView.h"
#import "KSYMCEditorViewController.h"

#define kWidthPadding  0
#define kHeightPadding  0

//用枚举状态判断要显示 UI 的 类型 eg: 某种状态下需要显示哪个 button，隐藏那些视图
typedef NS_ENUM(NSUInteger, KSYMultiCanvasUIStatus){
    KSYMultiCanvasUIStatusNormal = 0,
    KSYMultiCanvasUIStatusPreview = 1,
    KSYMultiCanvasUIStatusRecording = 2 //正在录制
};

//当前预览的状态
typedef NS_ENUM(NSUInteger, KSYMCRecorderStatus){
    KSYMultiCanvasRecorderStatusNoUse = -1,
    KSYMultiCanvasRecorderStatusNormal = 0,
    KSYMultiCanvasRecorderStatusRunning = 1
};

//目前以540 * 960 比例 计算
#define kRESOLUTION  CGSizeMake(540, 960)


@interface KSYConfigViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
KSYCameraRecorderDelegate,
KSYMCEditorVCDelegate
>
@property (weak, nonatomic) IBOutlet UIView           *bgView;
@property (weak, nonatomic) IBOutlet RecordProgressView *topProgressView;

@property (weak, nonatomic) IBOutlet UIView           *canvasView;//画布最后播放的背景
@property (weak, nonatomic) IBOutlet UICollectionView *canvasCollectionView;//CollectionView
@property (weak, nonatomic) IBOutlet UIView           *bottomPanel;//底部按钮面板

@property (weak, nonatomic) IBOutlet UIButton         *backButton;

@property (weak, nonatomic) IBOutlet UIButton         *recordButton;//录制按钮

@property (weak, nonatomic) IBOutlet UIButton         *flashButton;

@property (weak, nonatomic) IBOutlet UIButton         *cameraButton;

@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSIndexPath    *lastSelectedIndexPath;

@property (nonatomic, strong) KSYCameraRecorder *recorder; //录制
@property (nonatomic, strong) NSArray *reginsArray;



@property (nonatomic, strong) NSMutableArray *recordedURLs;

@property (nonatomic, strong) NSURL *lastConcatorURL; //上次合成完成的 URL

@property (nonatomic, assign) BOOL needReopenPreview;

@property (nonatomic, strong) KSYMoviePlayerController *player;
@end

@implementation KSYConfigViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
        self.recordedURLs = [NSMutableArray array];
        self.needReopenPreview = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubviews];
    [self buildModels];
    [self generateRecorder];
    [self registerNotifications];
    
    [self.view setNeedsUpdateConstraints];
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)buildModels{
    if (self.models.count > 0) { [self.models removeAllObjects]; }
    
    //竖向regions
    NSArray *regions = @[
                           [NSValue valueWithCGRect:CGRectMake(0, 0, 0.5, 0.5)],
                           [NSValue valueWithCGRect:CGRectMake(0, 0.5, 0.5, 0.5)],
                           [NSValue valueWithCGRect:CGRectMake(0.5, 0, 0.5, 0.5)],
                           [NSValue valueWithCGRect:CGRectMake(0.5, 0.5, 0.5, 0.5)]
                        ];
    NSMutableArray *tempModels = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0 ; i < regions.count; i++) {
        KSYCanvasModel *model = [[KSYCanvasModel alloc] init];
        model.isSelected = NO;
        model.isRecording = NO;
        model.modelStatus = KSYMultiCanvasModelStatusNOPreview;
        CGRect region = [regions[i] CGRectValue];
        model.region = region;
        model.resolution = CGSizeMake(region.size.width * kRESOLUTION.width, region.size.height * kRESOLUTION.height);
        model.leftChannelValue = 1;
        model.rightChannelValue = 1;
        model.pan = 0; //-1 ~ 1
        [tempModels addObject:model];
    }
    [self.models addObjectsFromArray:tempModels];
    self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.canvasCollectionView reloadData];
    
}

- (void)configSubviews{
    //
    self.canvasCollectionView.dataSource = self;
    self.canvasCollectionView.delegate = self;
    KSYFlowLayout *layout = [[KSYFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.canvasCollectionView setCollectionViewLayout:layout];
    [self.canvasCollectionView registerNib:[UINib nibWithNibName:[KSYCanvasCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYCanvasCell className]];
}


- (void)generateRecorder{
    if (self.recorder == nil){
        self.recorder = [[KSYCameraRecorder alloc] init];
        self.recorder.delegate = self;
    }
    //config 基本参数
    self.recorder.videoFrameRate = 30;
    self.recorder.videoBitrate = 4096;
    self.recorder.audioBitrate = 64;
    self.recorder.minRecDuration = 5; //5秒
    // 设置最短、最长录制时间
    self.recorder.maxRecDuration = 60; //1分钟
    // 视频方向
//    if (recordModel.orientation == KSYOrientationHorizontal){
//        _recorder.videoOrientation = UIInterfaceOrientationLandscapeRight;
//    }
    // 默认开启 前置摄像头
    self.recorder.cameraPosition = AVCaptureDevicePositionFront;
}


- (void)hanleCellRecorderByCollectionView:(UICollectionView *)collectionView
                                indexPath:(NSIndexPath *)indexPath
                            selectedModel:(KSYCanvasModel *)model
                                 selected:(BOOL)isSelected
                             andSameClick:(BOOL)isSameClick{
    //----------处理cell 录制----------
    KSYCanvasCell *cell = (KSYCanvasCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //check cell
    if (cell == nil) { return; }
    if (isSelected) {
        self.recorder.previewDimension = model.resolution;
        self.recorder.outputVideoDimension = model.resolution;
        
        if (!isSameClick) {
            if (self.recorder.preview.superview != nil) {
                [self.recorder.preview removeFromSuperview];
                [cell.canvasImageView addSubview:self.recorder.preview];
            } else {
                [self.recorder startPreview:cell.canvasImageView];
            }
        } else {
            [self.recorder startPreview:cell.canvasImageView];
        }
        
        //显示录制按钮
        if (self.recordButton.hidden) {
            self.recordButton.hidden = NO;
        }
        self.cameraButton.hidden = self.recordButton.hidden;
        self.flashButton.hidden = self.recordButton.hidden;
    } else {
        //如果正在录制那么必须停止,当停止录制按钮到normal 状态的时候
        if ([self.recorder isRecording]) {
            [self.recorder stopRecord:nil];
        }
        [self.recorder stopPreview];

        self.recordButton.hidden = YES;
        self.cameraButton.hidden = self.recordButton.hidden;
        self.flashButton.hidden = self.recordButton.hidden;
    }
}

- (void)reopenPreview{
    KSYCanvasCell *cell = (KSYCanvasCell *)[self.canvasCollectionView cellForItemAtIndexPath:self.lastSelectedIndexPath];
    if (cell) {
        KSYCanvasModel *model = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
        self.recorder.previewDimension = model.resolution;
        self.recorder.outputVideoDimension = model.resolution;
        if (self.recorder.preview.superview != nil) {
            [self.recorder.preview removeFromSuperview];
            [cell.canvasImageView addSubview:self.recorder.preview];
        } else {
            [self.recorder startPreview:cell.canvasImageView];
        }
    }
}

//创建播放器
- (void)playerVideoByURL:(NSURL *)videoURL{
    if (videoURL == nil) {
        [self.player stop];
        self.player = nil;
        return;
    }
    if (self.player == nil) {
        self.player = [[KSYMoviePlayerController alloc] initWithContentURL:nil];
        self.player.shouldLoop = NO;
        self.player.shouldAutoplay = NO;
    }
    [self.player reset:YES];
    [self.player setUrl:videoURL];
    self.player.view.frame = self.canvasView.bounds;
    if (self.player.view.superview == nil) {
        [self.canvasView addSubview:self.player.view];
        [self.canvasView bringSubviewToFront:self.canvasCollectionView];
        [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.canvasView);
        }];
    }
    [self.player prepareToPlay];
}

- (void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerPlaybackStateDidChangeNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerPlaybackDidFinishNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerLoadStateDidChangeNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMovieNaturalSizeAvailableNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerFirstVideoFrameRenderedNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerFirstAudioFrameRenderedNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerSuggestReloadNotification)
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerPlaybackStatusNotification)
                                               object:_player];
    
    [self.canvasCollectionView.visibleCells enumerateObjectsUsingBlock:^(KSYCanvasCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        KSYCanvasCell *canvasCell = (KSYCanvasCell *)cell;
        [canvasCell addObserver:canvasCell
                     forKeyPath:KSYKeyPathForModelStatus
                        options:NSKeyValueObservingOptionNew
                        context:&KSYModelKVOStatusContext];
        [canvasCell addObserver:canvasCell
                     forKeyPath:KSYKeyPathForIsSelected
                        options:NSKeyValueObservingOptionNew
                        context:&KSYModelKVOStatusContext];
    }];
}


#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
//苹果官方推荐的布局方法
- (void)updateViewConstraints{
    //为了适配 safeArea
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    //顶部进度条
    [self.topProgressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.bgView);
        make.height.equalTo(@4);
    }];
    
    
    //注意:这里的比例是按照 9:16高度计算
    // 宽度 两边间隙各留40 (也就是80)
    // cell 的宽高比要与录制宽高比一致
    CGFloat ratioHeight = ((kScreenWidth - 40 - 40) * 16)/9;
    //画布播放
    [self.canvasView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.centerY.equalTo(self.bgView.mas_centerY).offset(-20);
        make.width.equalTo(@((kScreenWidth - 40 - 40)));
        make.height.equalTo(@(ratioHeight));
    }];
    
    //collectionView
    [self.canvasCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.canvasView);
    }];
    
    
    NSLog(@"frame:%@",NSStringFromCGRect(self.bgView.frame));
    
    //返回按钮
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(23);
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.width.height.equalTo(@30);
    }];
    
    [self.cameraButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView.mas_right).offset(-23);
        make.top.equalTo(self.backButton.mas_top);
        make.width.height.equalTo(self.backButton);
    }];

    [self.flashButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cameraButton.mas_centerY);
        make.right.equalTo(self.cameraButton.mas_left).offset(-20);
        make.width.height.equalTo(self.cameraButton);
    }];
    
//    [self.doneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.bgView.mas_right).offset(-23);
//        make.top.equalTo(self.backButton.mas_top);
//        make.width.height.equalTo(self.backButton);
//    }];
//
    //底部功能面板
    [self.bottomPanel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.bgView);
        make.top.lessThanOrEqualTo(self.canvasView.mas_bottom);
    }];
    
    //录制按钮
    [self.recordButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomPanel);
        make.width.height.equalTo(@70);
    }];
    
    //删除按钮
    CGFloat btnOffset = kScreenWidth / 4.0;
//    [self.deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.recordButton.mas_centerY);
//        make.width.height.equalTo(@32);
//        make.centerX.equalTo(self.recordButton.mas_centerX).offset(-btnOffset);
//    }];
//    //确定按钮
//    [self.okButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.recordButton.mas_centerY);
//        make.width.height.equalTo(self.deleteButton);
//        make.centerX.equalTo(self.recordButton.mas_centerX).offset(btnOffset);
//    }];
//
//    //播放按钮
//    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.recordButton.mas_centerY);
//        make.width.equalTo(@30);
//        make.height.equalTo(@50);
//        make.left.equalTo(self.canvasView.mas_left).offset(10);
//    }];
//    //声道按钮
//    [self.channelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.playButton.mas_centerY);
//        make.width.height.equalTo(self.playButton);
//        make.left.equalTo(self.playButton.mas_right).offset(30);
//    }];
    
//    //底部音视频视图
//    [self.ksyAVPanel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(self.bottomPanel);
//        make.top.equalTo(self.bottomPanel.mas_top).offset(-60);
//    }];
    
    [super updateViewConstraints];
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (void)setLastConcatorURL:(NSURL *)lastConcatorURL{
    _lastConcatorURL = lastConcatorURL;
    
    [self playerVideoByURL:_lastConcatorURL];
}

#pragma mark -
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYCanvasCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYCanvasCell className] forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.row];
    return cell;
}

// 定义每个UICollectionViewCell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //为了保证横向纵向 间隙不小于宽高 否则 collectionView 会变形
    NSUInteger itemsCountInsection = [collectionView numberOfItemsInSection:indexPath.section] / 2;
    //检查横竖屏
    if (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait || self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGSizeMake(collectionView.bounds.size.width/2.0 - kWidthPadding * itemsCountInsection, collectionView.bounds.size.height/2.0 - kHeightPadding * itemsCountInsection);
    } else {
        return CGSizeMake(collectionView.bounds.size.height/2.0 - kWidthPadding * itemsCountInsection, collectionView.bounds.size.width/2.0 - kHeightPadding * itemsCountInsection);
        
    }
}

// 定义每个UICollectionViewCell的margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kHeightPadding, kWidthPadding, kHeightPadding, kWidthPadding);
}

// UICollectionViewCell最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kWidthPadding;
}

// UICollectionViewCell最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kHeightPadding;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYCanvasCell *canvasCell = (KSYCanvasCell *)cell;
    [canvasCell addObserver:canvasCell
                 forKeyPath:KSYKeyPathForModelStatus
                    options:NSKeyValueObservingOptionNew
                    context:&KSYModelKVOStatusContext];
    [canvasCell addObserver:canvasCell
                 forKeyPath:KSYKeyPathForIsSelected
                    options:NSKeyValueObservingOptionNew
                    context:&KSYModelKVOStatusContext];

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYCanvasCell *canvasCell = (KSYCanvasCell *)cell;
    //状态变化
    [canvasCell removeObserver:canvasCell
                    forKeyPath:KSYKeyPathForModelStatus
                       context:&KSYModelKVOStatusContext];
    //选中变化
    [canvasCell removeObserver:canvasCell
                    forKeyPath:KSYKeyPathForIsSelected
                       context:&KSYModelKVOStatusContext];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYCanvasModel *model = [self.models objectAtIndex:indexPath.row];
    
    //录制时候 cell 不能响应任何点击
    if (self.recorder.isRecording || model.videoURL != nil) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //------------处理点击-----------
    KSYCanvasModel *lastModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
    KSYCanvasModel *selectedModel = [self.models objectAtIndex:indexPath.row];
    BOOL clickSameCell = (self.lastSelectedIndexPath == indexPath);
    if (clickSameCell) {
        //选择同一个cell
        selectedModel.isSelected = !selectedModel.isSelected;
    } else {
        lastModel.isSelected = NO;
//        [collectionView reloadItemsAtIndexPaths:@[self.lastSelectedIndexPath]];
        selectedModel.isSelected = YES;
    }
    
//    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    self.lastSelectedIndexPath = indexPath;
    
    
    [self hanleCellRecorderByCollectionView:collectionView
                                  indexPath:indexPath
                              selectedModel:selectedModel
                                   selected:selectedModel.isSelected
                               andSameClick:clickSameCell];
}

#pragma mark -
#pragma mark - KSYCameraRecorder Delegate 录制代理
/**
 开始录制
 
 @param recorder instance of KSYCameraRecorder
 @param status   status of start record, noErr indicate start success,otherwise fail
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder
           startRecord:(OSStatus)status{
    [self.topProgressView removeLastRangeView];
    [self.topProgressView addRangeView];
    [self.topProgressView setLastRangeViewSelected:YES];
}

/**
 完成一次录制回调，超过最大录制长度而停止录制时不会有该回调
 @param recorder 相应的实例
 @param length 已经录制的视频总长度
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder
       didFinishRecord:(NSTimeInterval)length
              videoURL:(NSURL *)url{
    NSLog(@"完成:%@",url);
    KSYCanvasModel *currentModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
    for (KSYCanvasModel *model in self.models) {
        if (currentModel == model) {
            model.videoURL = url;
        }
        model.modelStatus = KSYMultiCanvasModelStatusNOPreview;
    }
    [self.recorder stopRecord:nil];
    [self.recorder stopPreview];
    self.recordButton.selected = NO;
    KSYMCEditorViewController *editVC = [[KSYMCEditorViewController alloc] initWithNibName:[KSYMCEditorViewController className] bundle:[NSBundle mainBundle]];
    editVC.model = currentModel;
    editVC.recordedURL = self.lastConcatorURL;
    KSYCanvasCell *cell = (KSYCanvasCell *)[self.canvasCollectionView cellForItemAtIndexPath:self.lastSelectedIndexPath];
    if (cell) {
        CGRect rect = [self.canvasCollectionView convertRect:cell.frame toView:self.canvasCollectionView];
        editVC.layoutFrame = rect;
    }
    editVC.delegate = self;
    [self.navigationController pushViewController:editVC animated:YES];
}

/**
 更新录制的进度
 1.stopRecord之后不再回调
 2.达到maxRecDuration之后不再回调
 
 @param recorder 相应的实例
 @param lastRecordLength 最新录制的一条视频已录制的长度
 @param totalLength 录制视频集合的总长度
 @warning 使用者应该尽可能快的返回该函数
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder
      lastRecordLength:(NSTimeInterval)lastRecordLength
           totalLength:(NSTimeInterval)totalLength{
    NSLog(@"record last:%f total:%f", lastRecordLength, totalLength);
    [self.topProgressView updateLastRangeView:lastRecordLength/recorder.maxRecDuration];
    
//    if (lastRecordLength >= recorder.minRecDuration) {
//        [self showCorrespondingViewsByUIStatus:KSYMultiCanvasUIStatusRecording];
//    }
}

/**
 达到最大录制长度限制的回调,只有设置了maxRecDuration之后才有可能收到该回调
 
 @param recorder 相应的实例
 @param maxRecDuration 最大长度
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder didReachMaxDurationLimit:(NSTimeInterval)maxRecDuration{
    
}


#pragma mark -
#pragma mark - KSYMCEditorVCDelegate Delegate VC代理
- (void)editorVC:(KSYMCEditorViewController *)editorVC
      isEditDone:(BOOL)isEditDone{
    self.needReopenPreview = !isEditDone;
}

- (void)editorVC:(KSYMCEditorViewController *)editorVC
     concatorURL:(NSURL *)url
     canvasModel:(KSYCanvasModel *)model{
    if (url) {
        self.lastConcatorURL = url;
        [self.recordedURLs addObject:url];
    }
    KSYCanvasModel *selectedModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
    selectedModel.leftChannelValue = model.leftChannelValue;
    selectedModel.rightChannelValue = model.rightChannelValue;
    selectedModel.isSelected = NO;
    selectedModel.modelStatus = KSYMultiCanvasModelStatusNOPreview;
    self.recordButton.hidden = YES;
    self.cameraButton.hidden = self.recordButton.hidden;
    self.flashButton.hidden = self.recordButton.hidden;
    
    //删除断点录制的信息
    for (int i = 0; i < self.recorder.recordedVideos.count; i ++) {
        [self.recorder deleteRecordedVideoAt:i];
    }
}

- (NSArray *)allRecordedURLs{
    return self.recordedURLs;
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)onBackButtonClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)onRecordButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        NSLog(@"录制开始");
        for (KSYCanvasModel *model in self.models) {
            KSYCanvasModel *currentModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
            if (currentModel == model) {
                if (model.videoURL) {
                    [self reopenPreview];
                }
                model.isSelected = YES;
            } else {
                model.isSelected = NO;
            }
            model.modelStatus = KSYMultiCanvasModelStatusRecording;
        }
        [self.recorder startRecord];
        if (![self.player isPlaying]) {
            [self.player play];
        }
    } else {
        NSLog(@"录制结束");
        [self.player pause];
        [self.player seekTo:0 accurate:NO];
        [self.recorder stopRecord:nil];
    }
}
- (IBAction)onDeleteButtonClick:(UIButton *)sender {
    
//    [self.topProgressView removeLastRangeView];
//
//    KSYCanvasModel *model = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
//    if (model.videoURL) {
//        if ([self.recordedURLs containsObject:model.videoURL]) {
//            [self.recordedURLs removeObject:model.videoURL];
//        }
//        [self.recorder deleteRecordedVideoByURL:model.videoURL];
//        model.videoURL = nil;
//    }
//    model.modelStatus = KSYMultiCanvasModelStatusNOPreview;
//    [self reopenPreview];
    
}
- (IBAction)onOKButtonClick:(UIButton *)sender {
    if (self.recorder.captureState == KSYCaptureStateCapturing) {
        __weak KSYConfigViewController *weakSelf = self;
        [self.recorder stopRecord:^{
            [weakSelf.recorder stopPreview];
        }];
        self.recordButton.selected = NO;
    }
    
    for (KSYCanvasModel *model in self.models) {
        model.isSelected = NO;
        model.modelStatus =  KSYMultiCanvasModelStatusNOPreview;
    }
//    [self showCorrespondingViewsByUIStatus:KSYMultiCanvasUIStatusNormal];
}


- (IBAction)onCameraButtonClick:(UIButton *)sender{
    [self.recorder switchCamera];
}

- (IBAction)onFlashButtonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self.recorder toggleTorch];
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        
        
        // using autoPlay to start live stream
        // [_player play];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], [_player serverAddress]);
        
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        
        if (self.player.playbackState == MPMoviePlaybackStatePlaying){
            
        } else {
            
        }
        
        NSLog(@"------------------------");
        NSLog(@"player playback state: %zd", self.player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            NSLog(@"player start caching");
            
        }
        
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
                NSLog(@"player finish caching");
                
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            NSLog(@"%@", [NSString stringWithFormat:@"player finish"]);
        }else if (reason == MPMovieFinishReasonPlaybackError){
            NSString *info = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = info;
            // Move to bottm center.
            
            [hud hideAnimated:YES afterDelay:2.0];
            
        }else if (reason == MPMovieFinishReasonUserExited){
            NSLog(@"%@", [NSString stringWithFormat:@"player userExited"]);
        }
        
        
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f", _player.naturalSize.width, _player.naturalSize.height);
    }
    if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name)
    {
        NSLog(@"first video frame show");
        
    }
    
    if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)
    {
        NSLog(@"first audio frame render");
    }
    
    if (MPMoviePlayerSuggestReloadNotification == notify.name)
    {
        NSLog(@"suggest using reload function!\n");
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (weakSelf.player) {
                NSLog(@"reload stream");
                [weakSelf.player reload:weakSelf.lastConcatorURL flush:YES mode:MPMovieReloadMode_Accurate];
            }
            
        });
    }
    
    if(MPMoviePlayerPlaybackStatusNotification == notify.name){
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        NSString *info;
        if(MPMovieStatusVideoDecodeWrong == status){
            info = @"Video Decode Wrong!\n";
        }
        else if(MPMovieStatusAudioDecodeWrong == status){
            info = @"Audio Decode Wrong!\n";
        }
        else if (MPMovieStatusHWCodecUsed == status){
            info = @"Hardware Codec used\n";
        }
        else if (MPMovieStatusSWCodecUsed == status){
            info = @"Software Codec used\n";
        }
        NSLog(@"%@",info);
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = info;
        // Move to bottm center.
        
        [hud hideAnimated:YES afterDelay:2.0];
    }
    
    if (MPMoviePlayerSeekCompleteNotification == notify.name) {
        
        
        if (self.player.playbackState != MPMusicPlaybackStatePlaying) {
            [self.player play];
        }
        
    }
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.needReopenPreview) {
        KSYCanvasModel *model = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
        [self.recorder deleteRecordedVideoByURL:model.videoURL];
        model.videoURL = nil;
        model.modelStatus = KSYMultiCanvasModelStatusNOPreview;
        
        [self reopenPreview];
        
        self.needReopenPreview = NO;
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)dealloc{
    [self.canvasCollectionView.visibleCells enumerateObjectsUsingBlock:^(KSYCanvasCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        [cell removeObserver:cell
                  forKeyPath:KSYKeyPathForModelStatus
                     context:&KSYModelKVOStatusContext];
        [cell removeObserver:cell
                  forKeyPath:KSYKeyPathForIsSelected
                     context:&KSYModelKVOStatusContext];
        
    }];
    
}

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
