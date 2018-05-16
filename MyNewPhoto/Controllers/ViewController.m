//
//  ViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/2.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *selImageView;
@property (nonatomic, strong) UIView *choseImgView;
@property (nonatomic, strong) UIButton *localImageBtn;
@property (nonatomic, strong) UIButton *cameraImageBtn;

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
