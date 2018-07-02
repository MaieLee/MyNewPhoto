//
//  SettingModel.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/7/2.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject
@property (nonatomic, copy)  NSString *name;
@property (nonatomic, assign) BOOL isShowSwitch;
@property (nonatomic, copy)  NSString *desc;
@end
