//
//  MNTitleButton.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNTitleButton.h"

@implementation MNTitleButton

//设置图片居右
-(void)setImageToRight
{
    NSDictionary *attribute = @{NSFontAttributeName:self.titleLabel.font};
    //获取文本的宽度
    CGFloat btnWidth = [self.titleLabel.text boundingRectWithSize:CGSizeMake(0, 24)
                                                         options:\
                        NSStringDrawingTruncatesLastVisibleLine |
                        NSStringDrawingUsesLineFragmentOrigin |
                        NSStringDrawingUsesFontLeading
                                                      attributes:attribute
                                                         context:nil].size.width;
    
    
    //通过调节文本和图片的内边距到达目的
    self.imageEdgeInsets = UIEdgeInsetsMake(3, btnWidth+2.5, 0, -btnWidth);
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.imageView.image.size.width-2.5, 0, self.imageView.image.size.width)];
}
@end
