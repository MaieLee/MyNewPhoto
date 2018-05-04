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
    [self configViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)configViews{
    self.selImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.selImageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selImageView];
    
    self.choseImgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 65)];
    self.choseImgView.backgroundColor = [UIColor whiteColor];
    self.choseImgView.center = self.view.center;
    [self.view addSubview:self.choseImgView];
    
    self.localImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.localImageBtn.frame = CGRectMake(0, 0, 65, 65);
    [self.localImageBtn setBackgroundImage:[UIImage imageNamed:@"local_pic"] forState:UIControlStateNormal];
    [self.localImageBtn addTarget:self action:@selector(selLoaclPhoto) forControlEvents:UIControlEventTouchUpInside];
    self.cameraImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraImageBtn.frame = CGRectMake(0, 0, 65, 65);
    [self.cameraImageBtn setBackgroundImage:[UIImage imageNamed:@"camera_pic"] forState:UIControlStateNormal];
    [self.cameraImageBtn addTarget:self action:@selector(selCameraPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.choseImgView addSubview:self.localImageBtn];
    [self.choseImgView addSubview:self.cameraImageBtn];
    self.cameraImageBtn.frame = CGRectMake(self.localImageBtn.frame.size.width+20, 0, self.cameraImageBtn.frame.size.width, self.cameraImageBtn.frame.size.height);
    
}

- (void)selLoaclPhoto
{
    self.imagePickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerVc animated:YES completion:nil];
}

- (void)selCameraPhoto
{
    self.imagePickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePickerVc animated:YES completion:nil];
}

- (UIImagePickerController *)imagePickerVc{
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
    }
    
    return _imagePickerVc;
}

//选择完成回调函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];

    self.selImageView.image = image;
    self.choseImgView.hidden = YES;
}

//用户取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
