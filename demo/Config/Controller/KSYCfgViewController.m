//
//  KSYCfgViewController.m
//  demo
//
//  Created by sunyazhou on 2017/7/6.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYCfgViewController.h"

#import "RecordConfigCell.h"
#import "OutputConfigCell.h"

#import "RecordConfigModel.h"
#import "OutputModel.h"
#import "KSYRecordViewController.h"
#import "KSYEditViewController.h"
#import "CTAssetsPickerController.h"

#import "KSYPreEditViewController.h"
#import "KSYTransModel.h"
#import "KSYInputCfgViewController.h"
#import "SlideInPresentationManager.h"
#import "TZImagePickerController.h"

@interface KSYCfgViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
RecordCfgCellDelegte,
OutputCfgCellDelegate,
CTAssetsPickerControllerDelegate,
KSYMEConcatorDelegate,
TZImagePickerControllerDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *configTableView;
@property (strong, nonatomic) IBOutlet UILabel *recordLabel; //组头视图
@property (strong, nonatomic) NSMutableArray *models;

@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *localImportButton;

@property (strong, nonatomic) KSYMEConcator *concator;

@property (nonatomic, strong) SlideInPresentationManager *slideInTransitioningDelegate;

@property (nonatomic, strong) TZImagePickerController *imagePickerVC;
@end

@implementation KSYCfgViewController

- (void)awakeFromNib{
    [super awakeFromNib];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.models = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self buildModels];
    [self configSubview];
    
}
#pragma mark -
#pragma mark - private methods 私有方法
- (void)buildModels{
    RecordConfigModel *recordModel = [[RecordConfigModel alloc] init];
    recordModel.resolution = KSYRecordPreset720P;
    recordModel.fps = 30;
    recordModel.videoKbps = 4096;
    recordModel.audioKbps = 64;
    recordModel.orientation = KSYOrientationVertical;
    
    [self.models removeAllObjects];
    [self.models addObjectsFromArray:@[recordModel]];
}


/**
 demo的UI代码 不需要关注
 */
- (void)configSubview{
    [self.configTableView registerNib:[UINib nibWithNibName:[RecordConfigCell className] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[RecordConfigCell className]];
    
//    [self.configTableView registerNib:[UINib nibWithNibName:[OutputConfigCell className] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[OutputConfigCell className]];
    
    CGFloat bottomY = kScreenHeight *0.15;
    [self.configTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            make.top.mas_equalTo(self.view.mas_top).offset(20);
        }
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(kScreenHeight * 0.5));
    }];
    
    //配置底部两个按钮
    CGFloat buttonHeight = 54;
    CGFloat buttonCenterX = kScreenWidth/4.0;
    CGFloat buttonCenterY = bottomY /2.0;
    [self.localImportButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).offset(50);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(-buttonCenterX );
        if (@available(iOS 11.0, *)) {
            make.centerY.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-buttonCenterY);
        } else {
            make.centerY.mas_equalTo(self.view.mas_bottom).offset(-buttonCenterY);
        }
        make.width.equalTo(@56);
        make.height.equalTo(@(buttonHeight));
    }];
    [self.startRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.localImportButton);
        make.top.mas_equalTo(self.localImportButton.mas_top);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(buttonCenterX);
    }];
    self.configTableView.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.configTableView.allowsSelection = YES;
    self.navigationController.navigationBar.hidden = YES;
}


#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
#pragma mark -
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.models.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:[RecordConfigCell className] forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.section];
    cell.delegate = self;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.recordLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 220;
    }
    return 260;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView endEditing:YES];
}

#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
- (void)recordConfigCell:(RecordConfigCell *)cell
             recordModel:(RecordConfigModel *)model{
    if (model == nil) { return; }
    if ([self.models containsObject:model]) {
        NSUInteger index = [self.models indexOfObject:model];
        [self.models replaceObjectAtIndex:index withObject:model];
    } else {
        [self.models addObject:model];
    }
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)localImportAction:(UIButton *)button{
    //选择本地视频
    [self pushImagePickerController];
}

- (IBAction)startRecordAction:(UIButton *)button{
    KSYRecordViewController *recordVC = [[KSYRecordViewController alloc] initWithNibName:@"KSYRecordViewController" bundle:[NSBundle mainBundle]];
    recordVC.models = self.models;
    [self.navigationController pushViewController:recordVC animated:YES];
//    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
}


/**
 弹出相册选择视频
 */
- (void)pushImagePickerController {
    self.imagePickerVC = nil;
    self.imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:100 columnNumber:4 delegate:self pushPhotoPickerVc:NO];
//    imagePickerVC.isSelectOriginalPhoto = YES;
    self.imagePickerVC.allowTakePicture = NO;
    self.imagePickerVC.photoWidth = 1000;
    
    // 2. 在这里设置imagePickerVc的外观
    self.imagePickerVC.navigationBar.barTintColor = [UIColor colorWithHexString:@"#08080b"];
    self.imagePickerVC.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    self.imagePickerVC.oKButtonTitleColorNormal = [UIColor colorWithHexString:@"#08080b"];
    self.imagePickerVC.navigationBar.translucent = NO;
    
    // 3. 设置是否可以选择视频/图片/原图
    self.imagePickerVC.allowPickingVideo = YES;
    self.imagePickerVC.allowPickingImage = NO;
    self.imagePickerVC.allowPickingOriginalPhoto = NO;
    self.imagePickerVC.allowPickingGif = NO;
    self.imagePickerVC.allowPickingMultipleVideo = YES; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    self.imagePickerVC.minImagesCount = 1;
    self.imagePickerVC.alwaysEnableDoneBtn = YES;
    
    self.imagePickerVC.minPhotoWidthSelectable = 300;
    self.imagePickerVC.minPhotoHeightSelectable = 200;
    
    // 5. 单选模式,maxImagesCount为1时才生效
    self.imagePickerVC.showSelectBtn = NO;
    self.imagePickerVC.allowCrop = NO;
    self.imagePickerVC.needCircleCrop = NO;
    
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Assets Picker Delegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    NSLog(@"选完%@",assets);
    
    KSYInputCfgModel *model = [[KSYInputCfgModel alloc] init];
    
    model.pixelWidth = 720;
    model.pixelHeight = 1280;
    model.videoKbps = 4096;
    [self pushPreEditByAssets:assets andConfigModel:model];
////    @weakify(self);
//    KSYInputCfgViewController *inputCfgVC = [[KSYInputCfgViewController alloc] initWithNibName:[KSYInputCfgViewController className] bundle:[NSBundle mainBundle]];
//    inputCfgVC.finish = ^(KSYInputCfgModel *model) {
////        @strongify(self);
//        [self pushPreEditByAssets:assets andConfigModel:model];
//    };
//    //输出配置转场
//    self.slideInTransitioningDelegate = nil;
//    //控制现实遮盖的视图转场
//    self.slideInTransitioningDelegate = [[SlideInPresentationManager alloc] init];
//    self.slideInTransitioningDelegate.direction = PresentationDirectionTop;
//    self.slideInTransitioningDelegate.disableCompactHeight = NO;
//    self.slideInTransitioningDelegate.sliderRate = 1.0/3.0;
//    inputCfgVC.transitioningDelegate = self.slideInTransitioningDelegate;
//    inputCfgVC.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:inputCfgVC animated:YES completion:nil];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"选完%@",assets);
        KSYInputCfgViewController *inputCfgVC = [[KSYInputCfgViewController alloc] initWithNibName:[KSYInputCfgViewController className] bundle:[NSBundle mainBundle]];
        inputCfgVC.finish = ^(KSYInputCfgModel *model) {
            @strongify(self);
            [self pushPreEditByAssets:assets andConfigModel:model];
        };
        @strongify(self);
        //输出配置转场
        self.slideInTransitioningDelegate = nil;
        //控制现实遮盖的视图转场
        self.slideInTransitioningDelegate = [[SlideInPresentationManager alloc] init];
        self.slideInTransitioningDelegate.direction = PresentationDirectionTop;
        self.slideInTransitioningDelegate.disableCompactHeight = NO;
        self.slideInTransitioningDelegate.sliderRate = 1.0/3.0;
        inputCfgVC.transitioningDelegate = self.slideInTransitioningDelegate;
        inputCfgVC.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:inputCfgVC animated:YES completion:nil];
    }];
}

- (void)handleAssets:(NSArray *)assets{
    if (assets == nil || assets.count == 0) { return; }
    
    __block NSMutableArray *urlsArray = [NSMutableArray arrayWithCapacity:assets.count];
    for (NSInteger i = 0; i < assets.count; i++){
        [urlsArray addObject:[NSNull null]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group  = dispatch_group_create();
        
        PHImageManager *manager = [PHImageManager defaultManager];
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        for (PHAsset *phAsset in assets) {
            dispatch_group_enter(group);
            [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                if(([asset isKindOfClass:[AVComposition class]] && ((AVComposition *)asset).tracks.count == 2)){
                    
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSURL *url = urlAsset.URL;
                    [urlsArray replaceObjectAtIndex:[assets indexOfObject:phAsset] withObject:url];
                    dispatch_group_leave(group);
                    
                } else if ([asset isKindOfClass:[AVURLAsset class]] ) {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSURL *url = urlAsset.URL;
                    [urlsArray replaceObjectAtIndex:[assets indexOfObject:phAsset] withObject:url];
                    dispatch_group_leave(group);
                } else {
                    dispatch_group_leave(group);
                }
//
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSArray *urls = [NSArray arrayWithArray:urlsArray];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeDeterminate;
            hud.label.text = @"视频拼接中...\nidx:0 progress:00.00 %%";

            NSURL *outputURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%ld.mp4",time(NULL)]];
            CGSize resolution = CGSizeMake(1080, 1920);
            _concator = [[KSYMEConcator alloc] init];
            _concator.delegate = self;

            [_concator concatVideos:urls
                         resizeMode:KSYMEResizeModeFill
                         resolution:resolution
                          outputURL:outputURL];
        });
    });
}

- (void)pushPreEditByAssets:(NSArray *)asset andConfigModel:(KSYInputCfgModel *)model{
    if (asset == nil || asset.count == 0) {
        NSLog(@"至少选择一个视频进行导入");
        return;
    }
    
    KSYPreEditViewController *preEditVC = [[KSYPreEditViewController alloc] initWithNibName:[KSYPreEditViewController className] bundle:[NSBundle mainBundle]];
    preEditVC.configModel = model;
    preEditVC.originAssets = [NSMutableArray arrayWithArray:asset];
    [self.navigationController showViewController:preEditVC sender:nil];
}

#pragma mark -
#pragma mark - KSYMEConcatorDelegate
- (void)onConcatError:(KSYMEConcator *)concator error:(KSYStatusCode)error extraStr:(NSString *)extraStr{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.label.text = [NSString stringWithFormat:@"concat fail\n errorCode:%ld\n extraStr:%@",(long)error, extraStr];
    [hud hideAnimated:YES afterDelay:1];
}

- (void)onConcatFinish:(NSURL *)path{
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithNibName:[KSYEditViewController className] bundle:[NSBundle mainBundle] VideoURL:path];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)onConcatFileIndex:(NSInteger)idx progressChanged:(float)value{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [hud setProgress:value];
    hud.label.numberOfLines = 3;
    hud.label.text = [NSString stringWithFormat:@"视频拼接\n idx:%ld \nprogress:%.2f %%",(long)idx, value * 100];
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
