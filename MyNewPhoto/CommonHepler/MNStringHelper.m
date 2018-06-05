//
//  MNStringHelper.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/6/5.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNStringHelper.h"

@implementation MNStringHelper

//传入 秒  得到 xx:xx:xx
+ (NSString *)getHHMMSSFromSS:(NSTimeInterval)totalTime{
    NSInteger seconds = totalTime;
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
    
}

//传入 秒  得到  xx:xx
+ (NSString *)getMMSSFromSS:(NSTimeInterval)totalTime{
    NSInteger seconds = totalTime;
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
    return format_time;
    
}

@end
