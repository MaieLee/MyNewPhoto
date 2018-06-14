//
//  MNAppDataHelper.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/6/13.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNAppDataHelper.h"
#import "FilterSampleModel.h"

@implementation MNAppDataHelper

+ (MNAppDataHelper *)shareManager
{
    static MNAppDataHelper *shareMNAppDataHelperInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareMNAppDataHelperInstance = [[self alloc] init];
    });
    
    return shareMNAppDataHelperInstance;
}

- (void)setFiltersArray:(NSMutableArray *)filtersArray{
    _filtersArray = [NSMutableArray arrayWithCapacity:filtersArray.count];
    for (FilterSampleModel *filterSample in filtersArray) {
        FilterSampleModel *filter = [[FilterSampleModel alloc] init];
        filter.filter = filterSample.filter;
        filter.image = filterSample.image;
        filter.desc = filterSample.desc;
        filter.index = filterSample.index;
        filter.isSel = NO;
        
        [_filtersArray addObject:filter];
    }
}

@end
