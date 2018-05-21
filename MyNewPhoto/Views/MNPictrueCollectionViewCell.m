//
//  MNPictrueCollectionViewCell.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/17.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNPictrueCollectionViewCell.h"

@implementation MNPictrueCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        
        [self initSubView];
        [self addAutolayout];
    }
    return self;
}


-(void)initSubView{
    self.backgroundColor=[UIColor whiteColor];
    self.picView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.picView.contentMode =  UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.picView];
}

- (void)addAutolayout
{
    [self.picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.contentView);
    }];
}

@end
