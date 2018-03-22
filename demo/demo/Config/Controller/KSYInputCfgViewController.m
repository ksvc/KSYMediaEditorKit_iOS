//
//  KSYInputCfgViewController.m
//  demo
//
//  Created by sunyazhou on 2017/10/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYInputCfgViewController.h"
#import "KSYInputCfgCell.h"
#import "KSYInputCfgModel.h"

@interface KSYInputCfgViewController ()<UITableViewDataSource,UITableViewDelegate,KSYInputCfgCellDelegte>
@property (weak, nonatomic) IBOutlet UITableView *inpuCfgTableView;
@property (strong, nonatomic) NSMutableArray *models;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@end

@implementation KSYInputCfgViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.models = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildModels];
    [self configSubview];
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)buildModels{
    KSYInputCfgModel *inputModel = [[KSYInputCfgModel alloc] init];
    
    inputModel.pixelWidth = 720;
    inputModel.pixelHeight = 1280;
    inputModel.videoKbps = 4096;
    
    [self.models removeAllObjects];
    [self.models addObjectsFromArray:@[inputModel]];
}
- (void)configSubview{
    [self.inpuCfgTableView registerNib:[UINib nibWithNibName:[KSYInputCfgCell className] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[KSYInputCfgCell className]];
    self.inpuCfgTableView.backgroundColor = [UIColor blackColor];
}

#pragma mark -
#pragma mark - public methods 公有方法

#pragma mark -
#pragma mark - override methods 复写方法
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
    KSYInputCfgCell *cell = [tableView dequeueReusableCellWithIdentifier:[KSYInputCfgCell className] forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.section];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreenHeight/3;
}


- (void)inputConfigCell:(KSYInputCfgCell *)cell
               cfgModel:(KSYInputCfgModel*)model{
    [self.models removeAllObjects];
    [self.models addObject:model];
    [self.inpuCfgTableView reloadData];
}
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

- (IBAction)doneButtonAction:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(inputCfgViewController:inputModel:)]) {
//        [self.delegate inputCfgViewController:self inputModel:[self.models firstObject]];
//    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.finish) {
            self.finish([self.models firstObject]);
        }
    }];
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log
- (void)dealloc{
    
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
