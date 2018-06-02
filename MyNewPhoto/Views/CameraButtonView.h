//
//  CameraButtonView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/25.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TakePictureComplete) (void);
typedef void(^TakeVideoComplete) (NSInteger cameraStatus);//0:pre 1:start 2:end

@interface CameraButtonView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) TakePictureComplete takePicture;
@property (nonatomic, copy) TakeVideoComplete takeVideo;

- (void)startRecord;
- (void)finishSaveVideo;
@end
