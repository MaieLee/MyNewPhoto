//
//  SysPictureModel.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/21.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface SysPictureModel : NSObject

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UIImage *assetImage;

@end
