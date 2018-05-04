//
//  ToolBarView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SwitchCameraBlock) ();

@interface ToolBarView : UIView

@property (nonatomic, copy) SwitchCameraBlock cameraBlock;

@end
