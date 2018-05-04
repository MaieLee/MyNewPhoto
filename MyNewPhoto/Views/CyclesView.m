//
//  CyclesImageView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/4.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "CyclesView.h"

@implementation CyclesView

- (void)drawRect:(CGRect)rect{
    // 获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = rect.size.width;
    
    /**
     *  画空心圆
     */
    CGRect bigRect = CGRectMake(rect.origin.x + kBorderWith/4,
                                rect.origin.y + kBorderWith/4,
                                width - kBorderWith/2,
                                width - kBorderWith/2);
    
    //设置空心圆的线条宽度
    CGContextSetLineWidth(ctx, kBorderWith/4);
    //以矩形bigRect为依据画一个圆
    CGContextAddEllipseInRect(ctx, bigRect);
    //填充当前绘画区域的颜色
    [[UIColor blackColor] set];
    //(如果是画圆会沿着矩形外围描画出指定宽度的（圆线）空心圆)/（根据上下文的内容渲染图层）
    
    CGContextStrokePath(ctx);
}

@end
