//
//  FilterManager.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/10.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FilterManager : NSObject
@property (nonatomic, strong) NSArray *filterArray;
- (id)filterTheImage:(NSInteger)index;
@end
