//
//  VideoRecordTimePickerView.h
//  MyNewPhoto
//
//  Created by MaieLee on 2018/7/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RecordTimePickerView) (NSString *times);

@interface VideoRecordTimePickerView : UIView
@property (nonatomic, copy) RecordTimePickerView recordTimeBlock;

- (void)show;
@end
