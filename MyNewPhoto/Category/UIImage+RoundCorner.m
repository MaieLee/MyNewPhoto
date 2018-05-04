//
//  UIImage+RoundCorner.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/4.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "UIImage+RoundCorner.h"

@implementation UIImage (RoundCorner)
- (UIImage *)imageWithRect:(CGSize)rectSize{
    CGSize drawSize = CGSizeMake(rectSize.width-kBorderWith/2, rectSize.height-kBorderWith/2);
    CGRect rect = (CGRect){0.f, 0.f, drawSize};
    
    UIGraphicsBeginImageContextWithOptions(drawSize, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:drawSize.width/2].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
@end
