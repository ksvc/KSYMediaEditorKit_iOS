//
//  KSYPreEditViewController.m
//  demo
//
//  Created by sunyazhou on 2017/10/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYPreEditViewController.h"
#import "KSYTransitionsCell.h"
#import "KSYDragCollectionViewFlowLayout.h"
#import "PHImageManager+CTAssetsPickerController.h"
#import <KSYMediaEditorKit/KSYMETransitionEditor.h>
#import <libksygpulive/KSYTransitionFilter.h>
#import "KSYEditViewController.h"
#import "KSYTransTagCell.h"
typedef NS_ENUM(NSUInteger, KSYTransClipsType) {
    KSYTransClipsTypeHeader = 0, //片头
    KSYTransClipsTypeOnChip = 1, //片中
    KSYTransClipsTypeFooter = 2  //篇尾
};

@interface KSYPreEditViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (weak, nonatomic  ) IBOutlet UIView             *preViewBGView;
@property (weak, nonatomic  ) IBOutlet UIView             *bottomPanel;
@property (weak, nonatomic  ) IBOutlet UICollectionView   *collectionView;
@property (weak, nonatomic  ) IBOutlet HMSegmentedControl *transSegment;
@property (weak, nonatomic  ) IBOutlet UIButton           *backBtn;
@property (weak, nonatomic  ) IBOutlet UIButton           *doneBtn;

@property (nonatomic, strong) NSMutableArray     *models;
@property (nonatomic, strong) NSIndexPath        *lastSelectedIndexPath;
@property (nonatomic, assign) KSYTransClipsType  currentTransType;

@property (nonatomic) KSYMETransitionEditor *transEditor;

@end

@implementation KSYPreEditViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.models = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubviews];
    [self buildModels];
    [self convertURLS];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.transEditor startPreviewOn:self.preViewBGView loop:YES];
}

- (void)dealloc{
    NSLog(@"pre vc dealloc");
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)configSubviews{
    if (@available(iOS 11.0, *)) {
        [self.preViewBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.bottomPanel.mas_top);
        }];
        
        [self.bottomPanel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.height.equalTo(@170);
        }];
        
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(30);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(30);
            make.width.height.mas_equalTo(30);
        }];
        
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(30);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-18);
            
        }];
    } else {
        
        [self.bottomPanel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.view);
            make.height.equalTo(@170);
        }];
        
        [self.preViewBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.bottom.equalTo(self.bottomPanel.mas_top);
        }];
        
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(30);
            make.left.equalTo(self.view.mas_left).offset(30);
            make.width.height.mas_equalTo(30);
        }];
        
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-18);
        }];
    }
    
    
    
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.bottomPanel);
        make.height.equalTo(@112);
    }];
    
    
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:[KSYTransitionsCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYTransitionsCell className]];
    [self.collectionView registerNib:[UINib nibWithNibName:[KSYTransTagCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYTransTagCell className]];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 22;
    layout.minimumLineSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(16, 24, 16, 24);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.collectionViewLayout = layout;
    
    
    //底部分段控件 用于选择转场
    //所有tabbar的标题都来自面板里
    
    self.transSegment.sectionTitles = [self getTransArrayByType:KSYTransClipsTypeHeader];
    self.transSegment.frame = CGRectMake(0, 20, self.view.width, 40);
    self.transSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.transSegment.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.transSegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.transSegment.shouldAnimateUserSelection = NO;
    self.transSegment.selectionIndicatorColor = [UIColor redColor];
    self.transSegment.selectionIndicatorBoxColor = [UIColor redColor];
    self.transSegment.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    [self.transSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    
    [self.transSegment mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.bottomPanel);
        make.height.equalTo(@40);
    }];
}

- (void)initTransEditorWithURLS:(NSArray *)urls{
    if (urls == nil || urls.count == 0) { return; }
    _transEditor = [[KSYMETransitionEditor alloc] initWithVideoList:urls];
    
    [_transEditor startPreviewOn:self.preViewBGView loop:YES];
}

- (void)buildModels{
    if (self.originAssets == nil || self.originAssets.count == 0) { return; }
    [self.models removeAllObjects];
    NSMutableArray *tmpModels= [[NSMutableArray alloc] initWithCapacity:0];
    
    
    for (int i = 0 ; i < self.originAssets.count; i++) {
        
        //转场 tag model
        KSYTransModel *tagModel = [[KSYTransModel alloc] init];
        tagModel.type = KSYTransCellTypeTrans;
        tagModel.transitionType = KSYTransitionTypeNone; //默认无转场
        if (i == 0) { tagModel.isSelected = YES; } //默认第一个是选中的
        
        [tmpModels addObject:tagModel];
        
        //asset Model
        KSYTransModel *model = [[KSYTransModel alloc] init];
        id asset = self.originAssets[i];
        if ([asset isKindOfClass:[NSURL class]]) {
            model.asset = [AVURLAsset assetWithURL:asset];
        } else {
            model.asset = asset;
        }
        model.type = KSYTransCellTypeVideo;
        model.transitionType = KSYTransitionTypeNone; //默认无转场
        [tmpModels addObject:model];
    }
    
    KSYTransModel *lastModel = [[KSYTransModel alloc] init];
    lastModel.type = KSYTransCellTypeTrans;
    [tmpModels addObject:lastModel];
    
    if (self.configModel != nil && self.configModel.footerVideo) {
        //最后的视频
        KSYTransModel *footerVideoModel = [[KSYTransModel alloc] init];
        //最后来张片尾视频占位图
        footerVideoModel.asset = @"ksy_ME_preEdit_trans_footer_placeholder";
        footerVideoModel.type = KSYTransCellTypeVideo;
        footerVideoModel.transitionType = KSYTransitionTypeNone; //默认无转场
        [tmpModels addObject:footerVideoModel];
    }
    [self.models addObjectsFromArray:tmpModels];
    [self.collectionView reloadData];
}

- (NSArray *)getTransArrayByType:(KSYTransClipsType)type{
    self.currentTransType = type;
    if (type == KSYTransClipsTypeHeader) {
        NSArray *headerArray = @[@"关闭转场",@"淡入",@"模糊变清晰"];
        return headerArray;
    } else if (type == KSYTransClipsTypeOnChip) {
        NSArray *onChipsArray = @[@"关闭转场",@"淡入淡出",@"闪黑",@"闪白",@"清晰变模糊",@"上推",@"下推",@"左推",@"右推"];
        return onChipsArray;
    } else if (type == KSYTransClipsTypeFooter) {
        NSArray *footerArray = @[@"关闭转场",@"淡出",@"清晰变模糊"];
        return footerArray;
    } else { return @[]; }
}

- (void)convertURLS{
    if (self.models.count == 0) { return; }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *tmpAssets = [NSArray arrayWithArray:self.originAssets];
        NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:tmpAssets.count];
        PHImageManager *manager = [PHImageManager defaultManager];
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
        };

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (int i = 0; i < tmpAssets.count; i++ ) {
            id phAsset = [tmpAssets objectAtIndex:i];
            __block NSURL *url = nil;
            if ([phAsset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset *urlAsset = (AVURLAsset *)phAsset;
                url = urlAsset.URL;
                dispatch_semaphore_signal(semaphore);
            } else if ([phAsset isKindOfClass:[NSURL class]]){
                url = (NSURL *)phAsset;
                dispatch_semaphore_signal(semaphore);
            } else if ([phAsset isKindOfClass:[PHAsset class]]){
                [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    if([asset isKindOfClass:[AVAsset class]] && ((AVComposition *)asset).tracks.count == 2){
                        if ([asset respondsToSelector:@selector(URL)]){
                            AVURLAsset *urlAsset = (AVURLAsset *)asset;
                            url = urlAsset.URL;
                            dispatch_semaphore_signal(semaphore);
                        }
                        else if ([asset isKindOfClass:[AVComposition class]]) {
                            //Output URL of the slow motion file.
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentsDirectory = paths.firstObject;
                            NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeSlowMoVideo-%d.mov",arc4random() % 1000]];
                            NSURL *furl = [NSURL fileURLWithPath:myPathDocs];
                            
                            //Begin slow mo video export
                            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                            exporter.outputURL = furl;
                            exporter.outputFileType = AVFileTypeQuickTimeMovie;
                            exporter.shouldOptimizeForNetworkUse = YES;
                            
                            [exporter exportAsynchronouslyWithCompletionHandler:^{
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                                        NSURL *URL = exporter.outputURL;
                                        url = URL;
                                    }
                                    dispatch_semaphore_signal(semaphore);
                                });
                            }];
                        }
                    } else if ([asset isKindOfClass:[AVURLAsset class]] ) {
                        AVURLAsset *urlAsset = (AVURLAsset *)asset;
                        url = urlAsset.URL;
                        dispatch_semaphore_signal(semaphore);
                    } else {
                        NSLog(@"%@",asset);
                        dispatch_semaphore_signal(semaphore);
                    }
                }];
            } else{
                NSLog(@"未知类型待 coding 解析");
                dispatch_semaphore_signal(semaphore);
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (url) {
                [urls addObject:url];
            }
            
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            //追加片尾视频
            if (self.configModel != nil && self.configModel.footerVideo) {
                NSString *tailLeaderPath = [[NSBundle mainBundle] pathForResource:@"TailLeader" ofType:@"mp4"];
                [urls addObject:[NSURL fileURLWithPath:tailLeaderPath]];
            }
            NSArray *finalURLS = [NSArray arrayWithArray:urls];
            [self initTransEditorWithURLS:finalURLS];
        });
        
    });
}


- (NSUInteger)mapTranstionTypeToIndex:(KSYTransitionType)type{
    
    if (self.currentTransType == KSYTransClipsTypeHeader) {
        if (type == KSYTransitionTypeFadesIn) {
            return 1;
        } else if (type == KSYTransitionTypeBlurIn){
            return 2;
        } else {
            return 0;
        }
    } else if (self.currentTransType == KSYTransClipsTypeFooter) {
        if (type == KSYTransitionTypeFadesOut) {
            return 1;
        } else if (type == KSYTransitionTypeBlurOut){
            return 2;
        } else {
            return 0;
        }
    }
    return type == 0 ? type : type-200;
}

#pragma mark -
#pragma mark - public methods 公有方法

#pragma mark -
#pragma mark - override methods 复写方法
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
#pragma mark -
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.models.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KSYTransModel *model = [self.models objectAtIndex:indexPath.row];
    UICollectionViewCell *cell = nil;
    if (model.type == KSYTransCellTypeVideo) {
        KSYTransitionsCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYTransitionsCell className] forIndexPath:indexPath];
        videoCell.model = model;
        cell = videoCell;
    } else if (model.type == KSYTransCellTypeTrans){
        KSYTransTagCell *tagCell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYTransTagCell className] forIndexPath:indexPath];
        tagCell.model = model;
        cell = tagCell;
    } else {
        static NSString *normal = @"ksytransNoraml";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:normal forIndexPath:indexPath];
        
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // 暂时去掉视频点击操作 如果想做视频可点击 可把这行注掉 返回 YES
    KSYTransModel *model = self.models[indexPath.item];
    return model.type != KSYTransCellTypeVideo;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KSYTransModel *lastModel = [self.models objectAtIndex:self.lastSelectedIndexPath.row];
    KSYTransModel *selectedModel = [self.models objectAtIndex:indexPath.row];
    if (self.lastSelectedIndexPath == indexPath) {
        //选择同一个cell
        selectedModel.isSelected = !selectedModel.isSelected;
    } else {
        lastModel.isSelected = NO;
        [collectionView reloadItemsAtIndexPaths:@[self.lastSelectedIndexPath]];
        selectedModel.isSelected = YES;
    }

    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    self.lastSelectedIndexPath = indexPath;
    
    if (indexPath.item == 0) {
        //片头
        self.transSegment.sectionTitles = [self getTransArrayByType:KSYTransClipsTypeHeader];
        
    } else if (indexPath.item == self.models.count -1) {
        //片尾
        self.transSegment.sectionTitles = [self getTransArrayByType:KSYTransClipsTypeFooter];
        
    } else {
        //片中
        self.transSegment.sectionTitles = [self getTransArrayByType:KSYTransClipsTypeOnChip];
    }
    [self.transSegment sizeToFit];
    
    NSUInteger index = [self mapTranstionTypeToIndex:selectedModel.transitionType];
    
    [self.transSegment setSelectedSegmentIndex:index animated:YES];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYTransModel *model = self.models[indexPath.item];
    if (model.type == KSYTransCellTypeVideo) {
        return CGSizeMake(80, 80);
    }
    return CGSizeMake(16,40);
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

- (IBAction)transSegmentValueChange:(HMSegmentedControl *)sender {
    KSYTransModel *model = self.models[self.lastSelectedIndexPath.item];
    KSYTransitionType transType = KSYTransitionTypeNone;
    if (sender.selectedSegmentIndex % 100 == 0) {
        transType = KSYTransitionTypeNone;
    } else {
        if (self.currentTransType == KSYTransClipsTypeHeader) {
            transType = sender.selectedSegmentIndex;
        } else if (self.currentTransType == KSYTransClipsTypeFooter) {
            transType = sender.selectedSegmentIndex + 100;
        } else {
            transType = sender.selectedSegmentIndex + 200;
        }
    }
    
    model.transitionType = transType;
    
    //成对出现 转场索引应该除2
    [_transEditor setTransitionWithIdx:self.lastSelectedIndexPath.item/2
                                  type:model.transitionType
                           overlapType:KSYOverlapType_BothVideo
                       overlapDuration:1.0f];
}

- (IBAction)onBackButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonAction:(UIButton *)sender {
    [_transEditor stopPreview];
    __weak typeof(self) weakSelf = self;
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.numberOfLines = 3;
    CGSize resolution;
    NSString *outPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%ld.mp4",time(NULL)];
    if (self.configModel) {
        resolution = CGSizeMake(self.configModel.pixelWidth, self.configModel.pixelHeight);
    }else{
        resolution = CGSizeMake(720, 1280);
    }
    
    [_transEditor concatVideosWithOutUrl:[NSURL fileURLWithPath:outPath]
                              resolution:resolution
                            videoBitrate:4096
                            audioBitrate:64
                              progressCB:^(int idx, CGFloat progress) {
        [hud setProgress:progress];
        hud.label.text = [NSString stringWithFormat:@"视频拼接\n idx:%zd \nprogress:%.2f %%",idx, progress * 100];
    } errorCB:^(int errorCode, NSString *errInfo) {
        hud.label.text = [NSString stringWithFormat:@"concat fail\n errorCode:%ld\n extraStr:%@",(long)errorCode, errInfo];
        [hud hideAnimated:YES afterDelay:1];
        
        [[[UIAlertView alloc] initWithTitle:@"composite fail" message:[NSString stringWithFormat:@"errCode:%ld\nmessage:%@",(long)errorCode, errInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } finishCB:^(NSURL *outURL) {
        [hud hideAnimated:YES];
        KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithNibName:@"KSYEditViewController" bundle:[NSBundle mainBundle] VideoURL:outURL];
        [weakSelf.navigationController showViewController:editVC sender:sender];
    }];
}

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
