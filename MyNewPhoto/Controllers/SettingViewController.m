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
#import "VideoRecordTimePickerView.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) VideoRecordTimePickerView *recordTimePickerView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpHeaderView];
    [self setUpDatas];
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
        _mainTableView.bounces = NO;
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

- (VideoRecordTimePickerView *)recordTimePickerView{
    if (_recordTimePickerView == nil) {
        _recordTimePickerView = [[VideoRecordTimePickerView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        _recordTimePickerView.userInteractionEnabled = YES;
        WEAKSELF
        _recordTimePickerView.recordTimeBlock = ^(NSString *times) {
            SettingTableViewCell *cell = (SettingTableViewCell *)[weakSelf.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            cell.descLabel.text = times;
        };
    }
    
    return _recordTimePickerView;
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
    NSInteger recordTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"RecordTime"];
    if (recordTime>0) {
        if (recordTime<60) {
            sModel.desc = [NSString stringWithFormat:@"%ld秒",(long)recordTime];
        }else{
            sModel.desc = @"无限制";
        }
    }else{
        sModel.desc = @"10秒";
    }
    [self.dataArray addObject:sModel];
    
    sModel = [[SettingModel alloc] init];
    sModel.name = @"当前版本";
    sModel.isShowSwitch = NO;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    sModel.desc = version;
    [self.dataArray addObject:sModel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCellIdentifier";
    SettingTableViewCell *cell = (SettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (indexPath.row==1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.descLblRight.constant=0;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.descLblRight.constant=15;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SettingModel *sModel = self.dataArray[indexPath.row];
    cell.itemSwitch.hidden = !sModel.isShowSwitch;
    cell.itemLabel.text = sModel.name;
    cell.descLabel.hidden = sModel.isShowSwitch;
    if (!sModel.isShowSwitch) {
        cell.descLabel.text = sModel.desc;
    }
    if (sModel.isShowSwitch) {
        BOOL isHideWater = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsHideWater"];
        [cell.itemSwitch setOn:!isHideWater];
        [cell.itemSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        [self.recordTimePickerView show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchAction:(UISwitch *)sender{
    [[NSUserDefaults standardUserDefaults] setBool:!sender.isOn forKey:@"IsHideWater"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)backAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.complete) {
            self.complete();
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
