//
//  VideoRecordTimePickerView.m
//  MyNewPhoto
//
//  Created by MaieLee on 2018/7/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "VideoRecordTimePickerView.h"

@interface VideoRecordTimePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *nameArray;
@end

@implementation VideoRecordTimePickerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _nameArray = [NSArray arrayWithObjects:@"10秒",@"15秒",@"20秒",@"无限制", nil];
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI{
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor grayColor];
    [self addSubview:topLine];
    
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 162)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [self addSubview:_pickerView];
}

#pragma mark pickerview function
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

//返回指定列的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40.0f;
}

// 自定义指定列的每行的视图，即指定列的每行的视图行为一致
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if (!view){
        view = [[UIView alloc] init];
    }
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = [_nameArray objectAtIndex:row];
    [view addSubview:text];
    
    return view;
}

//被选择的行

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSInteger recordTime = 10+row*5;
    if (row==3) {
        recordTime = 60*60*24;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:@"RecordTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.recordTimeBlock) {
        self.recordTimeBlock(self.nameArray[row]);
    }
}

@end
