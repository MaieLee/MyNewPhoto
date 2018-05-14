//
//  FilterSampleModel.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/11.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterSampleModel : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isSel;

@end
