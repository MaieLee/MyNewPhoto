//
//  ShowPicView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/31.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ShowPicView.h"

@interface ShowPicView ()
@property (strong, nonatomic) AVPlayer *myPlayer;//播放器
@property (strong, nonatomic) AVPlayerItem *item;//播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;//播放界面（layer）
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation ShowPicView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    _bgImageView = [[UIImageView alloc] initWithFrame:self.frame];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_bgImageView];
}

- (void)showCameraImage:(UIImage *)image{
    self.bgImageView.image = image;
}

@end
