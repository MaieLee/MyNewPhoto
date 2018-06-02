//
//  Macros.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define mnColor(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define mnFont(str) [UIFont systemFontOfSize:str]
#define screenSize [UIScreen mainScreen].bounds.size
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define kBorderWith 4.0
#define IS_IOS_9_10_11    [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0
#define IS_IOS_8       [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0

#define kScreenHeight  [UIScreen mainScreen].bounds.size.height
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width

#endif /* Macros_h */
