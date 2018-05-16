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
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, 0, 40, 40);
    [self addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.center = CGPointMake(backBtn.center.x, self.center.y);
    
    _titleBtn = [[MNTitleButton alloc] init];
    _titleBtn.frame = CGRectMake(0, 0, 40, 40);
    _titleBtn.titleLabel.font = mnFont(13);
    [_titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:_titleBtn];
    
}

- (void)backAction:(id)sender{
    if (self.backBlock) {
        self.backBlock();
    }
}

@end
