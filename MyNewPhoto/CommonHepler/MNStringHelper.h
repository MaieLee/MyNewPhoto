//
//  MNStringHelper.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/6/5.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNStringHelper : NSObject
+ (NSString *)getHHMMSSFromSS:(NSTimeInterval)totalTime;

+ (NSString *)getMMSSFromSS:(NSTimeInterval)totalTime;
@end
