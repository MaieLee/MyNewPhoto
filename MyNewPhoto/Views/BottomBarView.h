//
//  BottomBarView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GPUImageFilter;

typedef void(^CameraPicBlock) (void);
typedef void(^CameraVideoBlock) (NSInteger cameraStatus);
typedef void(^ShowFilterBlock) (id filter,NSString *desc);

@interface BottomBarView : UIView
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, weak) UIViewController *parentVC;

@property (nonatomic, copy) CameraPicBlock picBlock;
@property (nonatomic, copy) CameraVideoBlock videoBlock;
@property (nonatomic, copy) ShowFilterBlock filterBlock;

- (void)startVideoRecord;
- (void)finishSavePic;
- (void)finishSaveVideo;

@end
