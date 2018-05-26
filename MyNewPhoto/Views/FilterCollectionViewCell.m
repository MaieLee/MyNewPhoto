//
//  FilterCollectionViewCell.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/10.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "FilterCollectionViewCell.h"
#import "FilterSampleModel.h"

@interface FilterCollectionViewCell ()

@end

@implementation FilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI{
    self.backgroundColor = [UIColor clearColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [self addSubview:_imageView];
    
    _selImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [self addSubview:_selImageView];
//    _selImageView.hidden = YES;
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 42, 40, 18)];
    _descLabel.textColor = [UIColor whiteColor];
    _descLabel.font = mnFont(12);
    _descLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_descLabel];
}

@end
