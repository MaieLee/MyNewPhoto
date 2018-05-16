//
//  MNTitleButton.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNTitleButton.h"

@implementation MNTitleButton

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect titleF = self.titleLabel.frame;
    CGRect imageF = self.imageView.frame;
    
    titleF.origin.x = 0;
    self.titleLabel.frame = titleF;
    
    imageF.origin.x = CGRectGetMaxX(titleF) + 10;
    self.imageView.frame = imageF;
}

@end
