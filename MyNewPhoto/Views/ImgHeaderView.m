//
//  ImgHeaderView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ImgHeaderView.h"

@interface ImgHeaderView()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ImgHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI{
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat btnTop = kIsPhoneX?27:14;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, btnTop, 40, 40);
    [self addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _titleBtn = [[MNTitleButton alloc] init];
    _titleBtn.frame = CGRectMake(0, btnTop, 100, self.frame.size.height-10);
    _titleBtn.titleLabel.font = mnFont(15);
    [_titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_titleBtn setTitle:@"" forState:UIControlStateNormal];
    [_titleBtn setImage:[UIImage imageNamed:@"History_SearchArrow_down"] forState:UIControlStateNormal];
    [self addSubview:_titleBtn];
    _titleBtn.center = CGPointMake(self.center.x, backBtn.center.y);
    
    [_titleBtn addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction:(id)sender{
    if (self.backBlock) {
        self.backBlock();
    }
}

- (void)titleAction:(UIButton *)sender{
    [sender setSelected:!sender.isSelected];
    
    if (sender.isSelected) {
        [sender setImage:[UIImage imageNamed:@"History_SearchArrow_Up"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"History_SearchArrow_down"] forState:UIControlStateNormal];
    }
    
    if (self.titleBlock) {
        self.titleBlock(sender.isSelected);
    }
}

- (void)closeTitle{
    if (self.titleBtn.isSelected) {
        [self.titleBtn setSelected:!self.titleBtn.isSelected];
        [_titleBtn setImage:[UIImage imageNamed:@"History_SearchArrow_down"] forState:UIControlStateNormal];
    }
}

@end
