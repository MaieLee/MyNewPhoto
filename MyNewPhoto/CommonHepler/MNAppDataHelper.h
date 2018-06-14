//
//  MNAppDataHelper.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/6/13.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNAppDataHelper : NSObject

@property (nonatomic, strong) NSMutableArray *filtersArray;

+ (MNAppDataHelper *)shareManager;

@end
