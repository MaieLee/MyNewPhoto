//
//  PictureFilterViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/15.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "PictureFilterViewController.h"
#import "BottomBarView.h"

@interface PictureFilterViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *pictureImageView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) BottomBarView *bottomView;
@property (nonatomic, assign) BOOL isHiddenView;
@property (nonatomic, assign) BOOL isLessthen;
@end

@implementation PictureFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pictureImageView = [[UIImageView alloc] initWithImage:self.picture];
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.pictureImageView.frame = self.view.frame;
    self.pictureImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.pictureImageView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 68)];
    [self.view addSubview:headerView];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, 0, 40, 40);
    [headerView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.center = CGPointMake(backBtn.center.x, headerView.center.y);
    self.headerView = headerView;
    
    WEAKSELF
    _bottomView = [[BottomBarView alloc] initWithFrame:CGRectMake(0, screenSize.height-63, screenSize.width, 63)];
    _bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:_bottomView];
    _bottomView.filterBlock = ^(id filter, NSString *desc) {
        [weakSelf showFilters:filter Desc:desc];
    };
    
    [self addGestureRecognizer];
}

// 添加所有的手势
- (void)addGestureRecognizer
{
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGestureRecognizer.delegate = self;
    [self.pictureImageView addGestureRecognizer:pinchGestureRecognizer];
    
    //点击
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.pictureImageView addGestureRecognizer:tapGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.pictureImageView addGestureRecognizer:panGestureRecognizer];
}

#pragma mark 手势处理
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.pictureImageView.frame.size.width <= screenSize.width*3.0) {
            self.pictureImageView.transform = CGAffineTransformScale(self.pictureImageView.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        }else{
            self.pictureImageView.frame = CGRectMake(self.pictureImageView.frame.origin.x, self.pictureImageView.frame.origin.y, screenSize.width*3.0, screenSize.height*3);
        }
        pinchGestureRecognizer.scale = 1;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.isLessthen = self.pictureImageView.frame.size.width > screenSize.width?NO:YES;
        if (self.isLessthen) {
            [UIView animateWithDuration:0.2 animations:^{
                self.pictureImageView.frame = self.view.frame;
            }];
        }
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    self.isHiddenView = !self.isHiddenView;
    if (self.isHiddenView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, -68);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 63);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
}

- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.isLessthen) {
            CGPoint translation = [panGestureRecognizer translationInView:self.pictureImageView.superview];
            [self.pictureImageView setCenter:(CGPoint){self.pictureImageView.center.x + translation.x, self.pictureImageView.center.y + translation.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:self.pictureImageView.superview];
        }
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.isLessthen) {
            CGPoint originCenter = self.view.center;
            CGFloat newCenterX = 0.0;
            CGFloat newCenterY = 0.0;
            if (originCenter.x < self.pictureImageView.center.x && originCenter.y >= self.pictureImageView.center.y) {
                //往右上角拖
                newCenterX = originCenter.x+(self.pictureImageView.frame.size.width/2-self.view.frame.size.width/2);
                newCenterY = originCenter.y-(self.pictureImageView.frame.size.height/2-self.view.frame.size.height/2);
            }
            
            [self.pictureImageView setCenter:(CGPoint){newCenterX, newCenterY}];
        }
    }
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showFilters:(id)filter Desc:(NSString *)desc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
