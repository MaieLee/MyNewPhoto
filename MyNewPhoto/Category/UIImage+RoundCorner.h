//
//  UIImage+RoundCorner.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/4.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RoundCorner)
- (UIImage *)imageWithRect:(CGSize)rectSize;
+ (UIImage *)createImageWithColor:(UIColor *)color Size:(CGSize)size;
+ (UIImage *)createFilterImage;
+ (UIImage *)createTickImage;
+ (UIImage *)thumbnailWithImage:(UIImage *)originalImage size:(CGSize)size;
+ (UIImage *)waterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect;
@end
