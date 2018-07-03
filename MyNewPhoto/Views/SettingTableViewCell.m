//
//  SettingTableViewCell.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/7/2.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.itemSwitch.onTintColor = [UIColor colorWithRed:252/255.0 green:115/255.0 blue:186/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
