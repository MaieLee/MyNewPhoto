//
//  ShowPicView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/31.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ShowPicView.h"

@interface ShowPicView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) BOOL isHold;
@property (nonatomic, assign) BOOL isSavePic;
@property (nonatomic, strong) NSTimer *timer;
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
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2;
    _oldFrame = self.frame;
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4)];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_bgImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(holdPicture)];
    [self addGestureRecognizer:tap];
    self.hidden = YES;
    self.alpha = 0.2;
}

- (void)showCameraImage:(UIImage *)image IsSavePic:(BOOL)isSavePic Complete:(void (^)(void))complete{
    self.hidden = NO;
    _isSavePic = isSavePic;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.bgImageView.image = image;
    self.alpha = 0.2;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
        self.timer = [NSTimer timerWithTimeInterval:3.f target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }];
}

- (void)holdPicture{
    self.isHold = !self.isHold;
    if (self.isHold) {
        [self.timer invalidate];
        self.timer = nil;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(-2, -2, screenSize.width+4, screenSize.height+4);
            self.bgImageView.frame = CGRectMake(2,2,screenSize.width,screenSize.height);
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = self.oldFrame;
            self.bgImageView.frame = CGRectMake(2,2,self.oldFrame.size.width-4,self.oldFrame.size.height-4);
        } completion:^(BOOL finished) {
            self.timer = [NSTimer timerWithTimeInterval:3.f target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }];
    }
}

- (void)timerAction
{
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.complete) {
        self.complete(self.isSavePic,self.bgImageView.image);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(self.frame.size.width+10, 0);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 0.2;
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

@end
