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
#import "VideoEditorViewController.h"

#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController/TZImageManager.h>


@interface KSYCfgViewController ()<UITableViewDataSource, UITableViewDelegate,RecordCfgCellDelegte,OutputCfgCellDelegate,TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *configTableView;
@property (strong, nonatomic) IBOutlet UILabel *recordLabel; //组头视图
@property (strong, nonatomic) IBOutlet UILabel *outputLabel; //组头视图
@property (nonatomic, strong) NSMutableArray *models;

@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *localImportButton;

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
    
    OutputModel *outputModel = [[OutputModel alloc] init];
    outputModel.resolution = KSYRecordPreset720P;
    outputModel.videoCodec = KSYVideoCodec_AUTO;
    outputModel.videoKbps = 2048;
    outputModel.audioKbps = 64;
    outputModel.videoFormat = KSYOutputFormat_MP4;
    
    [self.models removeAllObjects];
    [self.models addObjectsFromArray:@[recordModel,outputModel]];
}


/**
 demo的UI代码 不需要关注
 */
- (void)configSubview{
    [self.configTableView registerNib:[UINib nibWithNibName:[RecordConfigCell className] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[RecordConfigCell className]];
    
    [self.configTableView registerNib:[UINib nibWithNibName:[OutputConfigCell className] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[OutputConfigCell className]];
    
    CGFloat bottomY = kScreenHeight *0.15;
    [self.configTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-bottomY);
    }];
    
    //配置底部两个按钮
    CGFloat buttonHeight = 54;
    CGFloat buttonCenterX = kScreenWidth/4.0;
    CGFloat buttonCenterY = bottomY /2.0;
    [self.localImportButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).offset(50);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(-buttonCenterX );
        make.centerY.mas_equalTo(self.view.mas_bottom).offset(-buttonCenterY);
        make.width.equalTo(@56);
        make.height.equalTo(@(buttonHeight));
    }];
    [self.startRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.localImportButton);
        make.top.mas_equalTo(self.localImportButton.mas_top);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(buttonCenterX);
    }];
    self.configTableView.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    
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
    if (indexPath.section == 0) {
        RecordConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:[RecordConfigCell className] forIndexPath:indexPath];
        cell.model = [self.models objectAtIndex:indexPath.section];
        cell.delegate = self;
        return cell;
    }
    OutputConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:[OutputConfigCell className] forIndexPath:indexPath];
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
    if (section == 0) {
        return self.recordLabel;
    } else if (section == 1) {
        return self.outputLabel;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
- (void)recordConfigCell:(RecordConfigCell *)cell
             recordModel:(RecordConfigModel *)model{
    if ([self.models containsObject:model]) {
        NSUInteger index = [self.models indexOfObject:model];
        [self.models replaceObjectAtIndex:index withObject:model];
    } else {
        [self.models addObject:model];
    }
}
- (void)outputConfigCell:(OutputConfigCell *)cell
             outputModel:(OutputModel *)model{
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
    [self pushTZImagePickerController];
}

- (IBAction)startRecordAction:(UIButton *)button{
    KSYRecordViewController *recordVC = [[KSYRecordViewController alloc] initWithNibName:@"KSYRecordViewController" bundle:[NSBundle mainBundle]];
    recordVC.models = self.models;
    [self.navigationController pushViewController:recordVC animated:YES];
}


/**
 弹出相册选择视频
 */
- (void)pushTZImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:1 delegate:self pushPhotoPickerVc:YES];
    
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    imagePickerVc.minImagesCount = 1;
    imagePickerVc.alwaysEnableDoneBtn = NO;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    imagePickerVc.circleCropRadius = 100;
    imagePickerVc.isStatusBarDefault = NO;
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    imagePickerVc.allowPreview = YES;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    //    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
    //        NSLog(@"%@",assets);
    //    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


#pragma mark -
#pragma mark - TZImagePickerController Delegate 相册选择代理
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset{
    // open this code to send video / 打开这段代码发送视频
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //导出完成，在这里写上传代码，通过路径或者通过NSData上传
//        KSYEditViewController *editVC = [[KSYEditViewController alloc] initWithNibName:[KSYEditViewController className] bundle:[NSBundle mainBundle] VideoURL:[NSURL fileURLWithPath:outputPath]];
        VideoEditorViewController *editVC = [[VideoEditorViewController alloc] initWithUrl:[NSURL fileURLWithPath:outputPath]];
        editVC.outputModel = self.models.lastObject;
        [self.navigationController pushViewController:editVC animated:YES];
    }];
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
