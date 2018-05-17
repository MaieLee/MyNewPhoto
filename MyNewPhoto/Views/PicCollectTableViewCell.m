//
//  PicCollectTableViewCell.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/17.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "PicCollectTableViewCell.h"

@implementation PicCollectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
        [self addAutolayout];
    }
    
    return self;
}

- (void)setUpUI{
    self.backgroundColor = [UIColor whiteColor];
    UIView *topLine = [UIView new];
    topLine.frame = CGRectMake(0, 0, kScreenWidth, 0.5);
    topLine.backgroundColor = [UIColor grayColor];
    topLine.alpha = 0.5;
    [self addSubview:topLine];
    
    _titleLbl = [UILabel new];
    _titleLbl.font = mnFont(15);
    _titleLbl.textColor = [UIColor blackColor];
    [self addSubview:_titleLbl];
    
    _countLbl = [UILabel new];
    _countLbl.font = mnFont(15);
    _countLbl.textColor = [UIColor grayColor];
    [self addSubview:_countLbl];
}

- (void)addAutolayout{
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(15);
    }];
    
    [self.countLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(-15);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
