//
//  BottomBarView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CameraPicBlock) ();

@interface BottomBarView : UIView
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;

@property (nonatomic, copy) CameraPicBlock picBlock;

@end
