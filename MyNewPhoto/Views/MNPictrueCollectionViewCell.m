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
    self.backgroundColor = [UIColor whiteColor];
    self.picView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.picView.contentMode =  UIViewContentModeScaleAspectFill;
    self.picView.clipsToBounds = YES;
    [self.contentView addSubview:self.picView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = mnFont(13);
    self.timeLabel.backgroundColor = mnColor(0, 0, 0, 0.6);
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.hidden = YES;
}

- (void)addAutolayout
{
    [self.picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.contentView);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(16);
    }];
}

@end
