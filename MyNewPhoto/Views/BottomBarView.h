//
//  BottomBarView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GPUImageFilter;

typedef void(^ShowFilterBlock) (id filter,NSString *desc);

@interface BottomBarView : UIView

@property (nonatomic, assign) BOOL isFilterPicture;

@property (nonatomic, copy) ShowFilterBlock filterBlock;

- (void)show;
- (void)hide;

@end
