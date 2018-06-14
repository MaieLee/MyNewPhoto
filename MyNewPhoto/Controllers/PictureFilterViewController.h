//
//  PictureFilterViewController.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/15.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ViewController.h"

@interface PictureFilterViewController : ViewController
@property (nonatomic, strong) UIImage *picture;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) NSURL *videoURL;
@end
