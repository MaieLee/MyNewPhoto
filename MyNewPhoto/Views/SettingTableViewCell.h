//
//  SettingTableViewCell.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/7/2.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UISwitch *itemSwitch;

@end
