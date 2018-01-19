//
//  KSYOutputCfgViewController.m
//  demo
//
//  Created by sunyazhou on 2017/7/25.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYOutputCfgViewController.h"

@interface KSYOutputCfgViewController ()<OutputCfgCellDelegate,UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *models;
@property (weak, nonatomic) IBOutlet UITableView *configTableview;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UIButton *startComposeButton;

@end

@implementation KSYOutputCfgViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubview];
    [self buildModels];
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)buildModels{
    [self.models removeAllObjects];
    if (self.outputModel) {
        [self.models addObject:self.outputModel];
    }
    [self.configTableview reloadData];
}

/**
 demo的UI代码 不需要关注
 */
- (void)configSubview{
    self.configTableview.dataSource = self;
    self.configTableview.delegate = self;
    [self.configTableview registerNib:[UINib nibWithNibName:[OutputConfigCell className] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[OutputConfigCell className]];

    [self.configTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(30, 0, 0, 0));
    }];
    
    self.configTableview.backgroundColor = [UIColor blackColor];
    self.configTableview.allowsSelection = YES;
    
    self.configTableview.layer.cornerRadius = 2;
    self.configTableview.layer.masksToBounds = YES;
    
    
    [self.outputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.bottom.equalTo(self.configTableview.mas_top);
        make.width.equalTo(@120);
    }];
    
    [self.startComposeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.view);
        make.bottom.equalTo(self.configTableview.mas_top);
        make.width.equalTo(@80);
    }];
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
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OutputConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:[OutputConfigCell className] forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.section];
    cell.delegate = self;
    
    return cell;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.00001;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    return [self generateNewAttachmentLabelWithContent:@"输出配置"];
//}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreenHeight * (2.0/5.0) - 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView endEditing:YES];
}

#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
- (void)outputConfigCell:(OutputConfigCell *)cell
             outputModel:(OutputModel *)model{
    if ([self.models containsObject:model]) {
        NSUInteger index = [self.models indexOfObject:model];
        [self.models replaceObjectAtIndex:index withObject:model];
    } else {
        [self.models addObject:model];
    }
    self.outputModel = model;
}

- (IBAction)startComposeAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(outputConfigVC:withModel:isCancel:)]) {
        [self.delegate outputConfigVC:self withModel:self.outputModel isCancel:NO];
    }
}


#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
#pragma mark -
#pragma mark - life cycle 视图的生命周期
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

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
