//
//  ViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/2.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *selImageView;
@property (nonatomic, strong) UIView *choseImgView;
@property (nonatomic, strong) UIButton *localImageBtn;
@property (nonatomic, strong) UIButton *cameraImageBtn;

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

- (void)showLoadingHUD:(NSString *)message{
    [self hideHUD];
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self currentView] animated:YES];
    if (message == nil) {
        progressHUD.mode = MBProgressHUDModeIndeterminate;
    }else{
        progressHUD.mode = MBProgressHUDModeText;
        progressHUD.label.text = message;
    }
    progressHUD.graceTime = 1;
    progressHUD.bezelView.color = [UIColor whiteColor];
    progressHUD.bezelView.layer.borderColor = [UIColor whiteColor].CGColor;
    progressHUD.bezelView.layer.borderWidth = 1;
    progressHUD.removeFromSuperViewOnHide = YES;
    if (message) {
        [progressHUD hideAnimated:YES afterDelay:2.0];
    }
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:[self currentView] animated:YES];
}

- (UIView *)currentView {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        viewController = [(UITabBarController *)viewController selectedViewController];
    }
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        viewController = [(UINavigationController *)viewController visibleViewController];
    }
    
    return viewController.view;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
