//
//  SettingViewController.m
//  MyNewPhoto
//
//  Created by mylee on 2018/7/1.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "SettingModel.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpHeaderView];
}

- (void)setUpHeaderView{
    CGFloat headerHeight = kIsPhoneX?80:68;
    CGFloat btnTop = kIsPhoneX?27:14;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, headerHeight)];
    [self.view addSubview:headerView];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, btnTop, 40, 40);
    [headerView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, btnTop, 0, 0)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"设置";
    titleLabel.font = mnFont(15);
    [titleLabel sizeToFit];
    [headerView addSubview:titleLabel];
    titleLabel.center = CGPointMake(headerView.center.x, backBtn.center.y);
    
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    [headerView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.equalTo(headerView);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.view addSubview:self.mainTableView];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.mas_equalTo(headerView.frame.size.height);
    }];
}

-(UITableView *)mainTableView{
    if(_mainTableView == nil){
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
        _mainTableView.rowHeight = 50.0f;
        _mainTableView.tableFooterView = [UIView new];
        [_mainTableView registerNib:[UINib nibWithNibName:@"SettingTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingCellIdentifier"];
    }
    return  _mainTableView;
}

- (void)setUpDatas{
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    SettingModel *sModel = [[SettingModel alloc] init];
    sModel.name = @"情迷水印";
    sModel.isShowSwitch = YES;
    [self.dataArray addObject:sModel];
    
    sModel = [[SettingModel alloc] init];
    sModel.name = @"录像时长";
    sModel.isShowSwitch = NO;
    sModel.desc = @"10秒";
    [self.dataArray addObject:sModel];
    
    sModel = [[SettingModel alloc] init];
    sModel.name = @"录像时长";
    sModel.isShowSwitch = NO;
    sModel.desc = @"10秒";
    [self.dataArray addObject:sModel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCellIdentifier";
    SettingTableViewCell *cell = (SettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)backAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
