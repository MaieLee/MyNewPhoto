//
//  PictureFilterViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/15.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "PictureFilterViewController.h"

@interface PictureFilterViewController ()

@property (nonatomic, strong) UIImageView *pictureImageView;

@end

@implementation PictureFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pictureImageView = [[UIImageView alloc] initWithImage:self.picture];
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.pictureImageView.frame = self.view.frame;
    [self.view addSubview:self.pictureImageView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
