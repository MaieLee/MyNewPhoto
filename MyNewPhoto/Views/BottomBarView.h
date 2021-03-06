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

@property (nonatomic, copy) ShowFilterBlock filterBlock;
- (instancetype)initWithFrame:(CGRect)frame IsFilterPic:(BOOL)isFilter;
- (void)show;
- (void)hide;

@end
