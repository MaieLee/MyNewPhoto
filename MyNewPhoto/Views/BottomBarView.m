//
//  BottomBarView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "BottomBarView.h"
#import "DrawCyclesButton.h"
#import "CyclesView.h"

@interface BottomBarView ()
@property (nonatomic, strong) DrawCyclesButton *camera;

@end

@implementation BottomBarView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI{
    _camera = [[DrawCyclesButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 110, 76, 76)];
    [self addSubview:_camera];
    _camera.center = CGPointMake(self.center.x, _camera.center.y);
    [_camera addTarget:self action:@selector(drawColor) forControlEvents:UIControlEventTouchUpInside];
    
    CyclesView *cyclesView = [[CyclesView alloc] initWithFrame:CGRectMake(20, 0, 36, 36)];
    [self addSubview:cyclesView];
    cyclesView.center = CGPointMake(cyclesView.center.x, _camera.center.y);
    cyclesView.backgroundColor = mnColor(0, 0, 0, 0);
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    [self insertSubview:_imgView belowSubview:cyclesView];
    _imgView.center = cyclesView.center;
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [cyclesView addSubview:_activityIndicator];
    _activityIndicator.frame = (CGRect){0,0,cyclesView.frame.size};
    _activityIndicator.hidesWhenStopped = YES;
    
    
}

- (void)drawColor{
    if (self.picBlock) {
        self.picBlock();
    }
}

@end
