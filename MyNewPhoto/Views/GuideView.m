//
//  GuideView.m
//  MyNewPhoto
//
//  Created by mylee on 2018/7/7.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "GuideView.h"

@implementation GuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI
{
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    
}

@end
