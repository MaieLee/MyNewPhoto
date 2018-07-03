//
//  SettingViewController.h
//  MyNewPhoto
//
//  Created by mylee on 2018/7/1.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ViewController.h"

typedef void(^SettingDissBlock) (void);

@interface SettingViewController : ViewController

@property (nonatomic, copy) SettingDissBlock complete;

@end
