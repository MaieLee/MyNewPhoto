//
//  MNImagePickerViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNImagePickerViewController.h"
#import "MNGetPhotoAlbums.h"
#import "ImgHeaderView.h"

@interface MNImagePickerViewController ()

@property (nonatomic, strong) ImgHeaderView *headerView;

@end

@implementation MNImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _headerView = [[ImgHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
    WEAKSELF
    _headerView.backBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self.view addSubview:_headerView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
