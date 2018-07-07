//
//  GuideView.m
//  MyNewPhoto
//
//  Created by mylee on 2018/7/7.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "GuideView.h"

@interface GuideView()
@property (nonatomic, strong) UIImageView *leftSlide;
@property (nonatomic, strong) UILabel *leftLbl;
@property (nonatomic, strong) UIImageView *upSlide;
@property (nonatomic, strong) UILabel *upLbl;
@property (nonatomic, assign) NSInteger tapCount;
@end

@implementation GuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI
{
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
    UIImageView *upSlide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up_slide"]];
    [upSlide sizeToFit];
    [self addSubview:upSlide];
    self.upSlide = upSlide;
    UILabel *upLbl = [UILabel new];
    upLbl.text = @"上滑选择滤镜";
    upLbl.textColor = [UIColor whiteColor];
    upLbl.font = [UIFont systemFontOfSize:18];
    [self addSubview:upLbl];
    self.upLbl = upLbl;
    
    UIImageView *leftSlide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_slide"]];
    [leftSlide sizeToFit];
    [self addSubview:leftSlide];
    self.leftSlide = leftSlide;
    UILabel *leftLbl = [UILabel new];
    leftLbl.text = @"左滑查看图片库";
    leftLbl.textColor = [UIColor whiteColor];
    leftLbl.font = [UIFont systemFontOfSize:18];
    [self addSubview:leftLbl];
    self.leftLbl = leftLbl;
    
    self.leftSlide.hidden = YES;
    self.leftLbl.hidden = YES;
    
    [self setUpConstraint];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
}

- (void)setUpConstraint{
    [self.upLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).mas_equalTo(-30);
    }];
    [self.upSlide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.upLbl.mas_bottom).mas_equalTo(-45);
    }];
    
    [self.leftSlide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(-40);
    }];
    [self.leftLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftSlide.mas_bottom).mas_offset(20);
        make.right.mas_equalTo(-20);
    }];
}

- (void)tap:(id)sender
{
    self.tapCount++;
    if (self.tapCount==1) {
        self.upLbl.hidden = YES;
        self.upSlide.hidden = YES;
        
        self.leftSlide.hidden = NO;
        self.leftLbl.hidden = NO;
    }else{
        self.upLbl.hidden = YES;
        self.upSlide.hidden = YES;
        
        self.leftSlide.hidden = YES;
        self.leftLbl.hidden = YES;
        
        [self closeTap:nil];
    }
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)closeTap:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasShowGuideView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self removeFromSuperview];
}

@end
