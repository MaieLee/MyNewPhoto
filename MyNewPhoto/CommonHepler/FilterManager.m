//
//  FilterManager.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/10.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "FilterManager.h"

@interface FilterManager ()

@property (nonatomic, strong) NSArray *filterArray;

@end

@implementation FilterManager

- (void)filterTheImage:(NSInteger)index{
    
}

- (NSArray *)filterArray{
    if (_filterArray == nil) {
        _filterArray = [NSArray arrayWithContentsOfFile:@"Filter.json"];
    }
    
    return _filterArray;
}

@end
