//
//  BottomBarView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GPUImageFilter;

typedef void(^CameraPicBlock) ();
typedef void(^ShowFilterBlock) (GPUImageFilter *filter);

@interface BottomBarView : UIView
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;

@property (nonatomic, copy) CameraPicBlock picBlock;
@property (nonatomic, copy) ShowFilterBlock filterBlock;

@end
