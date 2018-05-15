//
//  FilterManager.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/10.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager

- (id)filterTheImage:(NSInteger)index{
    NSDictionary *filterDict = self.filterArray[index];
    Class filterClass = NSClassFromString(filterDict[@"name"]);
    if (!filterClass) {
        return nil;
    }
    
    id instance = [[filterClass alloc] init];
    
    return instance;
}

- (NSArray *)filterArray{
    if (_filterArray == nil) {
        NSError *error;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Filter" ofType:@"json"];
        //根据文件路径读取数据
        NSData *jdata = [[NSData alloc] initWithContentsOfFile:filePath];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
        
        _filterArray = (NSArray *)jsonObject;
    }
    
    return _filterArray;
}

@end
