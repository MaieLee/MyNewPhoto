//
//  ShowPicView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/31.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ShowPicViewBlock)(BOOL isSavePic,UIImage *saveImage);

@interface ShowPicView : UIView

@property (nonatomic, copy) ShowPicViewBlock complete;

- (void)showCameraImage:(UIImage *)image IsSavePic:(BOOL)isSavePic Complete:(void (^)(void))complete;
@end
