//
//  ImgHeaderView.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNTitleButton.h"

typedef void(^BackBlock) ();

@interface ImgHeaderView : UIView

@property (nonatomic, copy) BackBlock backBlock;
@property (nonatomic, strong) MNTitleButton *titleBtn;

@end
