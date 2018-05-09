//
//  CameraFilterView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/9.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraFilterViewDelegate;

@interface CameraFilterView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *picArray;//图片数组
@property (strong, nonatomic) id <CameraFilterViewDelegate> cameraFilterDelegate;
@end

@protocol CameraFilterViewDelegate <NSObject>

- (void)switchCameraFilter:(NSInteger)index;//滤镜选择方法

@end
