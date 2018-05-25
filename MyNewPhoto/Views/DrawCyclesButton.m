//
//  DrawCyclesButton.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "DrawCyclesButton.h"

@implementation DrawCyclesButton

- (void)drawRect:(CGRect)rect{
    // 获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = rect.size.width;
    
    /**
     画实心圆
     */
    //填充当前绘画区域内的颜色
    [[UIColor whiteColor] set];
    //填充当前矩形区域
    CGContextFillRect(ctx, rect);
    //以矩形frame为依据画一个圆
    CGContextAddEllipseInRect(ctx, rect);
    //填充当前绘画区域内的颜色
    [mnColor(0, 0, 0, 0.1) set];
    //填充(沿着矩形内围填充出指定大小的圆)
    CGContextFillPath(ctx);
    
    /**
     *  画空心圆
     */
    CGRect bigRect = CGRectMake(rect.origin.x + kBorderWith,
                                rect.origin.y + kBorderWith,
                                width - kBorderWith*2,
                                width - kBorderWith*2);
    
    //设置空心圆的线条宽度
    CGContextSetLineWidth(ctx, kBorderWith);
    //以矩形bigRect为依据画一个圆
    CGContextAddEllipseInRect(ctx, bigRect);
    //填充当前绘画区域的颜色
    [[UIColor colorWithRed:26/255.0 green:170/255.0 blue:255/255.0 alpha:1] set];
    //(如果是画圆会沿着矩形外围描画出指定宽度的（圆线）空心圆)/（根据上下文的内容渲染图层）
    CGContextStrokePath(ctx);
}

@end
