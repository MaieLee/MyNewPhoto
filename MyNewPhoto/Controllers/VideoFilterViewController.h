//
//  VideoFilterViewController.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/6/25.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

@interface VideoFilterViewController : ViewController
@property (nonatomic, strong) UIImage *picture;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) PHAsset *videoAsset;
@end
