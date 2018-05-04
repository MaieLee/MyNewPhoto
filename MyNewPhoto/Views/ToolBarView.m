//
//  ToolBarView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ToolBarView.h"


@interface ToolBarView()

@end

@implementation ToolBarView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI{
    UIButton *switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchCameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchCameraBtn setTitle:@"切换镜头" forState:UIControlStateNormal];
    switchCameraBtn.titleLabel.font = mnFont(14);
    switchCameraBtn.frame = CGRectMake(self.frame.size.width-80, 10, 60, 40);
    [self addSubview:switchCameraBtn];
    
    [switchCameraBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)switchCamera{
    if (self.cameraBlock) {
        self.cameraBlock();
    }
}

@end
