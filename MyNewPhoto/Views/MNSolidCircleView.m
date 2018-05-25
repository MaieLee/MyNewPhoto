//
//  MNSolidCircleView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/25.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNSolidCircleView.h"

@interface MNSolidCircleView()
@property (nonatomic, strong) UIColor *bgColor;
@end

@implementation MNSolidCircleView

- (instancetype)initWithFrame:(CGRect)frame BgColor:(UIColor *)bgColor
{
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _bgColor = bgColor;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect{
    //获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /**
     画实心圆
     */
    //填充当前绘画区域内的颜色
    [_bgColor set];
    //以矩形frame为依据画一个圆
    CGContextAddEllipseInRect(ctx, rect);
    //填充(沿着矩形内围填充出指定大小的圆)
    CGContextFillPath(ctx);
    
}

@end
